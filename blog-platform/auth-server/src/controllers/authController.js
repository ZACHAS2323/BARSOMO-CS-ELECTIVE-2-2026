const crypto = require('crypto');
const jwt = require('jsonwebtoken');
const { users, saveUsers } = require('../store');

const allowedRoles = new Set(['reader', 'author', 'admin']);

function hashPassword(password) {
  const salt = crypto.randomBytes(16).toString('hex');
  const hash = crypto.scryptSync(password, salt, 64).toString('hex');
  return `scrypt$${salt}$${hash}`;
}

function passwordMatches(password, storedHash) {
  const [algorithm, salt, hash] = String(storedHash).split('$');
  if (algorithm !== 'scrypt' || !salt || !hash) return false;

  const expected = Buffer.from(hash, 'hex');
  const actual = crypto.scryptSync(password, salt, expected.length);
  return expected.length === actual.length && crypto.timingSafeEqual(expected, actual);
}

function createAccessToken(user) {
  return jwt.sign(
    { id: user.id, username: user.username, role: user.role },
    process.env.JWT_SECRET,
    { expiresIn: '15m' }
  );
}

function createRefreshToken(user) {
  return jwt.sign(
    { id: user.id, type: 'refresh' },
    process.env.JWT_SECRET,
    { expiresIn: '7d' }
  );
}

function register(req, res) {
  const { username, password, role } = req.body || {};
  if (typeof username !== 'string' || !username.trim() || typeof password !== 'string' || !password || !role) {
    return res.status(400).json({ error: 'Username, password, and role are required.' });
  }
  if (!allowedRoles.has(role)) {
    return res.status(400).json({ error: 'Role must be reader, author, or admin.' });
  }

  const normalizedUsername = username.trim();
  if (users.some((user) => user.username.toLowerCase() === normalizedUsername.toLowerCase())) {
    return res.status(409).json({ error: 'Username is already taken.' });
  }

  const id = users.reduce((highestId, user) => Math.max(highestId, Number(user.id) || 0), 0) + 1;
  const user = {
    id,
    username: normalizedUsername,
    hashed_password: hashPassword(password),
    role,
    refresh_token: null,
    created_at: new Date().toISOString(),
    revoked_at: null
  };
  users.push(user);
  saveUsers();

  return res.status(201).json({
    message: 'User registered successfully.',
    user: { id: user.id, username: user.username, role: user.role, created_at: user.created_at }
  });
}

function login(req, res) {
  const { username, password } = req.body || {};
  if (typeof username !== 'string' || !username.trim() || typeof password !== 'string' || !password) {
    return res.status(400).json({ error: 'Username and password are required.' });
  }

  const user = users.find((candidate) => candidate.username.toLowerCase() === username.trim().toLowerCase());
  if (!user || !passwordMatches(password, user.hashed_password)) {
    return res.status(401).json({ error: 'Invalid username or password.' });
  }

  const accessToken = createAccessToken(user);
  const refreshToken = createRefreshToken(user);
  user.refresh_token = refreshToken;
  user.revoked_at = null;
  saveUsers();

  return res.status(200).json({ accessToken, refreshToken });
}

function refresh(req, res) {
  const { refreshToken } = req.body || {};
  if (typeof refreshToken !== 'string' || !refreshToken) {
    return res.status(400).json({ error: 'Refresh token is required.' });
  }

  try {
    const payload = jwt.verify(refreshToken, process.env.JWT_SECRET);
    if (payload.type !== 'refresh') {
      return res.status(401).json({ error: 'Invalid refresh token.' });
    }

    const user = users.find((candidate) => candidate.id === payload.id);
    if (!user || user.revoked_at !== null || user.refresh_token !== refreshToken) {
      return res.status(401).json({ error: 'Refresh token is invalid or revoked.' });
    }

    return res.status(200).json({ accessToken: createAccessToken(user) });
  } catch {
    return res.status(401).json({ error: 'Refresh token is invalid or expired.' });
  }
}

function logout(req, res) {
  const { refreshToken } = req.body || {};
  if (typeof refreshToken !== 'string' || !refreshToken) {
    return res.status(400).json({ error: 'Refresh token is required.' });
  }

  const user = users.find((candidate) => candidate.refresh_token === refreshToken);
  if (!user) {
    return res.status(401).json({ error: 'Refresh token is invalid or already revoked.' });
  }

  user.refresh_token = null;
  user.revoked_at = new Date().toISOString();
  saveUsers();
  return res.status(200).json({ message: 'Logged out successfully.' });
}

module.exports = { register, login, refresh, logout };
