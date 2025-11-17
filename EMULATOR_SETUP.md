# Emulator Setup Guide

## Why Use Emulator?

✅ **Full Features:** Video calls, real-time chat, everything works
✅ **No Web Errors:** Socket.IO works perfectly
✅ **Easy Testing:** Test on multiple devices easily
✅ **Better Performance:** More like real device

## Option 1: Android Emulator (Easiest)

### Step 1: Install Android Studio
1. Download [Android Studio](https://developer.android.com/studio)
2. Install it
3. Open Android Studio

### Step 2: Set Up Emulator
1. Open Android Studio
2. Click **More Actions** → **Virtual Device Manager**
3. Click **Create Device**
4. Select **Phone** → **Pixel 5** (or any phone)
5. Click **Next**
6. Select **System Image** → **Latest API Level** (e.g., API 34)
7. Click **Download** if needed, then **Next**
8. Click **Finish**

### Step 3: Start Emulator
1. In Virtual Device Manager, click **Play** button (▶️) next to your device
2. Wait for emulator to boot (takes 1-2 minutes first time)

### Step 4: Run Flutter App
```bash
# Check if emulator is detected
flutter devices

# You should see something like:
# sdk gphone64 arm64 (mobile) • emulator-5554 • android-arm64

# Run the app
flutter run
```

## Option 2: iOS Simulator (Mac Only)

### Step 1: Install Xcode
1. Download from Mac App Store
2. Open Xcode
3. Accept license agreements

### Step 2: Open Simulator
1. Open Xcode
2. Go to **Xcode** → **Open Developer Tool** → **Simulator**
3. Or run: `open -a Simulator`

### Step 3: Choose Device
1. In Simulator: **File** → **Open Simulator** → **iOS** → **iPhone 14** (or any)

### Step 4: Run Flutter App
```bash
flutter run
# It will automatically detect iOS simulator
```

## Option 3: Physical Device (Best for Testing)

### Android Device:
1. Enable **Developer Options**:
   - Go to **Settings** → **About Phone**
   - Tap **Build Number** 7 times
2. Enable **USB Debugging**:
   - Go to **Settings** → **Developer Options**
   - Enable **USB Debugging**
3. Connect via USB
4. Run: `flutter run`

### iOS Device (Mac Only):
1. Connect iPhone via USB
2. Trust computer on iPhone
3. In Xcode: **Window** → **Devices and Simulators**
4. Select your device
5. Run: `flutter run`

## Quick Start (Android Emulator)

```bash
# 1. Start Android Studio
# 2. Open Virtual Device Manager
# 3. Start an emulator

# 4. In your project folder:
flutter devices  # Check emulator is detected
flutter run      # Run the app
```

## Update API URLs for Emulator

### For Android Emulator:
Edit `lib/services/api_service.dart`:
```dart
static const String baseUrl = 'http://10.0.2.2:3000/api';
```

Edit `lib/services/socket_service.dart`:
```dart
static const String socketUrl = 'http://10.0.2.2:3000';
```

**Note:** `10.0.2.2` is special - it points to your computer's localhost from Android emulator

### For iOS Simulator:
```dart
// Use localhost (same as web)
static const String baseUrl = 'http://localhost:3000/api';
static const String socketUrl = 'http://localhost:3000';
```

### For Physical Device:
```dart
// Use your computer's IP address
// Find IP: ipconfig (Windows) or ifconfig (Mac/Linux)
static const String baseUrl = 'http://192.168.1.100:3000/api';  // Replace with your IP
static const String socketUrl = 'http://192.168.1.100:3000';
```

## Troubleshooting

### Emulator Not Detected:
```bash
# Check Flutter doctor
flutter doctor

# Restart adb (Android)
adb kill-server
adb start-server

# Check devices
flutter devices
```

### Emulator Too Slow:
- Close other apps
- Increase RAM allocation in emulator settings
- Use a physical device instead

### Can't Connect to Backend:
- Make sure backend is running: `cd backend && npm run dev`
- Check API URL matches your setup
- For Android: Use `10.0.2.2:3000`
- For iOS: Use `localhost:3000`

## Recommended Setup

**For Development:**
- ✅ Android Emulator (easiest, works on all OS)
- ✅ Fast and reliable
- ✅ Easy to reset/restart

**For Testing:**
- ✅ Physical Device (most realistic)
- ✅ Better performance
- ✅ Test real-world scenarios

## Summary

1. **Install Android Studio** (or Xcode for Mac)
2. **Create/Start Emulator**
3. **Update API URLs** (10.0.2.2 for Android)
4. **Run:** `flutter run`
5. **Enjoy full features!** 🎉

