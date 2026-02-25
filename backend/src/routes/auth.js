const bcrypt = require('bcryptjs');
const prisma = require('../lib/prisma');

async function authRoutes(fastify, options) {
  // ==================== REGISTER ====================
  fastify.post('/register', {
    schema: {
      body: {
        type: 'object',
        required: ['email', 'password', 'username'],
        properties: {
          email: { type: 'string', format: 'email' },
          password: { type: 'string', minLength: 6 },
          username: { type: 'string', minLength: 3, maxLength: 20 },
        },
      },
    },
  }, async (request, reply) => {
    const { email, password, username } = request.body;

    // Check if user/username already exists
    const existingUser = await prisma.user.findUnique({ where: { email } });
    if (existingUser) {
      return reply.status(409).send({ error: 'Cet email est déjà utilisé' });
    }

    const existingUsername = await prisma.playerCard.findUnique({
      where: { username },
    });
    if (existingUsername) {
      return reply.status(409).send({ error: 'Ce nom d\'utilisateur est déjà pris' });
    }

    // Hash password
    const passwordHash = await bcrypt.hash(password, 12);

    // Calculate ID validity (10 days from now)
    const idValidUntil = new Date();
    idValidUntil.setDate(idValidUntil.getDate() + 10);

    // Create user + player card in transaction
    const user = await prisma.user.create({
      data: {
        email,
        passwordHash,
        playerCard: {
          create: {
            username,
            idValidUntil,
            rpcBalance: 5000, // Signup bonus
          },
        },
      },
      include: { playerCard: true },
    });

    // Record signup bonus transaction
    await prisma.transaction.create({
      data: {
        playerCardId: user.playerCard.id,
        type: 'SIGNUP_BONUS',
        amountRpc: 5000,
        description: 'Bonus d\'inscription',
      },
    });

    // Generate tokens
    const accessToken = fastify.jwt.sign(
      { userId: user.id, playerCardId: user.playerCard.id },
      { expiresIn: '15m' }
    );
    const refreshToken = fastify.jwt.sign(
      { userId: user.id, type: 'refresh' },
      { expiresIn: '7d' }
    );

    return reply.status(201).send({
      accessToken,
      refreshToken,
      user: {
        id: user.id,
        email: user.email,
        playerCard: {
          id: user.playerCard.id,
          username: user.playerCard.username,
          grade: user.playerCard.grade,
          rpcBalance: user.playerCard.rpcBalance,
          oziBalance: user.playerCard.oziBalance,
          totalPts: user.playerCard.totalPts,
          totalKm: user.playerCard.totalKm,
          idValidUntil: user.playerCard.idValidUntil,
          nationality: user.playerCard.nationality,
        },
      },
    });
  });

  // ==================== LOGIN ====================
  fastify.post('/login', {
    schema: {
      body: {
        type: 'object',
        required: ['email', 'password'],
        properties: {
          email: { type: 'string', format: 'email' },
          password: { type: 'string' },
        },
      },
    },
  }, async (request, reply) => {
    const { email, password } = request.body;

    const user = await prisma.user.findUnique({
      where: { email },
      include: { playerCard: true },
    });

    if (!user) {
      return reply.status(401).send({ error: 'Email ou mot de passe incorrect' });
    }

    const validPassword = await bcrypt.compare(password, user.passwordHash);
    if (!validPassword) {
      return reply.status(401).send({ error: 'Email ou mot de passe incorrect' });
    }

    // Check if ID is expired
    const now = new Date();
    const idExpired = user.playerCard && new Date(user.playerCard.idValidUntil) < now;

    // Update last login
    if (user.playerCard) {
      const lastLogin = user.playerCard.lastLoginDate;
      const today = new Date().toDateString();
      const wasYesterday = lastLogin && 
        new Date(new Date(lastLogin).getTime() + 86400000).toDateString() === today;

      await prisma.playerCard.update({
        where: { id: user.playerCard.id },
        data: {
          lastLoginDate: now,
          consecutiveLoginDays: wasYesterday
            ? user.playerCard.consecutiveLoginDays + 1
            : 1,
        },
      });

      // Daily login bonus (50 RPC/day for 10 days)
      if (user.playerCard.consecutiveLoginDays < 10) {
        await prisma.playerCard.update({
          where: { id: user.playerCard.id },
          data: { rpcBalance: { increment: 50 } },
        });
        await prisma.transaction.create({
          data: {
            playerCardId: user.playerCard.id,
            type: 'DAILY_LOGIN',
            amountRpc: 50,
            description: `Bonus connexion jour ${user.playerCard.consecutiveLoginDays + 1}`,
          },
        });
      }
    }

    // Generate tokens
    const accessToken = fastify.jwt.sign(
      { userId: user.id, playerCardId: user.playerCard?.id },
      { expiresIn: '15m' }
    );
    const refreshToken = fastify.jwt.sign(
      { userId: user.id, type: 'refresh' },
      { expiresIn: '7d' }
    );

    return reply.send({
      accessToken,
      refreshToken,
      user: {
        id: user.id,
        email: user.email,
        playerCard: user.playerCard ? {
          id: user.playerCard.id,
          username: user.playerCard.username,
          grade: user.playerCard.grade,
          rpcBalance: user.playerCard.rpcBalance,
          oziBalance: user.playerCard.oziBalance,
          totalPts: user.playerCard.totalPts,
          totalKm: user.playerCard.totalKm,
          leagueNumber: user.playerCard.leagueNumber,
          leagueRank: user.playerCard.leagueRank,
          idValidUntil: user.playerCard.idValidUntil,
          idActive: user.playerCard.idActive,
          idExpired,
          nationality: user.playerCard.nationality,
          periodsCompleted: user.playerCard.periodsCompleted,
          consecutiveLoginDays: user.playerCard.consecutiveLoginDays,
        } : null,
      },
    });
  });

  // ==================== REFRESH TOKEN ====================
  fastify.post('/refresh', async (request, reply) => {
    const { refreshToken } = request.body;

    if (!refreshToken) {
      return reply.status(400).send({ error: 'Refresh token requis' });
    }

    try {
      const decoded = fastify.jwt.verify(refreshToken);
      if (decoded.type !== 'refresh') {
        return reply.status(401).send({ error: 'Token invalide' });
      }

      const user = await prisma.user.findUnique({
        where: { id: decoded.userId },
        include: { playerCard: true },
      });

      if (!user) {
        return reply.status(401).send({ error: 'Utilisateur introuvable' });
      }

      const newAccessToken = fastify.jwt.sign(
        { userId: user.id, playerCardId: user.playerCard?.id },
        { expiresIn: '15m' }
      );

      return reply.send({ accessToken: newAccessToken });
    } catch (err) {
      return reply.status(401).send({ error: 'Refresh token expiré' });
    }
  });

  // ==================== FORGOT PASSWORD ====================
  fastify.post('/forgot-password', {
    schema: {
      body: {
        type: 'object',
        required: ['email'],
        properties: {
          email: { type: 'string', format: 'email' },
        },
      },
    },
  }, async (request, reply) => {
    const { email } = request.body;

    // Always return success to prevent email enumeration
    const user = await prisma.user.findUnique({ where: { email } });
    
    if (user) {
      // TODO: Send password reset email
      // For now, just log it
      console.log(`Password reset requested for: ${email}`);
    }

    return reply.send({
      message: 'Si un compte existe avec cet email, un lien de réinitialisation a été envoyé.',
    });
  });

  // ==================== RENEW ID ====================
  fastify.post('/renew-id', {
    preValidation: [fastify.authenticate],
  }, async (request, reply) => {
    const { playerCardId } = request.user;

    const idValidUntil = new Date();
    idValidUntil.setDate(idValidUntil.getDate() + 10);

    await prisma.playerCard.update({
      where: { id: playerCardId },
      data: { idValidUntil, idActive: true },
    });

    return reply.send({
      message: 'ID renouvelé avec succès',
      idValidUntil,
    });
  });
}

module.exports = authRoutes;
