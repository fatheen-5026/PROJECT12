-- ============================================================
-- CricketPass - Complete Database Setup
-- Run this in pgAdmin Query Tool OR command line
-- ============================================================
 
-- Enable UUID
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
 
-- Drop existing tables if any (fresh start)
DROP TABLE IF EXISTS quiz_scores  CASCADE;
DROP TABLE IF EXISTS coupons      CASCADE;
DROP TABLE IF EXISTS payments     CASCADE;
DROP TABLE IF EXISTS bookings     CASCADE;
DROP TABLE IF EXISTS seats        CASCADE;
DROP TABLE IF EXISTS matches      CASCADE;
DROP TABLE IF EXISTS stadiums     CASCADE;
DROP TABLE IF EXISTS users        CASCADE;
 
-- ============================================================
-- TABLE 1: users
-- ============================================================
CREATE TABLE users (
  id            UUID         PRIMARY KEY DEFAULT uuid_generate_v4(),
  name          VARCHAR(100) NOT NULL,
  email         VARCHAR(150) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  phone         VARCHAR(20),
  role          VARCHAR(20)  DEFAULT 'user',
  created_at    TIMESTAMP    DEFAULT NOW()
);
 
-- ============================================================
-- TABLE 2: stadiums
-- ============================================================
CREATE TABLE stadiums (
  id       UUID         PRIMARY KEY DEFAULT uuid_generate_v4(),
  name     VARCHAR(150) NOT NULL,
  city     VARCHAR(100) NOT NULL,
  capacity INT          NOT NULL
);
 
-- ============================================================
-- TABLE 3: matches
-- ============================================================
CREATE TABLE matches (
  id          UUID         PRIMARY KEY DEFAULT uuid_generate_v4(),
  team1       VARCHAR(100) NOT NULL,
  team2       VARCHAR(100) NOT NULL,
  team1_logo  VARCHAR(20)  DEFAULT '🏏',
  team2_logo  VARCHAR(20)  DEFAULT '🏏',
  match_date  TIMESTAMP    NOT NULL,
  stadium_id  UUID         REFERENCES stadiums(id) ON DELETE CASCADE,
  match_type  VARCHAR(50)  DEFAULT 'T20',
  status      VARCHAR(20)  DEFAULT 'upcoming'
);
 
-- ============================================================
-- TABLE 4: seats
-- ============================================================
CREATE TABLE seats (
  id          UUID          PRIMARY KEY DEFAULT uuid_generate_v4(),
  match_id    UUID          REFERENCES matches(id) ON DELETE CASCADE,
  seat_number VARCHAR(10)   NOT NULL,
  tier        VARCHAR(20)   NOT NULL CHECK (tier IN ('premium','middle','last')),
  base_price  DECIMAL(10,2) NOT NULL,
  is_booked   BOOLEAN       DEFAULT FALSE,
  UNIQUE(match_id, seat_number)
);
 
-- ============================================================
-- TABLE 5: bookings  ← every ticket purchase stored here
-- ============================================================
CREATE TABLE bookings (
  id               UUID          PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id          UUID          REFERENCES users(id),
  match_id         UUID          REFERENCES matches(id),
  seat_id          UUID          REFERENCES seats(id),
  base_price       DECIMAL(10,2) NOT NULL,
  gst_amount       DECIMAL(10,2) NOT NULL,
  discount_amount  DECIMAL(10,2) DEFAULT 0,
  total_amount     DECIMAL(10,2) NOT NULL,
  coupon_code      VARCHAR(30),
  payment_status   VARCHAR(20)   DEFAULT 'pending',
  payment_method   VARCHAR(20),
  booking_status   VARCHAR(20)   DEFAULT 'active',
  entry_used       BOOLEAN       DEFAULT FALSE,
  qr_code          TEXT,
  created_at       TIMESTAMP     DEFAULT NOW()
);
 
-- ============================================================
-- TABLE 6: payments
-- ============================================================
CREATE TABLE payments (
  id                  UUID          PRIMARY KEY DEFAULT uuid_generate_v4(),
  booking_id          UUID          REFERENCES bookings(id),
  razorpay_order_id   VARCHAR(100),
  razorpay_payment_id VARCHAR(100),
  amount              DECIMAL(10,2) NOT NULL,
  status              VARCHAR(20)   DEFAULT 'pending',
  payment_method      VARCHAR(20),
  created_at          TIMESTAMP     DEFAULT NOW()
);
 
-- ============================================================
-- TABLE 7: coupons  ← quiz rewards stored here
-- ============================================================
CREATE TABLE coupons (
  id               UUID        PRIMARY KEY DEFAULT uuid_generate_v4(),
  code             VARCHAR(30) UNIQUE NOT NULL,
  discount_percent INT         NOT NULL,
  user_id          UUID        REFERENCES users(id),
  is_used          BOOLEAN     DEFAULT FALSE,
  expires_at       TIMESTAMP,
  created_at       TIMESTAMP   DEFAULT NOW()
);
 
-- ============================================================
-- TABLE 8: quiz_scores
-- ============================================================
CREATE TABLE quiz_scores (
  id               UUID      PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id          UUID      REFERENCES users(id),
  booking_id       UUID      REFERENCES bookings(id),
  score            INT       NOT NULL,
  total_questions  INT       DEFAULT 10,
  coupon_code      VARCHAR(30),
  discount_percent INT       DEFAULT 0,
  created_at       TIMESTAMP DEFAULT NOW()
);
 
