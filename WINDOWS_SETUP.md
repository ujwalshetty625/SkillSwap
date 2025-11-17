# Windows Setup - Use Android Emulator

## The Issue:
Windows desktop requires Visual Studio (large download, complex setup).  
**Better option:** Use Android Emulator (easier, works great!)

## Quick Solution: Android Emulator

### Step 1: Install Android Studio
1. Download: https://developer.android.com/studio
2. Install it (includes everything you need)
3. Open Android Studio

### Step 2: Create Android Emulator
1. In Android Studio, click **More Actions** (bottom)
2. Click **Virtual Device Manager**
3. Click **Create Device** (top left)
4. Select **Phone** → **Pixel 5** → **Next**
5. Click **Download** next to latest API (e.g., "Tiramisu" API 33)
6. Wait for download → **Next** → **Finish**

### Step 3: Start Emulator
1. Click **▶️ Play** button next to your device
2. Wait 1-2 minutes (first time)

### Step 4: Run Flutter
```bash
flutter devices  # Should show Android emulator
flutter run      # Select Android emulator
```

## Alternative: Use Physical Android Phone

### Quick Setup:
1. Enable Developer Options:
   - Settings → About Phone
   - Tap "Build Number" 7 times
2. Enable USB Debugging:
   - Settings → Developer Options
   - Enable "USB Debugging"
3. Connect phone via USB
4. Run: `flutter run`

**Note:** For physical device, you'll need to update API URL to your computer's IP:
- Find your IP: `ipconfig` in PowerShell
- Look for "IPv4 Address" (e.g., 192.168.1.100)
- Update in `lib/services/api_service.dart` and `socket_service.dart`

## If You Really Want Windows Desktop:

You need Visual Studio:
1. Download Visual Studio Community (free)
2. Install "Desktop development with C++" workload
3. This is a 5-10 GB download and takes time

**Recommendation:** Just use Android emulator - it's much easier! 😊

## Summary:

✅ **Easiest:** Android Emulator (recommended)
✅ **Also Easy:** Physical Android Phone
❌ **Complex:** Windows Desktop (needs Visual Studio)

Go with Android emulator - it works perfectly for testing!

