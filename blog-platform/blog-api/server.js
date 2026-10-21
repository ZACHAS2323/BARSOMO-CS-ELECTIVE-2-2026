const path = require('path');
const dotenv = require('dotenv');

dotenv.config({ path: path.resolve(__dirname, '..', '.env') });

if (!process.env.JWT_SECRET) {
  console.error('JWT_SECRET is required in the project root .env file.');
  process.exit(1);
}

const express = require('express');
const postsRoutes = require('./src/routes/postsRoutes');

const app = express();
app.use(express.json({ limit: '16kb' }));
app.use('/api', postsRoutes);
app.use(express.static(path.join(__dirname, 'public')));

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

app.listen(5000, () => {
  console.log('Blog API listening on port 5000.');
});
