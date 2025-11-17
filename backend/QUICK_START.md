# Quick Start Guide

## Backend Setup (5 minutes)

1. **Install dependencies:**
   ```bash
   cd backend
   npm install
   ```

2. **Set up environment:**
   ```bash
   # Copy .env.example to .env and update if needed
   # Default settings work for local development
   ```

3. **Start MongoDB:**
   ```bash
   # Make sure MongoDB is running locally
   # Or update MONGODB_URI in .env for MongoDB Atlas
   ```

4. **Start the server:**
   ```bash
   npm run dev
   ```

   Server runs on `http://localhost:3000`

## Frontend Setup (5 minutes)

1. **Install Flutter dependencies:**
   ```bash
   flutter pub get
   ```

2. **Configure API URL:**
   - Edit `lib/services/api_service.dart`
   - Update `baseUrl` for your platform:
     - Android Emulator: `http://10.0.2.2:3000/api`
     - iOS Simulator: `http://localhost:3000/api`
     - Physical Device: `http://YOUR_COMPUTER_IP:3000/api`

3. **Run the app:**
   ```bash
   flutter run
   ```

## Test It Out

1. Sign up with a new account
2. Complete your profile (add skills)
3. Browse potential matches
4. Create matches and start chatting!

## Troubleshooting

**Backend won't start:**
- Check MongoDB is running
- Verify PORT 3000 is available
- Check `.env` file exists

**Frontend can't connect:**
- Verify backend is running (`http://localhost:3000/api/health`)
- Check `baseUrl` in `api_service.dart`
- For physical devices, ensure same WiFi network

**Need help?** See `SETUP_GUIDE.md` for detailed instructions.

