# Quick Emulator Setup (5 Minutes)

## ✅ Yes, Use Emulator for Full Features!

## Step-by-Step:

### 1. Install Android Studio
- Download: https://developer.android.com/studio
- Install it (takes 5-10 minutes)

### 2. Create Emulator
1. Open Android Studio
2. Click **More Actions** (bottom right)
3. Click **Virtual Device Manager**
4. Click **Create Device** (top left)
5. Select **Phone** → **Pixel 5** → **Next**
6. Click **Download** next to latest API (e.g., "Tiramisu" API 33)
7. Wait for download, then **Next** → **Finish**

### 3. Start Emulator
1. In Virtual Device Manager, click **▶️ Play** button
2. Wait 1-2 minutes (first time is slow)

### 4. Run Your App
```bash
# In your project folder:
flutter devices  # Should show your emulator
flutter run      # Run the app!
```

## ✅ Done! 

The app will automatically:
- ✅ Use correct API URL (`10.0.2.2:3000` for Android)
- ✅ Connect to Socket.IO properly
- ✅ Enable video calls
- ✅ All features work!

## If Emulator Not Detected:

```bash
# Check Flutter setup
flutter doctor

# Restart adb
adb kill-server
adb start-server

# Check again
flutter devices
```

## For Physical Device:

If you want to use your phone instead:
1. Enable Developer Options (tap Build Number 7 times)
2. Enable USB Debugging
3. Connect via USB
4. Run: `flutter run`

**Note:** For physical device, you'll need to change API URL to your computer's IP address (see `EMULATOR_SETUP.md`)

## That's It! 🎉

Now you can test video calls and all features properly!

