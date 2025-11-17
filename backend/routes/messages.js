const express = require('express');
const { body, validationResult } = require('express-validator');
const Message = require('../models/Message');
const User = require('../models/User');
const Match = require('../models/Match');
const { authenticate } = require('../middleware/auth');

const router = express.Router();

// Helper function to create consistent chat room ID
const getChatRoomId = (userId1, userId2) => {
  const ids = [userId1, userId2].sort();
  return `${ids[0]}_${ids[1]}`;
};

// @route   POST /api/messages/send
// @desc    Send a message
// @access  Private
router.post(
  '/send',
  authenticate,
  [
    body('receiverId').notEmpty(),
    body('message').trim().notEmpty(),
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

      const { receiverId, message } = req.body;
      const senderId = req.user.uid;

      // Verify users are matched (optional - you can remove this if you want to allow messaging without matching)
      const match = await Match.findOne({
        $or: [
          { user1Id: senderId, user2Id: receiverId },
          { user1Id: receiverId, user2Id: senderId },
        ],
      });

      // Uncomment if you want to require matching before messaging
      // if (!match) {
      //   return res.status(403).json({
      //     success: false,
      //     message: 'You can only message matched users',
      //   });
      // }

      // Create message
      const newMessage = new Message({
        senderId,
        receiverId,
        message,
      });

      await newMessage.save();

      res.status(201).json({
        success: true,
        message: 'Message sent successfully',
        data: {
          id: newMessage._id.toString(),
          senderId: newMessage.senderId,
          receiverId: newMessage.receiverId,
          message: newMessage.message,
          timestamp: newMessage.timestamp,
          isRead: newMessage.isRead,
        },
      });
    } catch (error) {
      res.status(500).json({
        success: false,
        message: 'Failed to send message',
        error: error.message,
      });
    }
  }
);

// @route   GET /api/messages/:otherUserId
// @desc    Get messages between current user and another user
// @access  Private
router.get('/:otherUserId', authenticate, async (req, res) => {
  try {
    const { otherUserId } = req.params;
    const currentUserId = req.user.uid;

    // Get messages where current user is sender or receiver
    const messages = await Message.find({
      $or: [
        { senderId: currentUserId, receiverId: otherUserId },
        { senderId: otherUserId, receiverId: currentUserId },
      ],
    })
      .sort({ timestamp: -1 })
      .limit(100); // Limit to last 100 messages

    // Mark messages as read
    await Message.updateMany(
      {
        senderId: otherUserId,
        receiverId: currentUserId,
        isRead: false,
      },
      { isRead: true }
    );

    res.json({
      success: true,
      messages: messages.map(msg => ({
        id: msg._id.toString(),
        senderId: msg.senderId,
        receiverId: msg.receiverId,
        message: msg.message,
        timestamp: msg.timestamp,
        isRead: msg.isRead,
      })),
      count: messages.length,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Failed to fetch messages',
      error: error.message,
    });
  }
});

// @route   GET /api/messages/conversations/list
// @desc    Get list of all conversations for current user
// @access  Private
router.get('/conversations/list', authenticate, async (req, res) => {
  try {
    const currentUserId = req.user.uid;

    // Get distinct conversation partners
    const sentMessages = await Message.distinct('receiverId', {
      senderId: currentUserId,
    });

    const receivedMessages = await Message.distinct('senderId', {
      receiverId: currentUserId,
    });

    const allPartners = [...new Set([...sentMessages, ...receivedMessages])];

    // Get last message for each conversation
    const conversations = await Promise.all(
      allPartners.map(async (partnerId) => {
        const lastMessage = await Message.findOne({
          $or: [
            { senderId: currentUserId, receiverId: partnerId },
            { senderId: partnerId, receiverId: currentUserId },
          ],
        })
          .sort({ timestamp: -1 })
          .limit(1);

        const partner = await User.findOne({ uid: partnerId });

        return {
          partner: partner ? partner.toJSON() : null,
          lastMessage: lastMessage
            ? {
                id: lastMessage._id.toString(),
                message: lastMessage.message,
                timestamp: lastMessage.timestamp,
                isRead: lastMessage.isRead,
                senderId: lastMessage.senderId,
              }
            : null,
        };
      })
    );

    // Sort by last message timestamp
    conversations.sort((a, b) => {
      if (!a.lastMessage) return 1;
      if (!b.lastMessage) return -1;
      return b.lastMessage.timestamp - a.lastMessage.timestamp;
    });

    res.json({
      success: true,
      conversations,
      count: conversations.length,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Failed to fetch conversations',
      error: error.message,
    });
  }
});

module.exports = router;

