const { posts, savePosts } = require('../store');

function listPosts(req, res) {
  return res.status(200).json(posts);
}

function getPost(req, res) {
  const post = posts.find((candidate) => String(candidate.id) === req.params.id);
  if (!post) return res.status(404).json({ error: 'Post not found.' });
  return res.status(200).json(post);
}

function listMyPosts(req, res) {
  const ownPosts = posts.filter((post) => post.user_id === req.user.id);
  return res.status(200).json(ownPosts);
}

function createPost(req, res) {
  const { title, content } = req.body || {};
  if (typeof title !== 'string' || !title.trim() || typeof content !== 'string' || !content.trim()) {
    return res.status(400).json({ error: 'A non-empty title and content are required.' });
  }

  const id = posts.reduce((highestId, post) => Math.max(highestId, Number(post.id) || 0), 0) + 1;
  const now = new Date().toISOString();
  const post = {
    id,
    user_id: req.user.id,
    title: title.trim(),
    content,
    created_at: now,
    updated_at: now
  };
  posts.push(post);
  savePosts();
  return res.status(201).json(post);
}

function updatePost(req, res) {
  const post = posts.find((candidate) => String(candidate.id) === req.params.id);
  if (!post) return res.status(404).json({ error: 'Post not found.' });
  if (req.user.role !== 'admin' && post.user_id !== req.user.id) {
    return res.status(403).json({ error: 'You can only update your own posts.' });
  }

  const body = req.body || {};
  const hasTitle = Object.prototype.hasOwnProperty.call(body, 'title');
  const hasContent = Object.prototype.hasOwnProperty.call(body, 'content');
  if (!hasTitle && !hasContent) {
    return res.status(400).json({ error: 'Provide a title, content, or both to update.' });
  }
  if (hasTitle && (typeof body.title !== 'string' || !body.title.trim())) {
    return res.status(400).json({ error: 'Title must be a non-empty string.' });
  }
  if (hasContent && (typeof body.content !== 'string' || !body.content.trim())) {
    return res.status(400).json({ error: 'Content must be a non-empty string.' });
  }

  if (hasTitle) post.title = body.title.trim();
  if (hasContent) post.content = body.content;
  post.updated_at = new Date().toISOString();
  savePosts();
  return res.status(200).json(post);
}

function deletePost(req, res) {
  const postIndex = posts.findIndex((candidate) => String(candidate.id) === req.params.id);
  if (postIndex === -1) return res.status(404).json({ error: 'Post not found.' });

  const [deletedPost] = posts.splice(postIndex, 1);
  savePosts();
  return res.status(200).json({ message: 'Post deleted successfully.', post: deletedPost });
}

module.exports = { listPosts, getPost, listMyPosts, createPost, updatePost, deletePost };
