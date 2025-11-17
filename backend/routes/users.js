const express = require('express');
const { body, validationResult } = require('express-validator');
const User = require('../models/User');
const { authenticate } = require('../middleware/auth');
const upload = require('../middleware/upload');
const path = require('path');

const router = express.Router();

// @route   GET /api/users/profile/:uid
// @desc    Get user profile by UID
// @access  Private
router.get('/profile/:uid', authenticate, async (req, res) => {
  try {
    const { uid } = req.params;
    const user = await User.findOne({ uid });

    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found',
      });
    }

    res.json({
      success: true,
      user: user.toJSON(),
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Failed to fetch user profile',
      error: error.message,
    });
  }
});

// @route   GET /api/users/me
// @desc    Get current user profile
// @access  Private
router.get('/me', authenticate, async (req, res) => {
  try {
    res.json({
      success: true,
      user: req.user.toJSON(),
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Failed to fetch profile',
      error: error.message,
    });
  }
});

// @route   PUT /api/users/me
// @desc    Update current user profile
// @access  Private
router.put(
  '/me',
  authenticate,
  [
    body('name').optional().trim().notEmpty(),
    body('bio').optional().trim(),
    body('skillsToTeach').optional().isArray(),
    body('skillsToLearn').optional().isArray(),
  ],
  async (req, res) => {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({
          success: false,
          message: 'Validation error',
          errors: errors.array(),
        });
      }

      const { name, bio, skillsToTeach, skillsToLearn } = req.body;

      // Update user fields
      if (name !== undefined) req.user.name = name;
      if (bio !== undefined) req.user.bio = bio;
      if (skillsToTeach !== undefined) req.user.skillsToTeach = skillsToTeach;
      if (skillsToLearn !== undefined) req.user.skillsToLearn = skillsToLearn;
      req.user.lastActive = new Date();

      await req.user.save();

      res.json({
        success: true,
        message: 'Profile updated successfully',
        user: req.user.toJSON(),
      });
    } catch (error) {
      res.status(500).json({
        success: false,
        message: 'Failed to update profile',
        error: error.message,
      });
    }
  }
);

// @route   POST /api/users/me/photo
// @desc    Upload profile photo
// @access  Private
router.post('/me/photo', authenticate, upload.single('photo'), async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({
        success: false,
        message: 'No file uploaded',
      });
    }

    // Construct photo URL
    const photoUrl = `${req.protocol}://${req.get('host')}/uploads/${req.file.filename}`;

    // Update user photo
    req.user.photoUrl = photoUrl;
    await req.user.save();

    res.json({
      success: true,
      message: 'Profile photo uploaded successfully',
      photoUrl,
      user: req.user.toJSON(),
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Failed to upload photo',
      error: error.message,
    });
  }
});

// @route   GET /api/users/all
// @desc    Get all users except current user
// @access  Private
router.get('/all', authenticate, async (req, res) => {
  try {
    const users = await User.find({ uid: { $ne: req.user.uid } })
      .select('-password')
      .sort({ lastActive: -1 });

    res.json({
      success: true,
      users: users.map(user => user.toJSON()),
      count: users.length,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Failed to fetch users',
      error: error.message,
    });
  }
});

module.exports = router;

