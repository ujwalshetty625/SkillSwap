# Skillocity Backend API

A complete REST API backend for the Skillocity skill exchange platform, built with Node.js, Express, MongoDB, and Socket.IO.

## Features

- 🔐 **Authentication**: JWT-based authentication with signup, login, logout, and password reset
- 👤 **User Management**: Profile creation, updates, and photo uploads
- 🔍 **Matching System**: Find potential matches based on mutual skill exchange
- 💬 **Real-time Chat**: WebSocket-based messaging with Socket.IO
- 📁 **File Uploads**: Profile photo uploads with Multer
- 🛡️ **Security**: Password hashing with bcrypt, JWT tokens, input validation

## Prerequisites

- Node.js (v14 or higher)
- MongoDB (local or cloud instance like MongoDB Atlas)
- npm or yarn

## Installation

1. **Clone the repository and navigate to backend folder:**
   ```bash
   cd backend
   ```

2. **Install dependencies:**
   ```bash
   npm install
   ```

3. **Set up environment variables:**
   ```bash
   cp .env.example .env
   ```
   
   Edit `.env` and update the following:
   - `MONGODB_URI`: Your MongoDB connection string
   - `JWT_SECRET`: A strong secret key for JWT tokens
   - `PORT`: Server port (default: 3000)
   - `CORS_ORIGIN`: Allowed origins (comma-separated)

4. **Start MongoDB:**
   - If using local MongoDB: `mongod`
   - If using MongoDB Atlas: Update `MONGODB_URI` in `.env`

5. **Run the server:**
   ```bash
   # Development mode (with auto-reload)
   npm run dev

   # Production mode
   npm start
   ```

The server will start on `http://localhost:3000` (or your configured PORT).

## API Endpoints

### Authentication

- `POST /api/auth/signup` - Register a new user
- `POST /api/auth/login` - Login user
- `POST /api/auth/logout` - Logout user
- `GET /api/auth/me` - Get current user
- `POST /api/auth/reset-password` - Request password reset

### Users

- `GET /api/users/me` - Get current user profile
- `PUT /api/users/me` - Update current user profile
- `POST /api/users/me/photo` - Upload profile photo
- `GET /api/users/profile/:uid` - Get user profile by UID
- `GET /api/users/all` - Get all users (except current user)

### Matches

- `GET /api/matches/potential` - Find potential matches
- `POST /api/matches/create` - Create a match with another user
- `GET /api/matches/my-matches` - Get all matches for current user
- `GET /api/matches/common-skills/:otherUserId` - Get common skills

### Messages

- `POST /api/messages/send` - Send a message
- `GET /api/messages/:otherUserId` - Get messages with a user
- `GET /api/messages/conversations/list` - Get all conversations

### Health Check

- `GET /api/health` - Check API status

## WebSocket Events (Socket.IO)

### Client → Server

- `join` - Join user's personal room: `socket.emit('join', userId)`
- `send_message` - Send a message: `socket.emit('send_message', { senderId, receiverId, message })`
- `typing` - Send typing indicator: `socket.emit('typing', { senderId, receiverId, isTyping })`

### Server → Client

- `receive_message` - Receive a new message
- `message_sent` - Confirmation that message was sent
- `message_error` - Error sending message
- `user_typing` - User is typing indicator

## Request/Response Examples

### Sign Up

**Request:**
```json
POST /api/auth/signup
{
  "email": "user@example.com",
  "password": "password123",
  "name": "John Doe"
}
```

**Response:**
```json
{
  "success": true,
  "message": "User created successfully",
  "user": {
    "uid": "uuid-here",
    "email": "user@example.com",
    "name": "John Doe",
    "bio": "",
    "skillsToTeach": [],
    "skillsToLearn": [],
    "photoUrl": null,
    "createdAt": "2024-01-01T00:00:00.000Z",
    "lastActive": "2024-01-01T00:00:00.000Z"
  },
  "token": "jwt-token-here"
}
```

