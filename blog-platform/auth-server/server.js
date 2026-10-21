const path = require('path');
const dotenv = require('dotenv');

dotenv.config({ path: path.resolve(__dirname, '..', '.env') });

if (!process.env.JWT_SECRET) {
  console.error('JWT_SECRET is required in the project root .env file.');
  process.exit(1);
}

const express = require('express');
const authRoutes = require('./src/routes/authRoutes');

const app = express();
const allowedOrigins = new Set(['http://localhost:5000', 'http://127.0.0.1:5000']);
app.use((req, res, next) => {
  const origin = req.get('origin');
  if (allowedOrigins.has(origin)) {
    res.setHeader('Access-Control-Allow-Origin', origin);
    res.setHeader('Vary', 'Origin');
  }
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');
  if (req.method === 'OPTIONS') return res.sendStatus(204);
  return next();
});
app.use(express.json({ limit: '16kb' }));
app.use(authRoutes);

app.use((req, res) => {
  res.status(404).json({ error: 'Route not found.' });
});

app.use((error, req, res, next) => {
  if (res.headersSent) return next(error);
  const status = error.status || error.statusCode || 500;
  const message = error.type === 'entity.parse.failed'
    ? 'Invalid JSON body.'
    : status >= 500 ? 'Internal server error.' : error.message;
  return res.status(status).json({ error: message });
});

app.listen(4000, () => {
  console.log('Auth Server listening on port 4000.');
});
