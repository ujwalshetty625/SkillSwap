# Skillocity - Complete Setup Guide

This guide will help you set up both the backend and frontend for the Skillocity skill exchange platform.

## Prerequisites

- Node.js (v14 or higher) and npm
- MongoDB (local installation or MongoDB Atlas account)
- Flutter SDK (3.0 or higher)
- Android Studio / Xcode (for mobile development)

## Backend Setup

### 1. Navigate to Backend Directory

```bash
cd backend
```

### 2. Install Dependencies

```bash
npm install
```

### 3. Configure Environment Variables

Create a `.env` file in the `backend` directory (or copy from `.env.example`):

```env
PORT=3000
NODE_ENV=development

# MongoDB Connection
# For local MongoDB:
MONGODB_URI=mongodb://localhost:27017/skillocity
# For MongoDB Atlas:
# MONGODB_URI=mongodb+srv://username:password@cluster.mongodb.net/skillocity

# JWT Secret (change this to a strong random string)
JWT_SECRET=your-super-secret-jwt-key-change-this-in-production
JWT_EXPIRE=7d

# File Upload
MAX_FILE_SIZE=5242880
UPLOAD_PATH=./uploads

# CORS (add your Flutter app URLs)
CORS_ORIGIN=http://localhost:3000,http://localhost:8080
```

### 4. Start MongoDB

**Local MongoDB:**
```bash
# On macOS/Linux
mongod

# On Windows
# Start MongoDB service from Services or run:
mongod.exe
```

**MongoDB Atlas:**
- Create a free cluster at [MongoDB Atlas](https://www.mongodb.com/cloud/atlas)
- Get your connection string and update `MONGODB_URI` in `.env`

### 5. Start the Backend Server

```bash
# Development mode (with auto-reload)
npm run dev

# Production mode
npm start
```

The backend will start on `http://localhost:3000`

### 6. Verify Backend is Running

Open your browser and visit: `http://localhost:3000/api/health`

You should see:
```json
{"status":"ok","message":"Skillocity API is running"}
```

## Frontend Setup

### 1. Install Flutter Dependencies

From the project root directory:

```bash
flutter pub get
```

### 2. Configure API Endpoint

Edit `lib/services/api_service.dart` and update the `baseUrl`:

```dart
// For Android Emulator:
static const String baseUrl = 'http://10.0.2.2:3000/api';

// For iOS Simulator:
static const String baseUrl = 'http://localhost:3000/api';

// For Physical Device (use your computer's IP):
// Find your IP: ipconfig (Windows) or ifconfig (Mac/Linux)
static const String baseUrl = 'http://192.168.1.100:3000/api'; // Replace with your IP
```

### 3. Run the Flutter App

```bash
# For Android
flutter run

# For iOS
flutter run

# For Web
flutter run -d chrome
```

## Testing the Setup

### 1. Test Backend API

You can test the API using curl or Postman:

**Sign Up:**
```bash
curl -X POST http://localhost:3000/api/auth/signup \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123",
    "name": "Test User"
  }'
```

**Login:**
```bash
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123"
  }'
```

### 2. Test Flutter App

1. Open the app
2. Sign up with a new account
3. Complete your profile (add skills to teach and learn)
4. Browse potential matches
5. Create a match
6. Send messages

## Common Issues & Solutions

### Backend Issues

**MongoDB Connection Error:**
- Ensure MongoDB is running
- Check `MONGODB_URI` in `.env`
- For MongoDB Atlas, whitelist your IP address

**Port Already in Use:**
- Change `PORT` in `.env` to a different port (e.g., 3001)
- Update Flutter `api_service.dart` to match

**JWT Token Errors:**
- Ensure `JWT_SECRET` is set in `.env`
- Restart the server after changing `.env`

### Frontend Issues

**Connection Refused:**
- Check backend is running
- Verify `baseUrl` in `api_service.dart` matches your setup
- For physical devices, ensure phone and computer are on same network
- Check firewall settings

**CORS Errors:**
- Add your Flutter app URL to `CORS_ORIGIN` in backend `.env`
- Restart backend server

**Token Not Persisting:**
- Ensure `shared_preferences` package is installed
- Run `flutter pub get` again

### Network Configuration for Physical Devices

1. **Find your computer's IP address:**
   - Windows: `ipconfig` (look for IPv4 Address)
   - Mac/Linux: `ifconfig` or `ip addr`

2. **Update Flutter API service:**
   ```dart
   static const String baseUrl = 'http://YOUR_IP:3000/api';
   ```

3. **Ensure both devices are on the same network**

4. **Test connection:**
   - Open `http://YOUR_IP:3000/api/health` in phone's browser
   - Should show the health check JSON

## Project Structure

```
SkillocityExchange/
├── backend/
│   ├── models/          # MongoDB models
│   ├── routes/          # API routes
│   ├── middleware/      # Auth & upload middleware
│   ├── uploads/         # Uploaded files
│   ├── server.js        # Main server file
│   └── package.json     # Dependencies
│
├── lib/
│   ├── models/          # Data models
│   ├── services/        # API services
│   ├── screens/         # UI screens
│   └── widgets/         # Reusable widgets
│
└── pubspec.yaml        # Flutter dependencies
```

## API Endpoints Reference

### Authentication
- `POST /api/auth/signup` - Register new user
- `POST /api/auth/login` - Login user
- `POST /api/auth/logout` - Logout user
- `GET /api/auth/me` - Get current user

### Users
- `GET /api/users/me` - Get current user profile
- `PUT /api/users/me` - Update profile
- `POST /api/users/me/photo` - Upload profile photo
- `GET /api/users/all` - Get all users

### Matches
- `GET /api/matches/potential` - Find potential matches
- `POST /api/matches/create` - Create a match
- `GET /api/matches/my-matches` - Get user's matches

### Messages
- `POST /api/messages/send` - Send message
- `GET /api/messages/:otherUserId` - Get messages

## Video Call Setup

The app includes a complete video call system using Socket.IO and Jitsi Meet. See `VIDEO_CALL_SETUP.md` for detailed instructions.

**Quick Setup:**
1. Update `socketUrl` in `lib/services/socket_service.dart` to match your backend URL
2. Ensure Socket.IO is connected (automatic on login)
3. Test by initiating a call between two users

## Next Steps

1. **Customize the backend:**
   - Add email verification
   - Implement password reset
   - Add push notifications
   - Set up cloud storage for images

2. **Enhance the frontend:**
   - Implement push notifications for calls
   - Add image caching
   - Improve error handling

3. **Deploy:**
   - Backend: Deploy to Heroku, AWS, or DigitalOcean
   - Frontend: Build and publish to App Store / Play Store

## Support

If you encounter issues:
1. Check the console logs (both backend and Flutter)
2. Verify all environment variables are set correctly
3. Ensure MongoDB is running and accessible
4. Check network connectivity between devices

## License

ISC

