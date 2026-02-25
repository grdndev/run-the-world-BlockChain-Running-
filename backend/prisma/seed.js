require('dotenv').config({ path: require('path').join(__dirname, '../.env') });
const { PrismaClient } = require('../generated/prisma');
const bcrypt = require('bcryptjs');

const prisma = new PrismaClient();

async function seed() {
  console.log('🌱 Seeding database...');

  // Create leagues
  const leagueData = [
    { number: 1,  name: 'Ligue 1 - Bronze',       minPts: 0,     maxPts: 99 },
    { number: 2,  name: 'Ligue 2 - Argent',        minPts: 100,   maxPts: 299 },
    { number: 3,  name: 'Ligue 3 - Or',            minPts: 300,   maxPts: 599 },
    { number: 4,  name: 'Ligue 4 - Platine',       minPts: 600,   maxPts: 999 },
    { number: 5,  name: 'Ligue 5 - Diamant',       minPts: 1000,  maxPts: 1999 },
    { number: 6,  name: 'Ligue 6 - Maître',        minPts: 2000,  maxPts: 3999 },
    { number: 7,  name: 'Ligue 7 - Grand Maître',  minPts: 4000,  maxPts: 7999 },
    { number: 8,  name: 'Ligue 8 - Champion',      minPts: 8000,  maxPts: 14999 },
    { number: 9,  name: 'Ligue 9 - Légende',       minPts: 15000, maxPts: 29999 },
    { number: 10, name: 'Ligue 10 - Mythique',     minPts: 30000, maxPts: 9999999 },
  ];

  for (const league of leagueData) {
    await prisma.league.upsert({
      where: { number: league.number },
      update: league,
      create: league,
    });
  }
  console.log('✅ Leagues created');

  // Create initial period
  await prisma.period.upsert({
    where: { number: 1 },
    update: {},
    create: {
      number: 1,
      startDate: new Date(),
      endDate: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000),
    },
  });
  console.log('✅ Period 1 created');

  // Create a test user
  const hashedPassword = await bcrypt.hash('test123', 12);
  const testUser = await prisma.user.upsert({
    where: { email: 'test@rtw.com' },
    update: {},
    create: {
      email: 'test@rtw.com',
      passwordHash: hashedPassword,
    },
  });

  await prisma.playerCard.upsert({
    where: { userId: testUser.id },
    update: {},
    create: {
      userId: testUser.id,
      username: 'TestRunner',
      grade: 'STARTER',
      nationality: 'FR',
      rpcBalance: 5000,
      oziBalance: 0,
      totalPts: 0,
      totalKm: 0,
      leagueNumber: 1,
      idValidUntil: new Date(Date.now() + 10 * 24 * 60 * 60 * 1000),
      idActive: true,
    },
  });
  console.log('✅ Test user created (test@rtw.com / test123)');

  // Create some sample lands (Paris area)
  const sampleLands = [
    { h3Index: '891f1d481a3ffff', lat: 48.8566, lng: 2.3522, city: 'Paris', country: 'FR' },
    { h3Index: '891f1d481a7ffff', lat: 48.8580, lng: 2.3540, city: 'Paris', country: 'FR' },
    { h3Index: '891f1d481abffff', lat: 48.8550, lng: 2.3500, city: 'Paris', country: 'FR' },
    { h3Index: '891f1d481afffff', lat: 48.8590, lng: 2.3560, city: 'Paris', country: 'FR' },
    { h3Index: '891f1d4818fffff', lat: 48.8545, lng: 2.3480, city: 'Paris', country: 'FR' },
  ];

  for (const land of sampleLands) {
    await prisma.land.upsert({
      where: { h3Index: land.h3Index },
      update: {},
      create: {
        ...land,
        status: 'LIBRE',
      },
    });
  }
  console.log('✅ Sample lands created');

  console.log('🎉 Seeding complete!');
}

seed()
  .catch((e) => {
    console.error('❌ Seed error:', e);
    process.exit(1);
  })
  .finally(() => prisma.$disconnect());
