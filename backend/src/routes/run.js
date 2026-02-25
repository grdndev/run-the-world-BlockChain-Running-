const prisma = require('../lib/prisma');

// Points calculation from whitepaper
// BASE_PTS = distance_km * grade_multiplier
// BONUS_PTS = land_traversed * 10
// With boost: PTS * 1.5 (15min free boost) or PTS * 2 (paid boost)

const GRADE_MULTIPLIERS = {
  STARTER: 10,
  DEBUTANT: 12,
  CONFIRME: 15,
  EXPERT: 20,
  PRO: 25,
  ELITE: 30,
};

// RPC earned per km
const RPC_PER_KM = 100; // 100 RPC ~= 0.01€

// Anti-cheat limits
const MAX_SPEED_KMH = 20; // Max running speed
const MIN_SPEED_KMH = 1;  // Must be moving (not standing)
const MAX_RUN_DURATION_HOURS = 5;

async function runRoutes(fastify, options) {
  // ==================== START A RUN ====================
  fastify.post('/start', {
    preValidation: [fastify.authenticate],
  }, async (request, reply) => {
    const { playerCardId } = request.user;
    const { lat, lng } = request.body;

    // Check player has active ID
    const player = await prisma.playerCard.findUnique({
      where: { id: playerCardId },
    });

    if (!player.idActive) {
      return reply.status(400).send({ error: 'Ton ID a expiré. Renouvelle-le pour courir.' });
    }

    if (new Date(player.idValidUntil) < new Date()) {
      await prisma.playerCard.update({
        where: { id: playerCardId },
        data: { idActive: false },
      });
      return reply.status(400).send({ error: 'Ton ID a expiré. Renouvelle-le pour courir.' });
    }

    // Check no active run
    const activeRun = await prisma.run.findFirst({
      where: { playerCardId, endTime: null },
    });

    if (activeRun) {
      return reply.status(400).send({
        error: 'Tu as déjà une course en cours',
        runId: activeRun.id,
      });
    }

    const run = await prisma.run.create({
      data: {
        playerCardId,
        startLat: lat || 0,
        startLng: lng || 0,
        gpsTrace: JSON.stringify([{ lat, lng, t: Date.now() }]),
      },
    });

    return reply.status(201).send({
      runId: run.id,
      startTime: run.startTime,
      message: 'Course démarrée ! Bonne course 🏃',
    });
  });

  // ==================== UPDATE GPS TRACE (periodic) ====================
  fastify.patch('/:runId/trace', {
    preValidation: [fastify.authenticate],
  }, async (request, reply) => {
    const { playerCardId } = request.user;
    const { runId } = request.params;
    const { points } = request.body; // Array of {lat, lng, t}

    const run = await prisma.run.findFirst({
      where: { id: runId, playerCardId, endTime: null },
    });

    if (!run) {
      return reply.status(404).send({ error: 'Course introuvable ou déjà terminée' });
    }

    // Append GPS points
    const existingTrace = JSON.parse(run.gpsTrace || '[]');
    const newTrace = [...existingTrace, ...points];

    // Calculate current distance
    const distance = calculateDistance(newTrace);

    await prisma.run.update({
      where: { id: runId },
      data: {
        gpsTrace: JSON.stringify(newTrace),
        distanceKm: distance,
      },
    });

    return reply.send({
      runId,
      currentDistance: distance,
      pointsCount: newTrace.length,
    });
  });

  // ==================== END A RUN ====================
  fastify.post('/:runId/end', {
    preValidation: [fastify.authenticate],
  }, async (request, reply) => {
    const { playerCardId } = request.user;
    const { runId } = request.params;
    const { h3Indexes = [] } = request.body; // H3 indexes of lands traversed

    const run = await prisma.run.findFirst({
      where: { id: runId, playerCardId, endTime: null },
    });

    if (!run) {
      return reply.status(404).send({ error: 'Course introuvable ou déjà terminée' });
    }

    const player = await prisma.playerCard.findUnique({
      where: { id: playerCardId },
    });

    const gpsTrace = JSON.parse(run.gpsTrace || '[]');
    const distance = calculateDistance(gpsTrace);
    const durationMs = Date.now() - new Date(run.startTime).getTime();
    const durationHours = durationMs / (1000 * 60 * 60);

    // Anti-cheat checks
    const avgSpeed = distance / durationHours;
    let antiCheatFlag = false;
    let antiCheatReason = null;

    if (avgSpeed > MAX_SPEED_KMH) {
      antiCheatFlag = true;
      antiCheatReason = `Vitesse suspecte: ${avgSpeed.toFixed(1)} km/h`;
    }
    if (durationHours > MAX_RUN_DURATION_HOURS) {
      antiCheatFlag = true;
      antiCheatReason = `Durée suspecte: ${durationHours.toFixed(1)}h`;
    }
    if (distance > 0 && avgSpeed < MIN_SPEED_KMH) {
      antiCheatFlag = true;
      antiCheatReason = `Vitesse trop faible: ${avgSpeed.toFixed(1)} km/h`;
    }

    // Calculate points
    const gradeMultiplier = GRADE_MULTIPLIERS[player.grade] || 10;
    const basePts = Math.floor(distance * gradeMultiplier);
    const landBonus = h3Indexes.length * 10;
    let totalPts = basePts + landBonus;

    // Check for active boost
    const activeBoost = await prisma.boost.findFirst({
      where: {
        playerCardId,
        active: true,
        expiresAt: { gt: new Date() },
      },
    });

    let boostMultiplier = 1;
    if (activeBoost) {
      boostMultiplier = activeBoost.type === 'FREE' ? 1.5 : 2;
      // Deactivate if expired
      if (new Date(activeBoost.expiresAt) <= new Date()) {
        await prisma.boost.update({
          where: { id: activeBoost.id },
          data: { active: false },
        });
        boostMultiplier = 1;
      }
    }

    totalPts = Math.floor(totalPts * boostMultiplier);

    // Calculate RPC earned
    const rpcEarned = Math.floor(distance * RPC_PER_KM);

    // If anti-cheat flagged, reduce rewards / mark for review
    if (antiCheatFlag) {
      totalPts = 0;
    }

    // Update everything in a transaction
    const result = await prisma.$transaction(async (tx) => {
      // End the run
      const endedRun = await tx.run.update({
        where: { id: runId },
        data: {
          endTime: new Date(),
          distanceKm: distance,
          durationMinutes: Math.floor(durationMs / 60000),
          ptsEarned: totalPts,
          rpcEarned,
          landsTraversed: h3Indexes.length,
          avgSpeedKmh: avgSpeed,
          antiCheatFlag,
          antiCheatReason,
        },
      });

      if (!antiCheatFlag) {
        // Update player stats
        await tx.playerCard.update({
          where: { id: playerCardId },
          data: {
            totalPts: { increment: totalPts },
            currentPeriodPts: { increment: totalPts },
            totalKm: { increment: distance },
            rpcBalance: { increment: rpcEarned },
          },
        });

        // Record RPC transaction
        if (rpcEarned > 0) {
          await tx.transaction.create({
            data: {
              playerCardId,
              type: 'RUN_REWARD',
              amountRpc: rpcEarned,
              description: `Course: ${distance.toFixed(2)}km, ${totalPts} PTS`,
            },
          });
        }

        // Record land explorations
        for (const h3Index of h3Indexes) {
          let land = await tx.land.findUnique({ where: { h3Index } });
          if (land) {
            const exploration = await tx.landExploration.findFirst({
              where: { landId: land.id, playerCardId },
            });
            if (exploration) {
              await tx.landExploration.update({
                where: { id: exploration.id },
                data: {
                  visitCount: { increment: 1 },
                  lastVisitedAt: new Date(),
                },
              });
            } else {
              await tx.landExploration.create({
                data: { landId: land.id, playerCardId, visitCount: 1 },
              });
            }
          }
        }
      }

      return endedRun;
    });

    return reply.send({
      summary: {
        runId: result.id,
        distance: distance.toFixed(2),
        duration: `${Math.floor(durationMs / 60000)} min`,
        avgSpeed: `${avgSpeed.toFixed(1)} km/h`,
        ptsEarned: totalPts,
        rpcEarned,
        landsTraversed: h3Indexes.length,
        boostMultiplier,
        antiCheatFlag,
        antiCheatReason,
      },
      message: antiCheatFlag
        ? '⚠️ Course suspecte détectée. Aucune récompense.'
        : `Bravo ! +${totalPts} PTS, +${rpcEarned} RPC`,
    });
  });

  // ==================== GET RUN HISTORY ====================
  fastify.get('/history', {
    preValidation: [fastify.authenticate],
  }, async (request, reply) => {
    const { playerCardId } = request.user;
    const { limit = 20, offset = 0 } = request.query;

    const runs = await prisma.run.findMany({
      where: { playerCardId, endTime: { not: null } },
      orderBy: { startTime: 'desc' },
      take: parseInt(limit),
      skip: parseInt(offset),
      select: {
        id: true,
        startTime: true,
        endTime: true,
        distanceKm: true,
        durationMinutes: true,
        ptsEarned: true,
        rpcEarned: true,
        landsTraversed: true,
        avgSpeedKmh: true,
        antiCheatFlag: true,
      },
    });

    const total = await prisma.run.count({
      where: { playerCardId, endTime: { not: null } },
    });

    return reply.send({ runs, total, limit: parseInt(limit), offset: parseInt(offset) });
  });

  // ==================== GET ACTIVE RUN ====================
  fastify.get('/active', {
    preValidation: [fastify.authenticate],
  }, async (request, reply) => {
    const { playerCardId } = request.user;

    const run = await prisma.run.findFirst({
      where: { playerCardId, endTime: null },
    });

    if (!run) {
      return reply.send({ active: false });
    }

    const gpsTrace = JSON.parse(run.gpsTrace || '[]');
    const currentDistance = calculateDistance(gpsTrace);

    return reply.send({
      active: true,
      runId: run.id,
      startTime: run.startTime,
      currentDistance,
      pointsCount: gpsTrace.length,
    });
  });

  // ==================== ACTIVATE BOOST ====================
  fastify.post('/boost', {
    preValidation: [fastify.authenticate],
  }, async (request, reply) => {
    const { playerCardId } = request.user;
    const { type = 'FREE' } = request.body; // FREE or PAID

    const player = await prisma.playerCard.findUnique({
      where: { id: playerCardId },
    });

    if (type === 'FREE') {
      if (player.freeBoostUsed) {
        return reply.status(400).send({ error: 'Boost gratuit déjà utilisé cette période' });
      }

      const boost = await prisma.boost.create({
        data: {
          playerCardId,
          type: 'FREE',
          multiplier: 1.5,
          durationMinutes: 15,
          expiresAt: new Date(Date.now() + 15 * 60 * 1000),
          active: true,
        },
      });

      await prisma.playerCard.update({
        where: { id: playerCardId },
        data: { freeBoostUsed: true },
      });

      return reply.send({
        message: 'Boost gratuit activé ! x1.5 pendant 15 minutes',
        boost,
      });
    }

    if (type === 'PAID') {
      const BOOST_COST = 2000; // 2000 RPC
      const MAX_BOOSTS_PER_PERIOD = 3;

      if (player.boostsUsedThisPeriod >= MAX_BOOSTS_PER_PERIOD) {
        return reply.status(400).send({ error: `Maximum ${MAX_BOOSTS_PER_PERIOD} boosts payants par période` });
      }

      if (player.rpcBalance < BOOST_COST) {
        return reply.status(400).send({ error: 'Solde RPC insuffisant', required: BOOST_COST });
      }

      const [boost] = await prisma.$transaction([
        prisma.boost.create({
          data: {
            playerCardId,
            type: 'PAID',
            multiplier: 2,
            durationMinutes: 30,
            expiresAt: new Date(Date.now() + 30 * 60 * 1000),
            active: true,
          },
        }),
        prisma.playerCard.update({
          where: { id: playerCardId },
          data: {
            rpcBalance: { decrement: BOOST_COST },
            boostsUsedThisPeriod: { increment: 1 },
          },
        }),
        prisma.transaction.create({
          data: {
            playerCardId,
            type: 'BOOST_PURCHASE',
            amountRpc: -BOOST_COST,
            description: 'Boost payant x2 - 30min',
          },
        }),
      ]);

      return reply.send({
        message: 'Boost payant activé ! x2 pendant 30 minutes',
        boost,
      });
    }

    return reply.status(400).send({ error: 'Type de boost invalide (FREE ou PAID)' });
  });
}

// ==================== HELPERS ====================

function calculateDistance(points) {
  if (points.length < 2) return 0;

  let total = 0;
  for (let i = 1; i < points.length; i++) {
    total += haversine(
      points[i - 1].lat, points[i - 1].lng,
      points[i].lat, points[i].lng
    );
  }
  return total;
}

function haversine(lat1, lon1, lat2, lon2) {
  const R = 6371; // Earth radius in km
  const dLat = toRad(lat2 - lat1);
  const dLon = toRad(lon2 - lon1);
  const a =
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos(toRad(lat1)) * Math.cos(toRad(lat2)) *
    Math.sin(dLon / 2) * Math.sin(dLon / 2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  return R * c;
}

function toRad(deg) {
  return deg * (Math.PI / 180);
}

module.exports = runRoutes;
