// ============================================================
// CricketPass - Automatic Database Setup Script
// Run: node setup_db.js
// ============================================================
 
const { Client } = require('pg');
const fs         = require('fs');
const path       = require('path');
 
// Your database password
const PASSWORD   = 'Fathee@5026';
const DB_NAME    = 'cricketpass';
const MATCH_IDS  = [
  'bbbbbbbb-0001-0001-0001-000000000001',
  'bbbbbbbb-0002-0002-0002-000000000002',
  'bbbbbbbb-0003-0003-0003-000000000003',
  'bbbbbbbb-0004-0004-0004-000000000004',
  'bbbbbbbb-0005-0005-0005-000000000005',
  'bbbbbbbb-0006-0006-0006-000000000006',
  'bbbbbbbb-0007-0007-0007-000000000007',
  'bbbbbbbb-0008-0008-0008-000000000008',
];
 
const log  = (msg) => console.log(`  ${msg}`);
const ok   = (msg) => console.log(`  ✅ ${msg}`);
const err  = (msg) => console.log(`  ❌ ${msg}`);
const info = (msg) => console.log(`\n━━━ ${msg} ━━━`);
 
async function run() {
  console.log('\n╔════════════════════════════════════════╗');
  console.log('║   CricketPass Database Setup           ║');
  console.log('╚════════════════════════════════════════╝\n');
 
  // ── STEP 1: Connect to postgres (default db) and create cricketpass ────────
  info('STEP 1: Creating database');
  const adminClient = new Client({
    host:     'localhost',
    port:     5432,
    user:     'postgres',
    password: PASSWORD,
    database: 'postgres',
  });
 
  try {
    await adminClient.connect();
    ok('Connected to PostgreSQL');
 
    // Check if DB exists
    const exists = await adminClient.query(
      `SELECT 1 FROM pg_database WHERE datname = $1`, [DB_NAME]
    );
    if (exists.rows.length > 0) {
      log(`Database "${DB_NAME}" already exists — will update tables`);
    } else {
      await adminClient.query(`CREATE DATABASE ${DB_NAME}`);
      ok(`Database "${DB_NAME}" created`);
    }
    await adminClient.end();
  } catch (e) {
    err(`Cannot connect to PostgreSQL: ${e.message}`);
    if (e.message.includes('password')) {
      console.log('\n  🔑 Password is wrong. Edit line 10 in this file:');
      console.log(`     const PASSWORD = 'YOUR_ACTUAL_PASSWORD';\n`);
    }
    if (e.message.includes('ECONNREFUSED')) {
      console.log('\n  💡 PostgreSQL is not running.');
      console.log('     Open Windows Services → find PostgreSQL → click Start\n');
    }
    process.exit(1);
  }
 
  // ── STEP 2: Connect to cricketpass and run schema ──────────────────────────
  info('STEP 2: Creating all 8 tables');
  const dbClient = new Client({
    host:     'localhost',
    port:     5432,
    user:     'postgres',
    password: PASSWORD,
    database: DB_NAME,
  });
 
  try {
    await dbClient.connect();
 
    // Read schema file
    let schemaPath = path.join(__dirname, 'schema.sql');
    if (!fs.existsSync(schemaPath)) {
      // Try parent directory
      schemaPath = path.join(__dirname, '..', 'database', 'schema.sql');
    }
    if (!fs.existsSync(schemaPath)) {
      err('schema.sql not found. Make sure setup_db.js is in the same folder as schema.sql');
      process.exit(1);
    }
 
    const sql = fs.readFileSync(schemaPath, 'utf8');
 
    // Run schema in chunks (split by semicolons, skip empty)
    const statements = sql
      .split(';')
      .map(s => s.trim())
      .filter(s => s.length > 5 && !s.startsWith('--'));
 
    let tableCount = 0;
    for (const stmt of statements) {
      try {
        await dbClient.query(stmt);
        if (stmt.toUpperCase().includes('CREATE TABLE')) {
          const tableName = stmt.match(/CREATE TABLE\s+(\w+)/i)?.[1] || '';
          ok(`Table created: ${tableName}`);
          tableCount++;
        }
      } catch (e) {
        // Ignore "already exists" errors during re-run
        if (!e.message.includes('already exists') && !e.message.includes('duplicate')) {
          log(`Note: ${e.message.slice(0, 80)}`);
        }
      }
    }
    ok(`${tableCount} tables ready`);
 
  } catch (e) {
    err(`Schema error: ${e.message}`);
    await dbClient.end();
    process.exit(1);
  }
 
  // ── STEP 3: Check seeded data ──────────────────────────────────────────────
  info('STEP 3: Checking seed data');
  try {
    const stadiums = await dbClient.query('SELECT COUNT(*) FROM stadiums');
    const matches  = await dbClient.query('SELECT COUNT(*) FROM matches');
    ok(`Stadiums in database: ${stadiums.rows[0].count}`);
    ok(`Matches in database:  ${matches.rows[0].count}`);
  } catch (e) {
    err(`Could not check seed data: ${e.message}`);
  }
 
  // ── STEP 4: Seed seats for all matches ────────────────────────────────────
  info('STEP 4: Creating 750 seats for each match');
  for (const matchId of MATCH_IDS) {
    try {
      // Check if seats already exist
      const existing = await dbClient.query(
        'SELECT COUNT(*) FROM seats WHERE match_id = $1', [matchId]
      );
      if (parseInt(existing.rows[0].count) > 0) {
        log(`Match ${matchId.slice(9,13)}… already has ${existing.rows[0].count} seats`);
        continue;
      }
 
      // Create seats
      const tiers = [
        { tier: 'premium', count: 50,  price: 2000, prefix: 'P' },
        { tier: 'middle',  count: 200, price: 1000, prefix: 'M' },
        { tier: 'last',    count: 500, price: 500,  prefix: 'L' },
      ];
      let total = 0;
      for (const { tier, count, price, prefix } of tiers) {
        for (let i = 1; i <= count; i++) {
          await dbClient.query(
            'INSERT INTO seats(match_id, seat_number, tier, base_price) VALUES($1,$2,$3,$4)',
            [matchId, `${prefix}${i}`, tier, price]
          );
          total++;
        }
      }
      ok(`Match ${matchId.slice(9,13)}… → ${total} seats created`);
    } catch (e) {
      err(`Seat creation failed for match ${matchId.slice(0,8)}: ${e.message}`);
    }
  }
 
  await dbClient.end();
 
  // ── DONE ──────────────────────────────────────────────────────────────────
  console.log('\n╔════════════════════════════════════════╗');
  console.log('║   ✅ DATABASE SETUP COMPLETE!          ║');
  console.log('╚════════════════════════════════════════╝');
  console.log('\n  Next steps:');
  console.log('  1. Make sure backend/.env has:');
  console.log('     DATABASE_URL=postgresql://postgres:Fathee%405026@localhost:5432/cricketpass');
  console.log('  2. cd backend && npm run dev');
  console.log('  3. You should see: 📦 PostgreSQL pool connected\n');
}
 
run().catch(e => {
  console.error('\n  ❌ Unexpected error:', e.message);
  process.exit(1);
});