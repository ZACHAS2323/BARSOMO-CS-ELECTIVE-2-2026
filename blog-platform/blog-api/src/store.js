const path = require('path');
const { LocalStorage } = require('node-localstorage');

const storage = new LocalStorage(path.resolve(__dirname, '..', 'data'));
const storedPosts = storage.getItem('posts');
const posts = storedPosts ? JSON.parse(storedPosts) : [];

if (!Array.isArray(posts)) {
  throw new Error('Stored posts data must be an array.');
}

function savePosts() {
  storage.setItem('posts', JSON.stringify(posts));
}

module.exports = { posts, savePosts };
