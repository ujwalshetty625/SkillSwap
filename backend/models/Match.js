const mongoose = require('mongoose');

const matchSchema = new mongoose.Schema({
  matchId: {
    type: String,
    required: true,
    unique: true,
  },
  user1Id: {
    type: String,
    required: true,
    ref: 'User',
  },
  user2Id: {
    type: String,
    required: true,
    ref: 'User',
  },
  commonSkills: {
    type: [String],
    default: [],
  },
  matchedAt: {
    type: Date,
    default: Date.now,
  },
}, {
  timestamps: true,
});

// Index for efficient querying
matchSchema.index({ user1Id: 1, user2Id: 1 });

module.exports = mongoose.model('Match', matchSchema);

