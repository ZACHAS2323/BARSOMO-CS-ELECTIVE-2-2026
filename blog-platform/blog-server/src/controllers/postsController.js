const pool = require('../../db');

const postFields = `
  SELECT p.id, p.author_id, u.username AS author_username, p.title, p.content,
         p.created_at, p.updated_at
  FROM posts p JOIN users u ON u.id = p.author_id`;

async function listPosts(req, res) {
  const [posts] = await pool.query(`${postFields} ORDER BY p.created_at DESC`);
  return res.status(200).json(posts);
}

async function getPost(req, res) {
  const [posts] = await pool.execute(`${postFields} WHERE p.id = ? LIMIT 1`, [req.params.id]);
  if (!posts[0]) return res.status(404).json({ error: 'Post not found.' });
  return res.status(200).json(posts[0]);
}

async function listMyPosts(req, res) {
  const [posts] = await pool.execute(
    `${postFields} WHERE p.author_id = ? ORDER BY p.created_at DESC`,
    [req.user.id]
  );
  return res.status(200).json(posts);
}

async function createPost(req, res) {
  const { title, content } = req.body || {};
  if (typeof title !== 'string' || !title.trim() || title.trim().length > 255
      || typeof content !== 'string' || !content.trim()) {
    return res.status(400).json({ error: 'A title (up to 255 characters) and non-empty content are required.' });
  }
  const [result] = await pool.execute(
    'INSERT INTO posts (author_id, title, content) VALUES (?, ?, ?)',
    [req.user.id, title.trim(), content.trim()]
  );
  const [posts] = await pool.execute(`${postFields} WHERE p.id = ? LIMIT 1`, [result.insertId]);
  return res.status(201).json(posts[0]);
}

async function updatePost(req, res) {
  const { title, content } = req.body || {};
  if (title === undefined && content === undefined) {
    return res.status(400).json({ error: 'Provide a title, content, or both to update.' });
  }
  if (title !== undefined && (typeof title !== 'string' || !title.trim() || title.trim().length > 255)) {
    return res.status(400).json({ error: 'Title must be a non-empty string of at most 255 characters.' });
  }
  if (content !== undefined && (typeof content !== 'string' || !content.trim())) {
    return res.status(400).json({ error: 'Content must be a non-empty string.' });
  }

  const [posts] = await pool.execute(`${postFields} WHERE p.id = ? LIMIT 1`, [req.params.id]);
  const post = posts[0];
  if (!post) return res.status(404).json({ error: 'Post not found.' });
  if (req.user.role !== 'admin' && post.author_id !== req.user.id) {
    return res.status(403).json({ error: 'You can only update your own posts.' });
  }

  await pool.execute(
    `UPDATE posts SET title = ?, content = ?, updated_at = UTC_TIMESTAMP()
     WHERE id = ?`,
    [title === undefined ? post.title : title.trim(), content === undefined ? post.content : content.trim(), post.id]
  );
  const [updated] = await pool.execute(`${postFields} WHERE p.id = ? LIMIT 1`, [post.id]);
  return res.status(200).json(updated[0]);
}

async function deletePost(req, res) {
  const [result] = await pool.execute('DELETE FROM posts WHERE id = ?', [req.params.id]);
  if (result.affectedRows === 0) return res.status(404).json({ error: 'Post not found.' });
  return res.status(200).json({ message: 'Post deleted successfully.' });
}

module.exports = { listPosts, getPost, listMyPosts, createPost, updatePost, deletePost };
