const prisma = require('../lib/prisma');

async function leagueRoutes(fastify, options) {
  // ==================== GET CURRENT LEAGUE RANKING ====================
  fastify.get('/ranking', {
    preValidation: [fastify.authenticate],
  }, async (request, reply) => {
    const { playerCardId } = request.user;
    const { leagueNumber } = request.query;

    const player = await prisma.playerCard.findUnique({
      where: { id: playerCardId },
    });

    const targetLeague = leagueNumber ? parseInt(leagueNumber) : player.leagueNumber;

    // Get all players in this league, ordered by points
    const players = await prisma.playerCard.findMany({
      where: { leagueNumber: targetLeague },
      orderBy: { currentPeriodPts: 'desc' },
      select: {
        id: true,
        username: true,
        grade: true,
        nationality: true,
        currentPeriodPts: true,
        totalKm: true,
        leagueRank: true,
      },
    });

    // Find current player's rank
    const myRank = players.findIndex(p => p.id === playerCardId) + 1;

    return reply.send({
      leagueNumber: targetLeague,
      totalPlayers: players.length,
      myRank,
      players: players.map((p, idx) => ({
        rank: idx + 1,
        ...p,
        isMe: p.id === playerCardId,
      })),
    });
  });

  // ==================== GET LEAGUE INFO ====================
  fastify.get('/:leagueNumber', async (request, reply) => {
    const leagueNumber = parseInt(request.params.leagueNumber);

    if (leagueNumber < 1 || leagueNumber > 10) {
      return reply.status(400).send({ error: 'Ligue invalide (1-10)' });
    }

    const league = await prisma.league.findFirst({
      where: { number: leagueNumber },
    });

    const playerCount = await prisma.playerCard.count({
      where: { leagueNumber },
    });

    // Point thresholds per league
    const LEAGUE_THRESHOLDS = {
      1: { min: 0, max: 99, name: 'Ligue 1 - Bronze' },
      2: { min: 100, max: 299, name: 'Ligue 2 - Argent' },
      3: { min: 300, max: 599, name: 'Ligue 3 - Or' },
      4: { min: 600, max: 999, name: 'Ligue 4 - Platine' },
      5: { min: 1000, max: 1999, name: 'Ligue 5 - Diamant' },
      6: { min: 2000, max: 3999, name: 'Ligue 6 - Maître' },
      7: { min: 4000, max: 7999, name: 'Ligue 7 - Grand Maître' },
      8: { min: 8000, max: 14999, name: 'Ligue 8 - Champion' },
      9: { min: 15000, max: 29999, name: 'Ligue 9 - Légende' },
      10: { min: 30000, max: Infinity, name: 'Ligue 10 - Mythique' },
    };

    const threshold = LEAGUE_THRESHOLDS[leagueNumber];

    return reply.send({
      number: leagueNumber,
      name: threshold.name,
      minPoints: threshold.min,
      maxPoints: threshold.max === Infinity ? null : threshold.max,
      playerCount,
      league: league || null,
    });
  });

  // ==================== GET GLOBAL RANKING (top players) ====================
  fastify.get('/global/top', async (request, reply) => {
    const { limit = 50 } = request.query;

    const players = await prisma.playerCard.findMany({
      orderBy: { totalPts: 'desc' },
      take: Math.min(parseInt(limit), 100),
      select: {
        id: true,
        username: true,
        grade: true,
        nationality: true,
        totalPts: true,
        totalKm: true,
        leagueNumber: true,
      },
    });

    return reply.send({
      ranking: players.map((p, idx) => ({
        rank: idx + 1,
        ...p,
      })),
    });
  });

  // ==================== END OF PERIOD — LEAGUE PROMOTIONS ====================
  // This would typically be a cron job, but exposed as admin endpoint
  fastify.post('/admin/end-period', {
    preValidation: [fastify.authenticate],
  }, async (request, reply) => {
    // In production, check admin role here
    // For now, process league promotions/demotions

    const leagues = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

    const results = {
      promotions: 0,
      demotions: 0,
      maintained: 0,
    };

    for (const leagueNum of leagues) {
      const players = await prisma.playerCard.findMany({
        where: { leagueNumber: leagueNum },
        orderBy: { currentPeriodPts: 'desc' },
      });

      const total = players.length;
      if (total === 0) continue;

      // Top 30% promoted (if not already in L10)
      const promoteCount = Math.floor(total * 0.3);
      // Bottom 30% demoted (if not already in L1)
      const demoteCount = Math.floor(total * 0.3);

      for (let i = 0; i < players.length; i++) {
        const player = players[i];
        let newLeague = leagueNum;

        if (i < promoteCount && leagueNum < 10) {
          newLeague = leagueNum + 1;
          results.promotions++;
        } else if (i >= total - demoteCount && leagueNum > 1) {
          newLeague = leagueNum - 1;
          results.demotions++;
        } else {
          results.maintained++;
        }

        await prisma.playerCard.update({
          where: { id: player.id },
          data: {
            leagueNumber: newLeague,
            leagueRank: i + 1,
            currentPeriodPts: 0, // Reset for new period
            periodsCompleted: { increment: 1 },
            boostsUsedThisPeriod: 0,
            freeBoostUsed: false,
          },
        });
      }
    }

    // Create new period record
    await prisma.period.create({
      data: {
        number: await prisma.period.count() + 1,
        startDate: new Date(),
        endDate: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000), // 30 days
      },
    });

    return reply.send({
      message: 'Fin de période traitée',
      results,
    });
  });

  // ==================== TEAM ROUTES ====================
  fastify.post('/teams', {
    preValidation: [fastify.authenticate],
  }, async (request, reply) => {
    const { playerCardId } = request.user;
    const { name } = request.body;

    if (!name || name.length < 3) {
      return reply.status(400).send({ error: 'Nom d\'équipe trop court (min 3 caractères)' });
    }

    // Check player not already in a team
    const existingMembership = await prisma.teamMember.findFirst({
      where: { playerCardId },
    });

    if (existingMembership) {
      return reply.status(400).send({ error: 'Tu fais déjà partie d\'une équipe' });
    }

    const team = await prisma.team.create({
      data: {
        name,
        members: {
          create: {
            playerCardId,
            role: 'CAPTAIN',
          },
        },
      },
      include: { members: { include: { player: true } } },
    });

    return reply.status(201).send(team);
  });

  fastify.post('/teams/:teamId/join', {
    preValidation: [fastify.authenticate],
  }, async (request, reply) => {
    const { playerCardId } = request.user;
    const { teamId } = request.params;

    const team = await prisma.team.findUnique({
      where: { id: teamId },
      include: { members: true },
    });

    if (!team) {
      return reply.status(404).send({ error: 'Équipe introuvable' });
    }

    if (team.members.length >= 5) {
      return reply.status(400).send({ error: 'Équipe complète (max 5 joueurs)' });
    }

    const existingMembership = await prisma.teamMember.findFirst({
      where: { playerCardId },
    });

    if (existingMembership) {
      return reply.status(400).send({ error: 'Tu fais déjà partie d\'une équipe' });
    }

    await prisma.teamMember.create({
      data: {
        teamId,
        playerCardId,
        role: 'MEMBER',
      },
    });

    return reply.send({ message: `Tu as rejoint l'équipe ${team.name}` });
  });
}

module.exports = leagueRoutes;