### Login

**Request:**
```json
POST /api/auth/login
{
  "email": "user@example.com",
  "password": "password123"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Login successful",
  "user": { ... },
  "token": "jwt-token-here"
}
```

### Update Profile

**Request:**
```json
PUT /api/users/me
Authorization: Bearer <token>
{
  "name": "John Doe",
  "bio": "I love coding!",
  "skillsToTeach": ["JavaScript", "React"],
  "skillsToLearn": ["Python", "Machine Learning"]
}
```

### Upload Photo

**Request:**
```
POST /api/users/me/photo
Authorization: Bearer <token>
Content-Type: multipart/form-data

photo: <file>
```

### Find Matches

**Request:**
```
GET /api/matches/potential
Authorization: Bearer <token>
```

**Response:**
```json
{
  "success": true,
  "matches": [
    {
      "uid": "user-uuid",
      "name": "Jane Smith",
      "email": "jane@example.com",
      "bio": "UI/UX Designer",
      "skillsToTeach": ["Figma", "Adobe XD"],
      "skillsToLearn": ["JavaScript", "React"],
      ...
    }
  ],
  "count": 1
}
```

### Send Message

**Request:**
```json
POST /api/messages/send
Authorization: Bearer <token>
{
  "receiverId": "other-user-uuid",
  "message": "Hello! Want to exchange skills?"
}
```

## Authentication

All protected routes require a JWT token in the Authorization header:

```
Authorization: Bearer <your-jwt-token>
```

The token is returned on signup/login and should be stored client-side.

## Database Schema

### User
- `uid` (String, unique) - User identifier
- `email` (String, unique) - User email
- `password` (String, hashed) - User password
- `name` (String) - User name
- `bio` (String) - User bio
- `skillsToTeach` (Array) - Skills user can teach
- `skillsToLearn` (Array) - Skills user wants to learn
- `photoUrl` (String) - Profile photo URL
- `createdAt` (Date) - Account creation date
- `lastActive` (Date) - Last active timestamp

### Message
- `senderId` (String) - Sender user ID
- `receiverId` (String) - Receiver user ID
- `message` (String) - Message content
- `isRead` (Boolean) - Read status
- `timestamp` (Date) - Message timestamp

### Match
- `matchId` (String, unique) - Match identifier
- `user1Id` (String) - First user ID
- `user2Id` (String) - Second user ID
- `commonSkills` (Array) - Common skills between users
- `matchedAt` (Date) - Match creation date

## File Uploads

Profile photos are uploaded to the `uploads/` directory and served at `/uploads/<filename>`.

Supported formats: JPEG, JPG, PNG, GIF, WEBP
Max file size: 5MB (configurable via `MAX_FILE_SIZE` in `.env`)

## Error Handling

All errors follow this format:

```json
{
  "success": false,
  "message": "Error message",
  "error": "Detailed error (development only)"
}
```

## Development

- Use `npm run dev` for development with auto-reload (requires nodemon)
- Use `npm start` for production
- Check logs in the console for debugging

## Production Deployment

1. Set `NODE_ENV=production` in `.env`
2. Use a strong `JWT_SECRET`
3. Configure proper `CORS_ORIGIN` for your frontend domain
4. Use a production MongoDB instance (MongoDB Atlas recommended)
5. Set up proper file storage (consider using cloud storage like AWS S3)
6. Use a process manager like PM2: `pm2 start server.js`

## Troubleshooting

### MongoDB Connection Error
- Ensure MongoDB is running
- Check `MONGODB_URI` in `.env`
- Verify network connectivity

### JWT Token Errors
- Check `JWT_SECRET` is set in `.env`
- Ensure token is sent in Authorization header
- Verify token hasn't expired

### File Upload Errors
- Check `uploads/` directory exists and is writable
- Verify file size is within limits
- Ensure file is an image format

## License

ISC

