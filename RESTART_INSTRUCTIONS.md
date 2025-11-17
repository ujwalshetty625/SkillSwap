# Do I Need to Restart? 🔄

## YES! You Need to Restart Both Backend and Frontend

After the changes we made (especially adding Socket.IO for video calls), you need to restart everything.

## Step-by-Step Restart Instructions

### 1. Stop Current Backend (if running)
- Press `Ctrl + C` in the terminal where backend is running
- Or close the terminal window

### 2. Stop Current Frontend (if running)
- Press `Ctrl + C` in the terminal where Flutter is running
- Or press `q` in the Flutter console

### 3. Restart Backend

```bash
# Navigate to backend folder
cd backend

# Install new dependencies (if any)
npm install

# Start the server
npm run dev
```

**You should see:**
```
✅ MongoDB connected
🚀 Server running on port 3000
📡 Socket.IO server ready
```

### 4. Restart Frontend

```bash
# Make sure you're in the project root (not backend folder)
cd ..  # if you're in backend folder

# Get new dependencies
flutter pub get

# Run the app
flutter run
```

**Or if you want to run on a specific device:**
```bash
# See available devices
flutter devices

# Run on specific device
flutter run -d <device-id>
```

## Why Restart?

We made these changes that require restart:

1. ✅ **Backend:** Added Socket.IO call handling
2. ✅ **Frontend:** Added Socket.IO service
3. ✅ **Frontend:** Added incoming call screen
4. ✅ **Frontend:** Updated video call flow
5. ✅ **Frontend:** Added new dependencies (socket_io_client)

## Quick Checklist

- [ ] Backend stopped
- [ ] Backend restarted (`npm run dev`)
- [ ] Backend shows "Socket.IO server ready"
- [ ] Frontend stopped
- [ ] Frontend dependencies updated (`flutter pub get`)
- [ ] Frontend restarted (`flutter run`)
- [ ] App loads successfully

## Testing After Restart

1. **Login** with an account
2. **Check Socket.IO connection:**
   - Look for "✅ Socket.IO connected" in Flutter logs
   - Or check backend logs for "User connected"

3. **Test Video Call:**
   - Login on TWO devices/emulators
   - Match two users
   - Start a video call from one device
   - Other device should show incoming call screen

## Troubleshooting

### Backend won't start:
```bash
# Make sure MongoDB is running
# Windows: Check Services
# Mac/Linux: sudo systemctl start mongod

# Check if port 3000 is available
# Or change PORT in .env file
```

### Frontend won't start:
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter run
```

### Socket.IO not connecting:
- Check `socketUrl` in `lib/services/socket_service.dart`
- Should match your backend URL
- For Android emulator: `http://10.0.2.2:3000`
- For iOS simulator: `http://localhost:3000`
- For physical device: `http://YOUR_COMPUTER_IP:3000`

## Summary

**YES, restart both!** The new video call features need the updated code running.

