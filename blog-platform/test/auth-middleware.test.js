const test = require('node:test');
const assert = require('node:assert/strict');
const jwt = require('jsonwebtoken');

process.env.JWT_SECRET = 'test-secret-with-more-than-thirty-two-characters';

const authenticate = require('../blog-server/src/middleware/authenticate');
const authorize = require('../blog-server/src/middleware/authorize');

function invoke(middleware, { authorization, user } = {}) {
  const result = { status: 200, body: null, nextCalled: false };
  const req = {
    user,
    get: (name) => name.toLowerCase() === 'authorization' ? authorization : undefined
  };
  const res = {
    status(code) {
      result.status = code;
      return this;
    },
    json(body) {
      result.body = body;
      return this;
    }
  };
  middleware(req, res, () => { result.nextCalled = true; });
  result.user = req.user;
  return result;
}

test('authenticate rejects missing and invalid bearer tokens', () => {
  assert.equal(invoke(authenticate).status, 401);
  assert.equal(invoke(authenticate, { authorization: 'Bearer not-a-token' }).status, 401);
});

test('authenticate rejects refresh tokens and accepts access tokens', () => {
  const refresh = jwt.sign({ id: 8, role: 'author', type: 'refresh' }, process.env.JWT_SECRET);
  assert.equal(invoke(authenticate, { authorization: `Bearer ${refresh}` }).status, 401);

  const access = jwt.sign(
    { id: 8, username: 'writer', role: 'author', type: 'access' },
    process.env.JWT_SECRET,
    { algorithm: 'HS256' }
  );
  const result = invoke(authenticate, { authorization: `Bearer ${access}` });
  assert.equal(result.nextCalled, true);
  assert.deepEqual(result.user, { id: 8, username: 'writer', role: 'author' });
});

test('authorize rejects disallowed roles and allows an assigned role', () => {
  assert.equal(invoke(authorize('admin'), { user: { role: 'author' } }).status, 403);
  assert.equal(invoke(authorize('author'), { user: { role: 'author' } }).nextCalled, true);
});
