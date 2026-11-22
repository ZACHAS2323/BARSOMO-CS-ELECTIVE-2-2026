const path = require('path');
require('dotenv').config({ path: path.resolve(__dirname, '..', '.env') });

if (!process.env.JWT_SECRET || process.env.JWT_SECRET.length < 32) {
  console.error('JWT_SECRET must be set to at least 32 characters in the project .env file.');
  process.exit(1);
}

const express = require('express');
const helmet = require('helmet');
const cors = require('cors');
const cookieParser = require('cookie-parser');
const { rateLimit } = require('express-rate-limit');
const pool = require('./db');
const authRoutes = require('./src/routes/authRoutes');

const app = express();
app.use(helmet());
app.use(cors({
  origin: [
    process.env.FRONTEND_ORIGIN || 'http://localhost:5173',
    'http://localhost:5173',
    'http://127.0.0.1:5173'
  ]
}));
app.use(cookieParser());
app.use(express.json({ limit: '16kb' }));
app.use(rateLimit({ windowMs: 15 * 60 * 1000, limit: 100 }));
app.use(authRoutes);

app.use((req, res) => res.status(404).json({ error: 'Route not found.' }));
app.use((error, req, res, next) => {
  if (res.headersSent) return next(error);
  if (error.type === 'entity.parse.failed') {
    return res.status(400).json({ error: 'Invalid JSON body.' });
  }
  console.error('Auth server error:', error);
  return res.status(500).json({ error: 'Internal server error.' });
});

const port = Number(process.env.AUTH_PORT || 4000);
pool.query('SELECT 1')
  .then(() => app.listen(port, () => console.log(`Auth Server listening on port ${port}.`)))
  .catch((error) => {
    console.error('Unable to connect to MariaDB:', error.message);
    process.exit(1);
  });
