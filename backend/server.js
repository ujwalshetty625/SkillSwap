const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const http = require('http');
const socketIo = require('socket.io');
const path = require('path');
require('dotenv').config(); // load .env

const app = express();
const server = http.createServer(app);

// Socket.IO setup
const io = socketIo(server, {
  cors: {
    origin: process.env.CORS_ORIGIN?.split(',') || '*',
    methods: ['GET', 'POST'],
  },
});

// Store active calls: { callId: { callerId, receiverId, roomName, status } }
const activeCalls = new Map();

// Middleware
app.use(
  cors({
    origin: process.env.CORS_ORIGIN?.split(',') || '*',
    credentials: true,
  })
);
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Serve uploaded files
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// ===== MongoDB Connection (UPDATED) =====
const MONGO_URI =
  process.env.MONGO_URI ||
  process.env.MONGODB_URI || // fallback if you ever name it this on Render
  'mongodb://localhost:27017/skillocity';

mongoose
  .connect(MONGO_URI, {
    useNewUrlParser: true,
    useUnifiedTopology: true,
  })
  .then(() => console.log('✅ MongoDB connected'))
  .catch((err) => console.error('❌ MongoDB connection error:', err));

// Routes
app.use('/api/auth', require('./routes/auth'));
app.use('/api/users', require('./routes/users'));
app.use('/api/matches', require('./routes/matches'));
app.use('/api/messages', require('./routes/messages'));

// Health check
app.get('/api/health', (req, res) => {
  res.json({ status: 'ok', message: 'Skillocity API is running' });
});

// Socket.IO connection handling
io.on('connection', (socket) => {
  console.log('User connected:', socket.id);

  // Join user's personal room
  socket.on('join', (userId) => {
    socket.join(`user_${userId}`);
    socket.userId = userId; // Store userId on socket
    console.log(`User ${userId} joined their room`);
  });

  // Handle sending messages
  socket.on('send_message', async (data) => {
    try {
      const Message = require('./models/Message');
      const { senderId, receiverId, message } = data;

      // Save message to database
      const newMessage = new Message({
        senderId,
        receiverId,
        message,
      });
      await newMessage.save();

      // Emit to receiver
      io.to(`user_${receiverId}`).emit('receive_message', {
        id: newMessage._id.toString(),
        senderId,
        receiverId,
        message,
        timestamp: newMessage.timestamp,
        isRead: false,
      });

      // Confirm to sender
      socket.emit('message_sent', {
        id: newMessage._id.toString(),
        success: true,
      });
    } catch (error) {
      socket.emit('message_error', { error: error.message });
    }
  });

  // Handle typing indicator
  socket.on('typing', (data) => {
    socket.to(`user_${data.receiverId}`).emit('user_typing', {
      senderId: data.senderId,
      isTyping: data.isTyping,
    });
  });

  // Handle video call initiation
  socket.on('initiate_call', (data) => {
    const { callerId, receiverId, roomName } = data;
    const callId = `${callerId}_${receiverId}_${Date.now()}`;

    // Store call info
    activeCalls.set(callId, {
      callerId,
      receiverId,
      roomName,
      status: 'ringing',
      callId,
    });

    console.log(`📞 Call initiated: ${callerId} calling ${receiverId}`);
    console.log(`📞 Sending to room: user_${receiverId}`);
    console.log(
      `📞 Active rooms:`,
      Array.from(io.sockets.adapter.rooms.keys())
    );

    // Notify receiver
    io.to(`user_${receiverId}`).emit('incoming_call', {
      callId,
      callerId,
      callerName: data.callerName || 'Someone',
      roomName,
    });

    // Confirm to caller
    socket.emit('call_initiated', {
      callId,
      roomName,
      status: 'ringing',
    });

    console.log(`✅ Call notification sent to ${receiverId}`);
  });

  // Handle call acceptance
  socket.on('accept_call', (data) => {
    const { callId } = data;
    const call = activeCalls.get(callId);

    if (call) {
      call.status = 'accepted';
      activeCalls.set(callId, call);

      console.log(`✅ Call accepted: ${callId}`);
      console.log(`📞 Room name: ${call.roomName}`);
      console.log(`📞 Notifying caller: ${call.callerId}`);
      console.log(`📞 Notifying receiver: ${call.receiverId}`);

      // Notify BOTH users at the same time to join Jitsi
      const joinData = {
        callId,
        roomName: call.roomName,
        status: 'accepted',
      };

      // Notify caller
      io.to(`user_${call.callerId}`).emit('call_accepted', joinData);

      // Notify receiver
      io.to(`user_${call.receiverId}`).emit('call_accepted', joinData);

      console.log(
        `✅ Both users notified to join Jitsi room: ${call.roomName}`
      );
    } else {
      console.log(`❌ Call not found: ${callId}`);
    }
  });

  // Handle call rejection
  socket.on('reject_call', (data) => {
    const { callId } = data;
    const call = activeCalls.get(callId);

    if (call) {
      call.status = 'rejected';
      activeCalls.set(callId, call);

      // Notify caller
      io.to(`user_${call.callerId}`).emit('call_rejected', {
        callId,
      });

      // Clean up after 5 seconds
      setTimeout(() => {
        activeCalls.delete(callId);
      }, 5000);

      console.log(`Call rejected: ${callId}`);
    }
  });

  // Handle call end
  socket.on('end_call', (data) => {
    const { callId } = data;
    const call = activeCalls.get(callId);

    if (call) {
      // Notify both parties
      io.to(`user_${call.callerId}`).emit('call_ended', { callId });
      io.to(`user_${call.receiverId}`).emit('call_ended', { callId });

      // Clean up
      activeCalls.delete(callId);
      console.log(`Call ended: ${callId}`);
    }
  });

  socket.on('disconnect', () => {
    console.log('User disconnected:', socket.id);
    // Clean up any calls from this user
    for (const [callId, call] of activeCalls.entries()) {
      if (call.callerId === socket.userId || call.receiverId === socket.userId) {
        if (call.status === 'ringing') {
          // Notify the other party
          const otherUserId =
            call.callerId === socket.userId ? call.receiverId : call.callerId;
          io.to(`user_${otherUserId}`).emit('call_ended', { callId });
        }
        activeCalls.delete(callId);
      }
    }
  });
});

// Error handling middleware
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({
    success: false,
    message: 'Something went wrong!',
    error:
      process.env.NODE_ENV === 'development' ? err.message : undefined,
  });
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({
    success: false,
    message: 'Route not found',
  });
});

const PORT = process.env.PORT || 3000;
server.listen(PORT, () => {
  console.log(`🚀 Server running on port ${PORT}`);
  console.log(`📡 Socket.IO server ready`);
});
