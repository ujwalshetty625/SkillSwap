# Video Call Debugging Guide

## Issue: Receiver Not Getting Call Notification

### Symptoms:
- Caller sees "Calling..." screen ✅
- Receiver doesn't see incoming call screen ❌
- Backend shows users connected ✅

### Debugging Steps:

1. **Check Socket.IO Connection:**
   - Look for "✅ Socket.IO connected" in Flutter logs
   - Check backend logs for "User [userId] joined their room"
   - Both users should be connected

2. **Check Backend Logs:**
   When caller initiates call, you should see:
   ```
   📞 Call initiated: [callerId] calling [receiverId]
   📞 Sending to room: user_[receiverId]
   ✅ Call notification sent to [receiverId]
   ```

3. **Check Flutter Logs:**
   When receiver should get call, look for:
   ```
   📞 Incoming call event received: {callId: ..., callerId: ..., ...}
   ```

4. **Verify User IDs:**
   - Make sure receiver's userId matches what caller is sending
   - Check both users are logged in with different accounts

### Common Issues:

#### Issue 1: Socket Not Connected on Receiver
**Solution:** Ensure receiver's app has Socket.IO connected
- Check `socketUrl` in `socket_service.dart`
- Should match backend URL
- For Android emulator: `http://10.0.2.2:3000`
- For iOS simulator: `http://localhost:3000`

#### Issue 2: Listener Not Set Up
**Solution:** Listener is set up in DashboardScreen
- Make sure receiver navigated to dashboard after login
- Listener is set in `initState()` of DashboardScreen

#### Issue 3: Wrong User ID
**Solution:** Verify user IDs match
- Check backend logs for actual user IDs
- Make sure caller is using correct receiverId

#### Issue 4: Navigation Context Lost
**Solution:** Using global navigator key
- Fixed in latest code
- Uses `navigatorKey` for navigation from anywhere

### Testing Checklist:

- [ ] Both users logged in
- [ ] Both users connected to Socket.IO (check logs)
- [ ] Both users joined their rooms (check backend logs)
- [ ] Caller initiates call
- [ ] Backend receives `initiate_call` event
- [ ] Backend sends `incoming_call` to receiver's room
- [ ] Receiver's app receives `incoming_call` event
- [ ] Navigation happens to IncomingCallScreen

### Manual Test:

1. **On Receiver Device:**
   - Open Flutter app
   - Login
   - Go to dashboard
   - Check logs for "✅ Socket.IO connected"
   - Check logs for "User [userId] joined their room"

2. **On Caller Device:**
   - Open Flutter app
   - Login
   - Go to chat with receiver
   - Click video call button
   - Check backend logs for call initiation

3. **Check Backend:**
   - Should see call initiated
   - Should see notification sent to receiver's room
   - Check if receiver's room exists: `user_[receiverId]`

### Quick Fix:

If still not working, add this debug code in `socket_service.dart`:

```dart
_socket!.onConnect((_) {
  print('✅ Socket.IO connected');
  print('📡 Socket ID: ${_socket!.id}');
  join(userId);
});

_socket!.on('incoming_call', (data) {
  print('📞 RAW incoming_call event: $data');
  print('📞 Data type: ${data.runtimeType}');
  callback(Map<String, dynamic>.from(data));
});
```

This will help identify if the event is being received but not processed correctly.

