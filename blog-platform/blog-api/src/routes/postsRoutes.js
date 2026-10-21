const express = require('express');
const authenticate = require('../middleware/authenticate');
const authorize = require('../middleware/authorize');
const postsController = require('../controllers/postsController');

const router = express.Router();

router.get('/posts', postsController.listPosts);
router.get('/posts/:id', postsController.getPost);
router.get('/me/posts', authenticate, postsController.listMyPosts);
router.post('/posts', authenticate, authorize('author', 'admin'), postsController.createPost);
router.put('/posts/:id', authenticate, postsController.updatePost);
router.delete('/posts/:id', authenticate, authorize('admin'), postsController.deletePost);

module.exports = router;
