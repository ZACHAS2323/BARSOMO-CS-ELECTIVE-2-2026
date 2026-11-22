const crypto = require('crypto');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const pool = require('../../db');

const publicRoles = new Set(['reader', 'author']);

function createAccessToken(user) {
  return jwt.sign(
    { sub: String(user.id), id: user.id, username: user.username, role: user.role, type: 'access' },
    process.env.JWT_SECRET,
    { algorithm: 'HS256', expiresIn: process.env.ACCESS_TOKEN_TTL || '15m' }
  );
}

function hashToken(token) {
  return crypto.createHash('sha256').update(token).digest('hex');
}

function createRefreshToken() {
  return crypto.randomBytes(48).toString('base64url');
}

function normalizeUsername(value) {
  return typeof value === 'string' ? value.trim() : '';
}

async function register(req, res, next) {
  try {
    const username = normalizeUsername(req.body && req.body.username);
    const password = req.body && req.body.password;
    const requestedRole = req.body && req.body.role;
    const submittedEmail = req.body && req.body.email;
    const email = typeof submittedEmail === 'string' && submittedEmail.trim()
      ? submittedEmail.trim().toLowerCase()
      : `${username.toLowerCase()}@local.invalid`;

    if (!username || typeof password !== 'string' || !requestedRole) {
      return res.status(400).json({ error: 'Username, password, and role are required.' });
    }
    if (!/^[a-zA-Z0-9_.-]{3,50}$/.test(username)) {
      return res.status(400).json({ error: 'Username must be 3-50 characters and use letters, numbers, dots, underscores, or hyphens.' });
    }
    if (Buffer.byteLength(password, 'utf8') < 8 || Buffer.byteLength(password, 'utf8') > 72) {
      return res.status(400).json({ error: 'Password must be between 8 and 72 bytes.' });
    }
    if (!publicRoles.has(requestedRole)) {
      return res.status(400).json({ error: 'Role must be reader or author. Admins must be assigned by a database administrator.' });
    }
    if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
      return res.status(400).json({ error: 'A valid email address is required.' });
    }

    const [[role]] = await pool.execute('SELECT id FROM roles WHERE role = ?', [requestedRole]);
    if (!role) {
      return res.status(500).json({ error: 'Configured user role was not found. Run the database schema.' });
    }
    const passwordHash = await bcrypt.hash(password, 12);
    const [result] = await pool.execute(
      'INSERT INTO users (email, username, password_hash, role_id) VALUES (?, ?, ?, ?)',
      [email, username, passwordHash, role.id]
    );
    return res.status(201).json({
      message: 'User registered successfully.',
      user: { id: result.insertId, username, email, role: requestedRole }
    });
  } catch (error) {
    if (error.code === 'ER_DUP_ENTRY') {
      return res.status(409).json({ error: 'Username or email is already in use.' });
    }
    return next(error);
  }
}

async function login(req, res, next) {
  try {
    const username = normalizeUsername(req.body && req.body.username);
    const password = req.body && req.body.password;
    if (!username || typeof password !== 'string' || !password) {
      return res.status(400).json({ error: 'Username and password are required.' });
    }

    const [users] = await pool.execute(
      `SELECT u.id, u.username, u.email, u.password_hash, u.is_active, r.role
       FROM users u JOIN roles r ON r.id = u.role_id
       WHERE u.username = ? LIMIT 1`,
      [username]
    );
    const user = users[0];
    if (!user || !user.is_active || !(await bcrypt.compare(password, user.password_hash))) {
      return res.status(401).json({ error: 'Invalid username or password.' });
    }

    const refreshToken = createRefreshToken();
    const refreshDays = Math.max(1, Number(process.env.REFRESH_TOKEN_DAYS) || 7);
    const expiresAt = new Date(Date.now() + refreshDays * 24 * 60 * 60 * 1000)
      .toISOString()
      .slice(0, 19)
      .replace('T', ' ');
    await pool.execute(
      'INSERT INTO refresh_tokens (user_id, token_hash, expires_at) VALUES (?, ?, ?)',
      [user.id, hashToken(refreshToken), expiresAt]
    );
    return res.status(200).json({
      accessToken: createAccessToken(user),
      refreshToken,
      user: { id: user.id, username: user.username, email: user.email, role: user.role }
    });
  } catch (error) {
    return next(error);
  }
}

async function refresh(req, res, next) {
  const refreshToken = req.body && req.body.refreshToken;
  if (typeof refreshToken !== 'string' || !refreshToken) {
    return res.status(400).json({ error: 'Refresh token is required.' });
  }
  try {
    const [rows] = await pool.execute(
      `SELECT u.id, u.username, r.role
       FROM refresh_tokens t
       JOIN users u ON u.id = t.user_id
       JOIN roles r ON r.id = u.role_id
       WHERE t.token_hash = ? AND t.revoked_at IS NULL
         AND t.expires_at > UTC_TIMESTAMP() AND u.is_active = 1
       LIMIT 1`,
      [hashToken(refreshToken)]
    );
    if (!rows[0]) return res.status(401).json({ error: 'Refresh token is invalid, expired, or revoked.' });
    return res.status(200).json({ accessToken: createAccessToken(rows[0]) });
  } catch (error) {
    return next(error);
  }
}

async function logout(req, res, next) {
  const refreshToken = req.body && req.body.refreshToken;
  if (typeof refreshToken !== 'string' || !refreshToken) {
    return res.status(400).json({ error: 'Refresh token is required.' });
  }
  try {
    await pool.execute(
      'UPDATE refresh_tokens SET revoked_at = UTC_TIMESTAMP() WHERE token_hash = ? AND revoked_at IS NULL',
      [hashToken(refreshToken)]
    );
    return res.status(200).json({ message: 'Logged out successfully.' });
  } catch (error) {
    return next(error);
  }
}

module.exports = { register, login, refresh, logout };
