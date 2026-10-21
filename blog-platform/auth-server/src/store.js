const path = require('path');
const { LocalStorage } = require('node-localstorage');

const storage = new LocalStorage(path.resolve(__dirname, '..', 'data'));
const storedUsers = storage.getItem('users');
const users = storedUsers ? JSON.parse(storedUsers) : [];

if (!Array.isArray(users)) {
  throw new Error('Stored users data must be an array.');
}

function saveUsers() {
  storage.setItem('users', JSON.stringify(users));
}

module.exports = { users, saveUsers };
