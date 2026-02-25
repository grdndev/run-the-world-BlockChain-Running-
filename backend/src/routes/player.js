const prisma = require('../lib/prisma');

// Grade thresholds
const GRADE_REQUIREMENTS = {
  DEBUTANT: { periods: 2, rpc: 15000, pts: 500 },
  CONFIRME: { periods: 3, rpc: 20000, pts: 800 },
  EXPERT: { periods: 5, rpc: 500000, pts: 20000 },
  PRO: { periods: 6, rpc: 1000000, pts: 50000 },
  ELITE: { periods: 12, rpc: 5000000, pts: 100000 },
};

async function playerRoutes(fastify, options) {
  // ==================== GET MY PROFILE ====================
  fastify.get('/me', {
    preValidation: [fastify.authenticate],
  }, async (request, reply) => {
    const { playerCardId } = request.user;

    const playerCard = await prisma.playerCard.findUnique({
      where: { id: playerCardId },
      include: {
        user: { select: { email: true, kycVerified: true } },
        landLeases: { include: { land: true } },
        landOwnerships: { include: { land: true } },
        teamMembership: { include: { team: true } },
      },
    });

    if (!playerCard) {
      return reply.status(404).send({ error: 'Player Card introuvable' });
    }

    // Check grade eligibility
    const nextGrade = getNextGrade(playerCard.grade);
    let gradeProgress = null;
    if (nextGrade) {
      const req = GRADE_REQUIREMENTS[nextGrade];
      gradeProgress = {
        nextGrade,
        requirements: req,
        current: {
          periods: playerCard.periodsCompleted,
          rpc: playerCard.rpcBalance,
          pts: playerCard.totalPts,
        },
        eligible:
          playerCard.periodsCompleted >= req.periods &&
          playerCard.rpcBalance >= req.rpc &&
          playerCard.totalPts >= req.pts,
      };
    }

    return reply.send({
      ...formatPlayerCard(playerCard),
      email: playerCard.user.email,
      kycVerified: playerCard.user.kycVerified,
      gradeProgress,
      lands: {
        rented: playerCard.landLeases.length,
        owned: playerCard.landOwnerships.length,
        leases: playerCard.landLeases.map(l => ({
          landId: l.land.id,
          h3Index: l.land.h3Index,
          city: l.land.city,
          periodsHeld: l.periodsHeld,
          monthlyRent: l.monthlyRentRpc,
        })),
        ownerships: playerCard.landOwnerships.map(o => ({
          landId: o.land.id,
          h3Index: o.land.h3Index,
          city: o.land.city,
          purchasePrice: o.purchasePriceOzi,
          periodsOwned: o.periodsOwned,
        })),
      },
      team: playerCard.teamMembership ? {
        id: playerCard.teamMembership.team.id,
        name: playerCard.teamMembership.team.name,
        role: playerCard.teamMembership.role,
      } : null,
    });
  });

  // ==================== UPDATE PROFILE ====================
  fastify.patch('/me', {
    preValidation: [fastify.authenticate],
  }, async (request, reply) => {
    const { playerCardId } = request.user;
    const { username, nationality } = request.body;

    const updateData = {};
    if (username) {
      const existing = await prisma.playerCard.findUnique({ where: { username } });
      if (existing && existing.id !== playerCardId) {
        return reply.status(409).send({ error: 'Ce nom d\'utilisateur est déjà pris' });
      }
      updateData.username = username;
    }
    if (nationality) updateData.nationality = nationality;

    const updated = await prisma.playerCard.update({
      where: { id: playerCardId },
      data: updateData,
    });

    return reply.send(formatPlayerCard(updated));
  });

  // ==================== UPGRADE GRADE ====================
  fastify.post('/me/upgrade-grade', {
    preValidation: [fastify.authenticate],
  }, async (request, reply) => {
    const { playerCardId } = request.user;

    const playerCard = await prisma.playerCard.findUnique({
      where: { id: playerCardId },
    });

    const nextGrade = getNextGrade(playerCard.grade);
    if (!nextGrade) {
      return reply.status(400).send({ error: 'Tu es déjà au grade maximum' });
    }

    const req = GRADE_REQUIREMENTS[nextGrade];
    if (
      playerCard.periodsCompleted < req.periods ||
      playerCard.rpcBalance < req.rpc ||
      playerCard.totalPts < req.pts
    ) {
      return reply.status(400).send({
        error: 'Conditions non remplies pour le grade suivant',
        requirements: req,
        current: {
          periods: playerCard.periodsCompleted,
          rpc: playerCard.rpcBalance,
          pts: playerCard.totalPts,
        },
      });
    }

    const updated = await prisma.playerCard.update({
      where: { id: playerCardId },
      data: { grade: nextGrade },
    });

    return reply.send({
      message: `Félicitations ! Tu es maintenant ${nextGrade}`,
      playerCard: formatPlayerCard(updated),
    });
  });

  // ==================== GET PLAYER BY USERNAME ====================
  fastify.get('/:username', async (request, reply) => {
    const { username } = request.params;

    const playerCard = await prisma.playerCard.findUnique({
      where: { username },
    });

    if (!playerCard) {
      return reply.status(404).send({ error: 'Joueur introuvable' });
    }

    return reply.send({
      username: playerCard.username,
      grade: playerCard.grade,
      totalPts: playerCard.totalPts,
      totalKm: playerCard.totalKm,
      nationality: playerCard.nationality,
      leagueNumber: playerCard.leagueNumber,
      leagueRank: playerCard.leagueRank,
    });
  });
}

function getNextGrade(currentGrade) {
  const order = ['STARTER', 'DEBUTANT', 'CONFIRME', 'EXPERT', 'PRO', 'ELITE'];
  const idx = order.indexOf(currentGrade);
  return idx < order.length - 1 ? order[idx + 1] : null;
}

function formatPlayerCard(pc) {
  return {
    id: pc.id,
    username: pc.username,
    grade: pc.grade,
    nationality: pc.nationality,
    rpcBalance: pc.rpcBalance,
    oziBalance: pc.oziBalance,
    totalPts: pc.totalPts,
    totalKm: pc.totalKm,
    currentPeriodPts: pc.currentPeriodPts,
    leagueNumber: pc.leagueNumber,
    leagueRank: pc.leagueRank,
    idValidUntil: pc.idValidUntil,
    idActive: pc.idActive,
    periodsCompleted: pc.periodsCompleted,
    boostsUsedThisPeriod: pc.boostsUsedThisPeriod,
    freeBoostUsed: pc.freeBoostUsed,
    consecutiveLoginDays: pc.consecutiveLoginDays,
    eosAccountName: pc.eosAccountName,
  };
}

module.exports = playerRoutes;
