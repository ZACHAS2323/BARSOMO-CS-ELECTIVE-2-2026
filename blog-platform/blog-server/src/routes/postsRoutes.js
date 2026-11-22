const express = require('express');
const asyncHandler = require('../middleware/asyncHandler');
const authenticate = require('../middleware/authenticate');
const authorize = require('../middleware/authorize');
const postsController = require('../controllers/postsController');

const router = express.Router();

router.get('/posts', asyncHandler(postsController.listPosts));
router.get('/posts/:id', asyncHandler(postsController.getPost));
router.get('/me/posts', authenticate, asyncHandler(postsController.listMyPosts));
router.post('/posts', authenticate, authorize('author', 'admin'), asyncHandler(postsController.createPost));
router.put('/posts/:id', authenticate, asyncHandler(postsController.updatePost));
router.delete('/posts/:id', authenticate, authorize('admin'), asyncHandler(postsController.deletePost));

module.exports = router;