-- ============================================================
-- INDEXES for fast queries
-- ============================================================
CREATE INDEX idx_bookings_user    ON bookings(user_id);
CREATE INDEX idx_bookings_match   ON bookings(match_id);
CREATE INDEX idx_seats_match      ON seats(match_id);
CREATE INDEX idx_matches_date     ON matches(match_date);
CREATE INDEX idx_coupons_user     ON coupons(user_id);
CREATE INDEX idx_coupons_code     ON coupons(code);
 
-- ============================================================
-- SEED: 10 Stadiums
-- ============================================================
INSERT INTO stadiums (id, name, city, capacity) VALUES
('aaaaaaaa-0001-0001-0001-000000000001','MA Chidambaram Stadium',    'Chennai',   50000),
('aaaaaaaa-0002-0002-0002-000000000002','Wankhede Stadium',          'Mumbai',    33000),
('aaaaaaaa-0003-0003-0003-000000000003','Eden Gardens',              'Kolkata',   68000),
('aaaaaaaa-0004-0004-0004-000000000004','Narendra Modi Stadium',     'Ahmedabad', 132000),
('aaaaaaaa-0005-0005-0005-000000000005','M. Chinnaswamy Stadium',    'Bengaluru', 35000),
('aaaaaaaa-0006-0006-0006-000000000006','Arun Jaitley Stadium',      'Delhi',     41000),
('aaaaaaaa-0007-0007-0007-000000000007','Rajiv Gandhi Intl Stadium', 'Hyderabad', 55000),
('aaaaaaaa-0008-0008-0008-000000000008','Sawai Mansingh Stadium',    'Jaipur',    30000),
('aaaaaaaa-0009-0009-0009-000000000009','BRSABV Ekana Stadium',      'Lucknow',   50000),
('aaaaaaaa-0010-0010-0010-000000000010','PCA Stadium',               'Mohali',    26000);
 
-- ============================================================
-- SEED: 8 Matches
-- ============================================================
INSERT INTO matches (id,team1,team2,team1_logo,team2_logo,match_date,stadium_id,match_type) VALUES
('bbbbbbbb-0001-0001-0001-000000000001','Chennai Super Kings','Mumbai Indians',       '🦁','🌀', NOW()+INTERVAL '5 days',  'aaaaaaaa-0001-0001-0001-000000000001','IPL T20'),
('bbbbbbbb-0002-0002-0002-000000000002','Royal Challengers', 'Kolkata Knight Riders','👑','⚡', NOW()+INTERVAL '7 days',  'aaaaaaaa-0005-0005-0005-000000000005','IPL T20'),
('bbbbbbbb-0003-0003-0003-000000000003','India',             'Australia',            '🇮🇳','🦘',NOW()+INTERVAL '10 days', 'aaaaaaaa-0002-0002-0002-000000000002','ODI'),
('bbbbbbbb-0004-0004-0004-000000000004','Delhi Capitals',    'Punjab Kings',         '🔵','🦁', NOW()+INTERVAL '12 days', 'aaaaaaaa-0006-0006-0006-000000000006','IPL T20'),
('bbbbbbbb-0005-0005-0005-000000000005','Rajasthan Royals',  'Sunrisers Hyderabad',  '🌹','🌅', NOW()+INTERVAL '14 days', 'aaaaaaaa-0008-0008-0008-000000000008','IPL T20'),
('bbbbbbbb-0006-0006-0006-000000000006','India',             'England',              '🇮🇳','🏴󠁧󠁢󠁥󠁮󠁧󠁿',NOW()+INTERVAL '18 days', 'aaaaaaaa-0004-0004-0004-000000000004','T20I'),
('bbbbbbbb-0007-0007-0007-000000000007','Gujarat Titans',    'Lucknow Super Giants', '🔷','🦟', NOW()+INTERVAL '20 days', 'aaaaaaaa-0004-0004-0004-000000000004','IPL T20'),
('bbbbbbbb-0008-0008-0008-000000000008','India',             'South Africa',         '🇮🇳','🇿🇦',NOW()+INTERVAL '25 days', 'aaaaaaaa-0003-0003-0003-000000000003','ODI');
 
-- ============================================================
-- VIEW: see all bookings easily in pgAdmin
-- ============================================================
CREATE OR REPLACE VIEW all_bookings AS
SELECT
  b.id            AS booking_id,
  b.created_at,
  b.payment_status,
  b.booking_status,
  b.payment_method,
  b.base_price,
  b.gst_amount,
  b.discount_amount,
  b.total_amount,
  b.entry_used,
  u.name          AS user_name,
  u.email         AS user_email,
  u.phone,
  m.team1,
  m.team2,
  m.match_date,
  m.match_type,
  s.name          AS stadium_name,
  s.city,
  se.seat_number,
  se.tier
FROM bookings  b
JOIN users    u  ON b.user_id    = u.id
JOIN matches  m  ON b.match_id   = m.id
JOIN stadiums s  ON m.stadium_id = s.id
JOIN seats    se ON b.seat_id    = se.id;
 
-- ============================================================
-- CONFIRM everything was created
-- ============================================================
SELECT '✅ Tables created successfully' AS status;
SELECT 'Stadiums: ' || COUNT(*)::text   AS stadiums FROM stadiums;
SELECT 'Matches:  ' || COUNT(*)::text   AS matches  FROM matches;