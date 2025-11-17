const express = require('express');
const { body, validationResult } = require('express-validator');
const { v4: uuidv4 } = require('uuid');
const User = require('../models/User');
const Match = require('../models/Match');
const { authenticate } = require('../middleware/auth');

const router = express.Router();

// Helper function to check mutual match
const isMutualMatch = (user1, user2) => {
  // Find skills user1 teaches that user2 wants to learn
  const user1TeachesUser2Learns = user1.skillsToTeach.filter(skill =>
    user2.skillsToLearn.includes(skill)
  );

  // Find skills user2 teaches that user1 wants to learn
  const user2TeachesUser1Learns = user2.skillsToTeach.filter(skill =>
    user1.skillsToLearn.includes(skill)
  );

  // Mutual match exists if both lists are not empty
  return user1TeachesUser2Learns.length > 0 && user2TeachesUser1Learns.length > 0;
};

// Helper function to get common skills
const getCommonSkills = (user1, user2) => {
  const common = [];

  // Skills user1 teaches that user2 wants
  common.push(...user1.skillsToTeach.filter(skill => user2.skillsToLearn.includes(skill)));

  // Skills user2 teaches that user1 wants
  common.push(...user2.skillsToTeach.filter(skill => user1.skillsToLearn.includes(skill)));

  // Remove duplicates
  return [...new Set(common)];
};

// @route   GET /api/matches/potential
// @desc    Find potential matches for current user
// @access  Private
router.get('/potential', authenticate, async (req, res) => {
  try {
    const currentUser = req.user;

    // Get all other users
    const allUsers = await User.find({ uid: { $ne: currentUser.uid } });

    // Filter for mutual matches
    const potentialMatches = allUsers.filter(user => isMutualMatch(currentUser, user));

    res.json({
      success: true,
      matches: potentialMatches.map(user => user.toJSON()),
      count: potentialMatches.length,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Failed to find potential matches',
      error: error.message,
    });
  }
});

// @route   POST /api/matches/create
// @desc    Create a match between current user and another user
// @access  Private
router.post(
  '/create',
  authenticate,
  [body('otherUserId').notEmpty()],
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

      const { otherUserId } = req.body;
      const currentUser = req.user;

      if (otherUserId === currentUser.uid) {
        return res.status(400).json({
          success: false,
          message: 'Cannot match with yourself',
        });
      }

      // Check if match already exists
      const existingMatch = await Match.findOne({
        $or: [
          { user1Id: currentUser.uid, user2Id: otherUserId },
          { user1Id: otherUserId, user2Id: currentUser.uid },
        ],
      });

      if (existingMatch) {
        return res.status(400).json({
          success: false,
          message: 'Match already exists',
          match: existingMatch,
        });
      }

      // Get other user
      const otherUser = await User.findOne({ uid: otherUserId });
      if (!otherUser) {
        return res.status(404).json({
          success: false,
          message: 'User not found',
        });
      }

      // Get common skills
      const commonSkills = getCommonSkills(currentUser, otherUser);

      // Create match
      const match = new Match({
        matchId: uuidv4(),
        user1Id: currentUser.uid,
        user2Id: otherUserId,
        commonSkills,
      });

      await match.save();

      res.status(201).json({
        success: true,
        message: 'Match created successfully',
        match: {
          matchId: match.matchId,
          user1Id: match.user1Id,
          user2Id: match.user2Id,
          commonSkills: match.commonSkills,
          matchedAt: match.matchedAt,
        },
        otherUser: otherUser.toJSON(),
      });
    } catch (error) {
      res.status(500).json({
        success: false,
        message: 'Failed to create match',
        error: error.message,
      });
    }
  }
);

// @route   GET /api/matches/my-matches
// @desc    Get all matches for current user
// @access  Private
router.get('/my-matches', authenticate, async (req, res) => {
  try {
    const currentUserId = req.user.uid;

    // Find all matches where user is either user1 or user2
    const matches = await Match.find({
      $or: [
        { user1Id: currentUserId },
        { user2Id: currentUserId },
      ],
    }).sort({ matchedAt: -1 });

    // Get user profiles for each match
    const matchedUsers = [];
    for (const match of matches) {
      const otherUserId = match.user1Id === currentUserId ? match.user2Id : match.user1Id;
      const otherUser = await User.findOne({ uid: otherUserId });

      if (otherUser) {
        matchedUsers.push({
          user: otherUser.toJSON(),
          match: {
            matchId: match.matchId,
            commonSkills: match.commonSkills,
            matchedAt: match.matchedAt,
          },
        });
      }
    }

    res.json({
      success: true,
      matches: matchedUsers,
      count: matchedUsers.length,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Failed to fetch matches',
      error: error.message,
    });
  }
});

// @route   GET /api/matches/common-skills/:otherUserId
// @desc    Get common skills between current user and another user
// @access  Private
router.get('/common-skills/:otherUserId', authenticate, async (req, res) => {
  try {
    const { otherUserId } = req.params;
    const currentUser = req.user;

    const otherUser = await User.findOne({ uid: otherUserId });
    if (!otherUser) {
      return res.status(404).json({
        success: false,
        message: 'User not found',
      });
    }

    const commonSkills = getCommonSkills(currentUser, otherUser);

    res.json({
      success: true,
      commonSkills,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Failed to get common skills',
      error: error.message,
    });
  }
});

module.exports = router;

