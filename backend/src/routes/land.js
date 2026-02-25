const prisma = require('../lib/prisma');

// H3 resolution 9 → ~0.1 km² per hexagon
// Land costs from whitepaper
const RENT_COST_RPC = 5000; // 5,000 RPC/month
const MIN_PERIODS_TO_BUY = 3; // Must rent 3 periods before buying

async function landRoutes(fastify, options) {
  // ==================== EXPLORE A LAND (run through it) ====================
  fastify.post('/explore', {
    preValidation: [fastify.authenticate],
  }, async (request, reply) => {
    const { playerCardId } = request.user;
    const { h3Index, lat, lng, city, country } = request.body;

    if (!h3Index || lat === undefined || lng === undefined) {
      return reply.status(400).send({ error: 'h3Index, lat et lng sont requis' });
    }

    // Find or create the land
    let land = await prisma.land.findUnique({ where: { h3Index } });

    if (!land) {
      land = await prisma.land.create({
        data: {
          h3Index,
          lat,
          lng,
          city: city || 'Inconnu',
          country: country || 'Inconnu',
          status: 'LIBRE',
        },
      });
    }

    // Record exploration
    const existing = await prisma.landExploration.findFirst({
      where: { landId: land.id, playerCardId },
    });

    if (existing) {
      await prisma.landExploration.update({
        where: { id: existing.id },
        data: {
          visitCount: { increment: 1 },
          lastVisitedAt: new Date(),
        },
      });
    } else {
      await prisma.landExploration.create({
        data: {
          landId: land.id,
          playerCardId,
          visitCount: 1,
        },
      });
    }

    return reply.send({
      land: formatLand(land),
      explored: true,
    });
  });

  // ==================== GET LANDS AROUND POSITION ====================
  fastify.get('/nearby', {
    preValidation: [fastify.authenticate],
  }, async (request, reply) => {
    const { lat, lng, radius = 0.01 } = request.query;

    if (!lat || !lng) {
      return reply.status(400).send({ error: 'lat et lng sont requis' });
    }

    const latNum = parseFloat(lat);
    const lngNum = parseFloat(lng);
    const radiusNum = parseFloat(radius);

    // Simple bounding box query
    const lands = await prisma.land.findMany({
      where: {
        lat: { gte: latNum - radiusNum, lte: latNum + radiusNum },
        lng: { gte: lngNum - radiusNum, lte: lngNum + radiusNum },
      },
      include: {
        currentLease: { include: { player: { select: { username: true } } } },
        currentOwnership: { include: { player: { select: { username: true } } } },
      },
    });

    return reply.send({
      lands: lands.map(l => ({
        ...formatLand(l),
        tenant: l.currentLease ? l.currentLease.player.username : null,
        owner: l.currentOwnership ? l.currentOwnership.player.username : null,
      })),
    });
  });

  // ==================== RENT A LAND ====================
  fastify.post('/:landId/rent', {
    preValidation: [fastify.authenticate],
  }, async (request, reply) => {
    const { playerCardId } = request.user;
    const { landId } = request.params;

    const land = await prisma.land.findUnique({
      where: { id: landId },
      include: { currentLease: true },
    });

    if (!land) {
      return reply.status(404).send({ error: 'LAND introuvable' });
    }

    if (land.status !== 'LIBRE') {
      return reply.status(400).send({ error: 'Cette LAND n\'est pas libre' });
    }

    // Check if land was explored
    const exploration = await prisma.landExploration.findFirst({
      where: { landId: land.id, playerCardId },
    });

    if (!exploration) {
      return reply.status(400).send({ error: 'Tu dois d\'abord explorer cette LAND en courant dessus' });
    }

    // Check RPC balance
    const player = await prisma.playerCard.findUnique({ where: { id: playerCardId } });

    if (player.rpcBalance < RENT_COST_RPC) {
      return reply.status(400).send({
        error: 'Solde RPC insuffisant',
        required: RENT_COST_RPC,
        current: player.rpcBalance,
      });
    }

    // Grade-based land limits
    const maxLands = getMaxLands(player.grade);
    const currentLands = await prisma.landLease.count({
      where: { playerCardId, active: true },
    });

    if (currentLands >= maxLands) {
      return reply.status(400).send({
        error: `Limite de LANDs atteinte pour ton grade (${maxLands})`,
      });
    }

    // Process rental in a transaction
    const result = await prisma.$transaction(async (tx) => {
      // Deduct RPC
      await tx.playerCard.update({
        where: { id: playerCardId },
        data: { rpcBalance: { decrement: RENT_COST_RPC } },
      });

      // Record transaction
      await tx.transaction.create({
        data: {
          playerCardId,
          type: 'LAND_RENT',
          amountRpc: -RENT_COST_RPC,
          description: `Location de LAND ${land.h3Index} (${land.city})`,
        },
      });

      // Create lease
      const lease = await tx.landLease.create({
        data: {
          landId: land.id,
          playerCardId,
          monthlyRentRpc: RENT_COST_RPC,
          startDate: new Date(),
          active: true,
        },
      });

      // Update land status
      await tx.land.update({
        where: { id: land.id },
        data: { status: 'LOUEE' },
      });

      return lease;
    });

    return reply.status(201).send({
      message: `LAND ${land.h3Index} louée avec succès !`,
      lease: result,
      cost: RENT_COST_RPC,
    });
  });

  // ==================== BUY A LAND ====================
  fastify.post('/:landId/buy', {
    preValidation: [fastify.authenticate],
  }, async (request, reply) => {
    const { playerCardId } = request.user;
    const { landId } = request.params;

    const land = await prisma.land.findUnique({
      where: { id: landId },
      include: {
        currentLease: true,
        currentOwnership: true,
      },
    });

    if (!land) {
      return reply.status(404).send({ error: 'LAND introuvable' });
    }

    if (land.currentOwnership) {
      return reply.status(400).send({ error: 'Cette LAND est déjà achetée' });
    }

    // Must have rented for MIN_PERIODS_TO_BUY periods
    const lease = await prisma.landLease.findFirst({
      where: { landId: land.id, playerCardId, active: true },
    });

    if (!lease || lease.periodsHeld < MIN_PERIODS_TO_BUY) {
      return reply.status(400).send({
        error: `Tu dois louer cette LAND pendant au moins ${MIN_PERIODS_TO_BUY} périodes avant de pouvoir l'acheter`,
        currentPeriods: lease ? lease.periodsHeld : 0,
      });
    }

    // Calculate purchase price in OZI based on city tier
    const purchasePrice = calculatePurchasePrice(land);

    const player = await prisma.playerCard.findUnique({ where: { id: playerCardId } });

    if (player.oziBalance < purchasePrice) {
      return reply.status(400).send({
        error: 'Solde OZI insuffisant',
        required: purchasePrice,
        current: player.oziBalance,
      });
    }

    // Process purchase
    const result = await prisma.$transaction(async (tx) => {
      // Deduct OZI
      await tx.playerCard.update({
        where: { id: playerCardId },
        data: { oziBalance: { decrement: purchasePrice } },
      });

      // Record transaction
      await tx.transaction.create({
        data: {
          playerCardId,
          type: 'LAND_PURCHASE',
          amountOzi: -purchasePrice,
          description: `Achat de LAND ${land.h3Index} (${land.city})`,
        },
      });

      // End lease
      if (lease) {
        await tx.landLease.update({
          where: { id: lease.id },
          data: { active: false },
        });
      }

      // Create ownership
      const ownership = await tx.landOwnership.create({
        data: {
          landId: land.id,
          playerCardId,
          purchasePriceOzi: purchasePrice,
        },
      });

      // Update land status
      await tx.land.update({
        where: { id: land.id },
        data: { status: 'ACHETEE' },
      });

      return ownership;
    });

    return reply.status(201).send({
      message: `LAND ${land.h3Index} achetée avec succès !`,
      ownership: result,
      cost: purchasePrice,
    });
  });

  // ==================== GET MY LANDS ====================
  fastify.get('/mine', {
    preValidation: [fastify.authenticate],
  }, async (request, reply) => {
    const { playerCardId } = request.user;

    const [leases, ownerships, explorations] = await Promise.all([
      prisma.landLease.findMany({
        where: { playerCardId, active: true },
        include: { land: true },
      }),
      prisma.landOwnership.findMany({
        where: { playerCardId },
        include: { land: true },
      }),
      prisma.landExploration.findMany({
        where: { playerCardId },
        include: { land: true },
        orderBy: { lastVisitedAt: 'desc' },
        take: 20,
      }),
    ]);

    return reply.send({
      rented: leases.map(l => ({
        leaseId: l.id,
        land: formatLand(l.land),
        monthlyRent: l.monthlyRentRpc,
        periodsHeld: l.periodsHeld,
        startDate: l.startDate,
        canBuy: l.periodsHeld >= MIN_PERIODS_TO_BUY,
      })),
      owned: ownerships.map(o => ({
        ownershipId: o.id,
        land: formatLand(o.land),
        purchasePrice: o.purchasePriceOzi,
        periodsOwned: o.periodsOwned,
        totalRevenueRpc: o.totalRevenueRpc,
        totalRevenueOzi: o.totalRevenueOzi,
      })),
      explored: explorations.map(e => ({
        land: formatLand(e.land),
        visitCount: e.visitCount,
        lastVisitedAt: e.lastVisitedAt,
      })),
    });
  });

  // ==================== GET LAND DETAILS ====================
  fastify.get('/:landId', async (request, reply) => {
    const { landId } = request.params;

    const land = await prisma.land.findUnique({
      where: { id: landId },
      include: {
        currentLease: { include: { player: { select: { username: true, grade: true } } } },
        currentOwnership: { include: { player: { select: { username: true, grade: true } } } },
        explorations: {
          orderBy: { visitCount: 'desc' },
          take: 5,
          include: { player: { select: { username: true } } },
        },
      },
    });

    if (!land) {
      return reply.status(404).send({ error: 'LAND introuvable' });
    }

    return reply.send({
      ...formatLand(land),
      tenant: land.currentLease ? {
        username: land.currentLease.player.username,
        grade: land.currentLease.player.grade,
        periodsHeld: land.currentLease.periodsHeld,
      } : null,
      owner: land.currentOwnership ? {
        username: land.currentOwnership.player.username,
        grade: land.currentOwnership.player.grade,
      } : null,
      topExplorers: land.explorations.map(e => ({
        username: e.player.username,
        visitCount: e.visitCount,
      })),
      purchasePrice: calculatePurchasePrice(land),
      rentCost: RENT_COST_RPC,
    });
  });
}

function getMaxLands(grade) {
  const limits = {
    STARTER: 1,
    DEBUTANT: 3,
    CONFIRME: 5,
    EXPERT: 10,
    PRO: 20,
    ELITE: 50,
  };
  return limits[grade] || 1;
}

function calculatePurchasePrice(land) {
  // Base price in OZI, varies by location quality
  const BASE_PRICE = 100; // 100 OZI
  // In production, could use population density, POI count, etc.
  return BASE_PRICE;
}

function formatLand(land) {
  return {
    id: land.id,
    h3Index: land.h3Index,
    lat: land.lat,
    lng: land.lng,
    city: land.city,
    country: land.country,
    status: land.status,
  };
}

module.exports = landRoutes;
