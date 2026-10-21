const jwt = require('jsonwebtoken');

function authenticate(req, res, next) {
  const authorization = req.get('authorization') || '';
  const match = authorization.match(/^Bearer\s+(.+)$/i);
  if (!match) {
    return res.status(401).json({ error: 'A bearer access token is required.' });
  }

  try {
    const payload = jwt.verify(match[1], process.env.JWT_SECRET);
    if (payload.type === 'refresh' || payload.id === undefined || !payload.username || !payload.role) {
      return res.status(401).json({ error: 'Invalid access token.' });
    }

    req.user = { id: payload.id, username: payload.username, role: payload.role };
    return next();
  } catch {
    return res.status(401).json({ error: 'Access token is invalid or expired.' });
  }
}

module.exports = authenticate;
