# Video Call System - Complete Guide

## How It Works

The video call system uses **Socket.IO** for real-time notifications and **Jitsi Meet** for the actual video calls.

### Call Flow:

1. **User A initiates call:**
   - Clicks video call button in chat
   - App creates a unique Jitsi room name
   - Sends notification to backend via Socket.IO

2. **Backend notifies User B:**
   - Backend receives call initiation
   - Sends `incoming_call` event to User B's Socket.IO room
   - User B's app receives notification

3. **User B sees incoming call screen:**
   - Full-screen notification with caller's info
   - Accept or Reject buttons

4. **If User B accepts:**
   - Backend notifies User A that call was accepted
   - Both users join the same Jitsi room
   - Jitsi Meet opens in browser/app

5. **If User B rejects:**
   - Backend notifies User A
   - Call ends, both return to chat

## Setup Instructions

### 1. Backend (Already Done ✅)

The backend Socket.IO server handles:
- `initiate_call` - When someone starts a call
- `accept_call` - When receiver accepts
- `reject_call` - When receiver rejects
- `end_call` - When call ends

### 2. Frontend Configuration

**Update Socket.IO URL** in `lib/services/socket_service.dart`:

```dart
// For Android Emulator:
static const String socketUrl = 'http://10.0.2.2:3000';

// For iOS Simulator:
static const String socketUrl = 'http://localhost:3000';

// For Physical Device:
static const String socketUrl = 'http://YOUR_COMPUTER_IP:3000';
```

**Important:** This should match your `api_service.dart` baseUrl (without `/api`)

### 3. Testing

1. **Start Backend:**
   ```bash
   cd backend
   npm run dev
   ```

2. **Run Flutter App on TWO devices/emulators:**
   - Device 1: Login as User A
   - Device 2: Login as User B
   - Make sure both are matched

3. **Test Call:**
   - User A: Open chat with User B → Click video call button
   - User B: Should see incoming call screen
   - User B: Click Accept
   - Both: Jitsi Meet should open

## Features

✅ **Real-time notifications** - Instant call alerts
✅ **Accept/Reject** - User can choose to answer
✅ **Call status** - Shows "Calling...", "Connecting...", etc.
✅ **Auto cleanup** - Calls cleaned up when ended
✅ **Disconnect handling** - Handles user disconnections gracefully

## Troubleshooting

### Call notification not received:
- Check Socket.IO connection (should see "✅ Socket.IO connected" in logs)
- Verify both users are logged in
- Check `socketUrl` matches backend URL
- Ensure backend is running

### Jitsi Meet not opening:
- Check internet connection
- Try opening Jitsi URL manually in browser
- For mobile: Ensure browser app is installed

### Call accepted but can't see each other:
- This is a Jitsi Meet issue, not our app
- Check camera/microphone permissions
- Try refreshing Jitsi page
- Check browser console for errors

## Socket.IO Events

### Client → Server:
- `join` - Join user room
- `initiate_call` - Start a call
- `accept_call` - Accept incoming call
- `reject_call` - Reject incoming call
- `end_call` - End active call

### Server → Client:
- `incoming_call` - Receive call notification
- `call_initiated` - Call started confirmation
- `call_accepted` - Call was accepted
- `call_rejected` - Call was rejected
- `call_ended` - Call ended
- `join_call` - Join Jitsi room (after accepting)

## Code Structure

- `backend/server.js` - Socket.IO server with call handling
- `lib/services/socket_service.dart` - Socket.IO client
- `lib/screens/video_call_screen.dart` - Caller's screen
- `lib/screens/incoming_call_screen.dart` - Receiver's screen
- `lib/main.dart` - Sets up incoming call listener

## Notes

- Jitsi Meet is free and doesn't require API keys
- Room names are unique per call
- Calls are stored in memory (not database)
- Multiple calls between same users create different rooms

