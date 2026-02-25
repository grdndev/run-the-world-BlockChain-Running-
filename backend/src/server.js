require('dotenv').config();
const fastify = require('fastify')({ logger: true });
const cors = require('@fastify/cors');
const jwt = require('@fastify/jwt');
const cookie = require('@fastify/cookie');

// Plugins
fastify.register(cors, {
  origin: true,
  credentials: true,
});

fastify.register(jwt, {
  secret: process.env.JWT_SECRET || 'rtw-dev-secret',
  sign: { expiresIn: '15m' },
});

fastify.register(cookie);

// Auth decorator
fastify.decorate('authenticate', async function (request, reply) {
  try {
    await request.jwtVerify();
  } catch (err) {
    reply.status(401).send({ error: 'Non autorisé' });
  }
});

// Routes
fastify.register(require('./routes/auth'), { prefix: '/api/auth' });
fastify.register(require('./routes/player'), { prefix: '/api/players' });
fastify.register(require('./routes/league'), { prefix: '/api/leagues' });
fastify.register(require('./routes/land'), { prefix: '/api/lands' });
fastify.register(require('./routes/run'), { prefix: '/api/runs' });

// Health check
fastify.get('/api/health', async () => ({ status: 'ok', version: '1.0.0' }));

// Start
const start = async () => {
  try {
    const port = parseInt(process.env.PORT) || 3000;
    const host = process.env.HOST || '0.0.0.0';
    await fastify.listen({ port, host });
    console.log(`🏃 RTW Backend running on http://${host}:${port}`);
  } catch (err) {
    fastify.log.error(err);
    process.exit(1);
  }
};

start();
