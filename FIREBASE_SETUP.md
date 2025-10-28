# Firebase Setup Guide for Skillocity

This guide will help you set up Firebase for the Skillocity app.

## Prerequisites
- A Google account
- Flutter SDK installed
- Android Studio or Xcode (for mobile development)

## Step 1: Create a Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project" or "Create a project"
3. Enter project name: **Skillocity** (or your preferred name)
4. Click "Continue"
5. (Optional) Enable Google Analytics
6. Click "Create project"

## Step 2: Register Your Apps

### For Android:

1. In Firebase Console, click the Android icon to add an Android app
2. Enter package name: `com.skillocity.app`
3. (Optional) Enter app nickname: "Skillocity Android"
4. Click "Register app"
5. Download `google-services.json`
6. Place it in: `android/app/google-services.json`

### For iOS:

1. In Firebase Console, click the iOS icon to add an iOS app
2. Enter bundle ID: `com.skillocity.app`
3. (Optional) Enter app nickname: "Skillocity iOS"
4. Click "Register app"
5. Download `GoogleService-Info.plist`
6. Place it in: `ios/Runner/GoogleService-Info.plist`

## Step 3: Enable Firebase Services

### Authentication:

1. In Firebase Console, go to **Build** → **Authentication**
2. Click "Get started"
3. Enable **Email/Password** sign-in method:
   - Click on "Email/Password"
   - Toggle "Enable"
   - Click "Save"

### Firestore Database:

1. Go to **Build** → **Firestore Database**
2. Click "Create database"
3. Choose production mode or test mode:
   - **Test mode** (for development): Allows read/write access for 30 days
   - **Production mode**: Requires security rules (recommended)
4. Select your region (choose closest to your users)
5. Click "Enable"

#### Firestore Security Rules (Production):

Replace the default rules with these:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // User profiles - users can read any profile, but only update their own
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Messages - only participants can read/write
    match /messages/{chatRoomId}/{messageId} {
      allow read, write: if request.auth != null;
    }
    
    // Matches - authenticated users can read, create their own matches
    match /matches/{matchId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update, delete: if false;
    }
  }
}
```

### Firebase Storage:

1. Go to **Build** → **Storage**
2. Click "Get started"
3. Choose security rules:
   - Start in **production mode**
4. Select your region
5. Click "Done"

#### Storage Security Rules:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Profile photos - users can only upload to their own folder
    match /profile_photos/{userId}.jpg {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId
                   && request.resource.size < 5 * 1024 * 1024  // Max 5MB
                   && request.resource.contentType.matches('image/.*');
    }
  }
}
```

## Step 4: Verify Configuration

After placing the config files, verify your setup:

```bash
# Check if files exist
ls android/app/google-services.json
ls ios/Runner/GoogleService-Info.plist

# Clean and rebuild
flutter clean
flutter pub get
```

## Step 5: Test Firebase Connection

Run the app and try these features to verify Firebase is working:

1. **Authentication**: Sign up with a new account
   - Go to Firebase Console → Authentication → Users
   - Your new user should appear here

2. **Firestore**: Complete your profile
   - Go to Firebase Console → Firestore Database
   - You should see a `users` collection with your profile

3. **Storage**: Upload a profile photo
   - Go to Firebase Console → Storage
   - You should see `profile_photos` folder with your image

## Common Issues & Solutions

### Issue: "Could not resolve com.google.firebase:firebase-bom"
**Solution**: Make sure you have internet connection and run `flutter pub get`

### Issue: "FirebaseException: [core/no-app]"
**Solution**: Verify `google-services.json` and `GoogleService-Info.plist` are in correct locations

### Issue: "Permission denied" errors in Firestore
**Solution**: Check your security rules in Firebase Console and ensure they match the rules above

### Issue: App crashes on startup
**Solution**: 
1. Run `flutter clean`
2. Delete the app from your device/emulator
3. Run `flutter pub get`
4. Rebuild and run the app

## Additional Resources

- [Firebase Documentation](https://firebase.google.com/docs)
- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Firestore Security Rules Guide](https://firebase.google.com/docs/firestore/security/get-started)

## Support

If you encounter issues not listed here, check the Firebase Console for error logs:
- **Authentication** → View error logs
- **Firestore** → Usage tab for errors
- **Storage** → Usage tab for errors
