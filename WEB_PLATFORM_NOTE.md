# Web Platform Support

## Current Status

⚠️ **Socket.IO video calls are NOT supported on Flutter Web** due to compatibility issues with the `socket_io_client` package.

## What Works on Web:
- ✅ Authentication (login/signup)
- ✅ User profiles
- ✅ Matching
- ✅ Chat messages (via REST API)
- ✅ All other features

## What Doesn't Work on Web:
- ❌ Real-time video calls (Socket.IO issues)
- ❌ Real-time chat updates (uses polling instead)

## Solutions:

### Option 1: Use Mobile/Desktop (Recommended)
- Run on Android/iOS emulator
- Run on physical device
- Run on desktop (Windows/Mac/Linux) - NOT web

### Option 2: For Web Development
If you need to test on web:
1. Video calls will be disabled automatically
2. Chat will work but without real-time updates
3. All other features work normally

### Option 3: Future Fix
To enable web support, we would need to:
- Use a different WebSocket library for web
- Or implement REST API polling for calls
- Or use a web-compatible Socket.IO alternative

## Running the App:

### Mobile/Desktop (Full Features):
```bash
flutter run
# Select Android/iOS/Desktop device
```

### Web (Limited Features):
```bash
flutter run -d chrome
# Video calls disabled, chat uses polling
```

## Error Fix:

The error you saw was because Socket.IO tried to initialize on web. Now it's fixed:
- Web: Socket.IO is skipped (no errors)
- Mobile/Desktop: Socket.IO works normally

## Summary:

✅ **Fixed:** Web platform errors resolved
⚠️ **Note:** Video calls work on mobile/desktop, not web
✅ **Workaround:** Use mobile/desktop for full features

