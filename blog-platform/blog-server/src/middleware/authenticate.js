const jwt = require('jsonwebtoken');

function authenticate(req, res, next) {
  const authorization = req.get('authorization') || '';
  const [scheme, token, extra] = authorization.split(' ');
  if (scheme !== 'Bearer' || !token || extra) {
    return res.status(401).json({ error: 'A valid Bearer access token is required.' });
  }
  try {
    const payload = jwt.verify(token, process.env.JWT_SECRET, { algorithms: ['HS256'] });
    if (payload.type !== 'access' || !payload.id || !payload.role) {
      return res.status(401).json({ error: 'Invalid access token.' });
    }
    req.user = {
      id: Number(payload.id),
      username: payload.username,
      role: payload.role
    };
    return next();
  } catch {
    return res.status(401).json({ error: 'Access token is invalid or expired.' });
  }
}

module.exports = authenticate;
