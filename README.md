# 🏏 CricketPass — Full Stack Stadium Ticket Booking

React + Node.js + PostgreSQL · Complete production-ready project

---

## Project Structure

```
cricket-full/
├── frontend/                    ← React + Vite
│   ├── index.html
│   ├── vite.config.js
│   ├── package.json
│   └── src/
│       ├── main.jsx             ← App entry point
│       ├── App.jsx              ← React Router routes
│       ├── index.css            ← Global styles
│       ├── api/
│       │   └── axios.js         ← Axios instance + interceptors
│       ├── store/
│       │   ├── index.js         ← Redux store
│       │   └── slices/
│       │       ├── authSlice.js     ← Login, register, logout
│       │       ├── matchSlice.js    ← Fetch matches
│       │       └── bookingSlice.js  ← Booking + coupon state
│       ├── components/
│       │   └── Navbar.jsx
│       └── pages/
│           ├── Home.jsx         ← Landing page
│           ├── Matches.jsx      ← Match listing grid
│           ├── SeatSelection.jsx← Interactive seat map
│           ├── Ticket.jsx       ← Booking success + QR
│           ├── Dashboard.jsx    ← My bookings
│           ├── Quiz.jsx         ← 10-question cricket quiz
│           ├── Login.jsx
│           └── Register.jsx
│
├── backend/                     ← Node.js + Express
│   ├── server.js                ← Express entry + middleware
│   ├── package.json
│   ├── .env.example
│   ├── db/
│   │   └── pool.js              ← PostgreSQL pool
│   ├── middleware/
│   │   └── auth.js              ← JWT + admin guard
│   ├── routes/
│   │   ├── auth.js              ← Register, login, me, profile
│   │   ├── matches.js           ← List, detail, seed seats
│   │   ├── bookings.js          ← Create, list, cancel, scan, coupon
│   │   └── quiz.js              ← Questions, submit, scores
│   └── utils/
│       └── email.js             ← Nodemailer HTML ticket email
│
└── database/
    └── schema.sql               ← All tables + seed data
```

---

## Quick Start

### Step 1 — Database

```bash
# Create the database
createdb cricketpass

# Apply schema + seed data
psql -d cricketpass -f database/schema.sql

# Seed seats for each match (after server is running)
curl -X POST http://localhost:5000/api/matches/22222222-0000-0000-0000-000000000001/seed-seats
curl -X POST http://localhost:5000/api/matches/22222222-0000-0000-0000-000000000002/seed-seats
curl -X POST http://localhost:5000/api/matches/22222222-0000-0000-0000-000000000003/seed-seats
```

### Step 2 — Backend

```bash
cd backend
cp .env.example .env
# Edit .env with your PostgreSQL, email, and Razorpay credentials

npm install
npm run dev       # starts on http://localhost:5000
```

### Step 3 — Frontend

```bash
cd frontend
npm install
npm run dev       # starts on http://localhost:5173
```

Open **http://localhost:5173** in your browser.

---

## All API Endpoints

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| POST | /api/auth/register | — | Register new user |
| POST | /api/auth/login | — | Login, returns JWT |
| GET | /api/auth/me | ✓ | Get current user |
| PUT | /api/auth/profile | ✓ | Update name/phone |
| GET | /api/matches | — | All upcoming matches |
| GET | /api/matches/:id | — | Match + seat grid |
| POST | /api/matches/:id/seed-seats | — | Generate 750 seats |
| POST | /api/bookings | ✓ | Create booking |
| GET | /api/bookings/my | ✓ | My booking history |
| GET | /api/bookings/:id | ✓ | Single booking |
| DELETE | /api/bookings/:id | ✓ | Cancel booking |
| POST | /api/bookings/scan | — | QR gate scan |
| GET | /api/bookings/validate-coupon/:code | ✓ | Validate coupon |
| GET | /api/quiz/questions | ✓ | Get 10 questions |
| POST | /api/quiz/submit | ✓ | Submit answers |
| GET | /api/quiz/my-scores | ✓ | Past quiz scores |

---

## Seat Tiers & Pricing

| Tier | Count | Base | GST | Total |
|------|-------|------|-----|-------|
| Premium (P1–P50) | 50 | ₹2,000 | ₹360 | ₹2,360 |
| Middle (M1–M200) | 200 | ₹1,000 | ₹180 | ₹1,180 |
| Last (L1–L500) | 500 | ₹500 | ₹90 | ₹590 |

---

## Quiz Discount Rules

| Score | Discount | Tier |
|-------|----------|------|
| 9–10 / 10 | 20% off | Gold 🥇 |
| 7–8 / 10 | 15% off | Silver 🥈 |
| 5–6 / 10 | 10% off | Bronze 🥉 |
| 3–4 / 10 | 5% off | Starter |
| 0–2 / 10 | No discount | — |

Coupon is valid for 30 days and single-use per user.

---

## Key Features

- ✅ JWT authentication (register/login/logout)
- ✅ Match listing with real-time seat availability
- ✅ Interactive stadium seat map (Premium / Middle / Last tiers)
- ✅ PostgreSQL row-level locking (prevents double booking)
- ✅ 18% GST calculation + coupon discount
- ✅ GPay / PhonePe / UPI payment selection (Razorpay ready)
- ✅ QR code ticket generation per booking
- ✅ HTML ticket email via Nodemailer
- ✅ My Bookings dashboard with QR viewer
- ✅ Booking cancellation
- ✅ QR scanner gate entry validation API
- ✅ 10-question cricket quiz with automatic coupon generation
- ✅ Redux Toolkit state management
- ✅ React Router v6 with protected routes
- ✅ Rate limiting + helmet security headers
- ✅ Dark stadium theme with Gold/Teal accent design

---

## Environment Variables

```env
PORT=5000
DATABASE_URL=postgresql://postgres:password@localhost:5432/cricketpass
JWT_SECRET=change_this_to_a_long_random_string
JWT_EXPIRES_IN=7d
RAZORPAY_KEY_ID=rzp_test_xxxxxxxxxx
RAZORPAY_KEY_SECRET=your_secret
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_USER=your@gmail.com
EMAIL_PASS=your_16_char_app_password
EMAIL_FROM=CricketPass <your@gmail.com>
GST_RATE=0.18
FRONTEND_URL=http://localhost:5173
```

> **Gmail tip:** Enable 2FA and generate an App Password at
> https://myaccount.google.com/apppasswords
