# Skillocity 🎓

A Flutter mobile app for peer-to-peer skill exchange where users teach and learn from each other. Exchange coding knowledge for piano lessons, Spanish for photography, or any skill combination!

## Features ✨

- **User Authentication**: Secure email/password signup and login with Firebase
- **User Profiles**: Create detailed profiles with bio, skills to teach, and skills to learn
- **Profile Photos**: Upload and display profile pictures stored in Firebase Storage
- **Smart Matching**: Intelligent algorithm finds mutual matches (users who teach what you want to learn and want to learn what you teach)
- **Real-Time Chat**: Message matched users instantly with Firestore-powered real-time chat
- **Video Calling**: Face-to-face skill exchange sessions using Jitsi Meet integration
- **Modern UI**: Beautiful Material 3 design with light and dark theme support
- **Responsive**: Works seamlessly on both Android and iOS devices

## Tech Stack 🛠️

- **Frontend**: Flutter 3.x with Dart
- **Backend**: Firebase (Authentication, Firestore, Storage)
- **Video**: Jitsi Meet Flutter SDK
- **State Management**: Provider
- **UI**: Material 3 Design

## Project Structure 📁

```
lib/
├── main.dart                 # App entry point and initialization
├── models/
│   └── user_model.dart      # User, Message, and Match data models
├── services/
│   ├── auth_service.dart    # Firebase Authentication logic
│   ├── db_service.dart      # Firestore database operations
│   └── match_service.dart   # Skill matching algorithm
├── screens/
│   ├── login_screen.dart    # User login
│   ├── signup_screen.dart   # New user registration
│   ├── profile_screen.dart  # Edit profile and skills
│   ├── dashboard_screen.dart # Main screen with matches
│   ├── chat_screen.dart     # Real-time messaging
│   └── video_call_screen.dart # Video call integration
└── widgets/
    ├── custom_button.dart   # Reusable button component
    ├── custom_text_field.dart # Reusable input field
    └── user_card.dart       # User profile card widget
```

## Prerequisites 📋

Before you begin, ensure you have the following installed:

- **Flutter SDK** (3.0 or higher): [Install Flutter](https://flutter.dev/docs/get-started/install)
- **Dart** (3.0 or higher): Comes with Flutter
- **Android Studio** or **Xcode**: For mobile development
- **Git**: For version control
- **Firebase Account**: Free tier works perfectly

### For Android Development:
- Android Studio with Android SDK
- Android Emulator or physical device

### For iOS Development:
- macOS with Xcode installed
- iOS Simulator or physical iPhone

## Installation & Setup 🚀

### 1. Clone the Repository

```bash
git clone <your-repo-url>
cd skillocity
```

### 2. Install Flutter Dependencies

```bash
flutter pub get
```

### 3. Firebase Setup

Follow the detailed Firebase setup guide: [FIREBASE_SETUP.md](FIREBASE_SETUP.md)

**Quick steps:**
1. Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
2. Add Android and iOS apps to your Firebase project
3. Download config files:
   - `google-services.json` → `android/app/`
   - `GoogleService-Info.plist` → `ios/Runner/`
4. Enable Authentication (Email/Password)
5. Create Firestore Database
6. Set up Firebase Storage

### 4. Platform-Specific Setup

#### Android Configuration:

No additional steps needed! The `google-services.json` file handles configuration.

#### iOS Configuration:

1. Open `ios/Runner.xcworkspace` in Xcode
2. Update the bundle identifier to match your Firebase iOS app
3. Ensure deployment target is iOS 12.0 or higher

### 5. Verify Installation

```bash
# Check Flutter environment
flutter doctor

# Run dependency check
flutter pub get

# Check for any issues
flutter analyze
```

## Running the App 🏃

### On Android:

```bash
# List available devices
flutter devices

# Run on connected Android device
flutter run

# Or specify device
flutter run -d <device-id>
```

### On iOS:

```bash
# Run on iOS simulator
flutter run -d "iPhone 15"

# Or on connected iPhone
flutter run
```

### Debug Mode:

```bash
flutter run --debug
```

### Release Mode:

```bash
flutter run --release
```

## Building for Production 📦

### Android APK:

```bash
# Build APK
flutter build apk --release

# Output: build/app/outputs/flutter-apk/app-release.apk
```

### Android App Bundle (for Play Store):

```bash
# Build App Bundle
flutter build appbundle --release

# Output: build/app/outputs/bundle/release/app-release.aab
```

### iOS:

```bash
# Build for iOS
flutter build ios --release

# Then open Xcode to archive and upload
open ios/Runner.xcworkspace
```

## Key Features Explained 🔑

### 1. Skill Matching Algorithm

The app uses a mutual matching system:
- User A teaches Python and wants to learn Guitar
- User B teaches Guitar and wants to learn Python
- ✅ Perfect match! Both can help each other

### 2. Real-Time Chat

- Messages sync instantly using Firestore streams
- Chat rooms are created automatically when users match
- Message history is preserved

### 3. Video Calling

- Uses Jitsi Meet for secure, peer-to-peer video calls
- No server setup required
- Works on WiFi and mobile data

## Usage Guide 📱

### First Time Setup:

1. **Sign Up**: Create account with email and password
2. **Profile Setup**: Add your name, bio, and profile photo
3. **Add Skills**: List skills you can teach (e.g., "Python", "Guitar", "Spanish")
4. **Add Learning Goals**: List skills you want to learn (e.g., "Piano", "Photography")

### Finding Matches:

1. Open **Discover** tab
2. Browse potential matches who teach what you want to learn
3. Tap on a user to see common skills
4. Click **Match** to connect

### Chatting:

1. Go to **My Matches** tab
2. Tap on a matched user
3. Start chatting in real-time
4. Click the video icon to start a video call

### Video Sessions:

1. From a chat, click the video camera icon
2. The app will launch a Jitsi Meet session
3. Both users join the same room automatically
4. Have your skill exchange session!

## Troubleshooting 🔧

### Common Issues:

#### "Execution failed for task ':app:processDebugGoogleServices'"
- Ensure `google-services.json` is in `android/app/`
- Run `flutter clean` and `flutter pub get`

#### "Firebase app not initialized"
- Check Firebase config files are correctly placed
- Verify Firebase.initializeApp() is called in main.dart

#### Video call doesn't start
- Check internet connection
- Ensure Jitsi Meet permissions are granted
- Try rebuilding the app

#### Profile photo doesn't upload
- Check Firebase Storage is enabled
- Verify storage security rules allow uploads
- Check file size (max 5MB)

### Getting Help:

1. Check [FIREBASE_SETUP.md](FIREBASE_SETUP.md) for Firebase issues
2. Run `flutter doctor` to check environment
3. Check Firebase Console for error logs
4. Review app logs: `flutter logs`

## Dependencies 📚

All dependencies are defined in `pubspec.yaml`:

- **firebase_core** (^2.24.2): Firebase SDK initialization
- **firebase_auth** (^4.15.3): User authentication
- **cloud_firestore** (^4.13.6): NoSQL database
- **firebase_storage** (^11.5.6): File storage
- **provider** (^6.1.1): State management
- **image_picker** (^1.0.7): Profile photo selection
- **cached_network_image** (^3.3.1): Efficient image loading
- **jitsi_meet_flutter_sdk** (^9.1.2): Video calling
- **uuid** (^4.3.3): Unique ID generation
- **intl** (^0.18.1): Date formatting

## Future Enhancements 🚀

Potential features for future versions:

- [ ] Push notifications for new matches and messages
- [ ] User rating and review system
- [ ] Skill verification badges
- [ ] Session scheduling with calendar integration
- [ ] In-app skill categories and search
- [ ] Achievement system and gamification
- [ ] Multi-language support
- [ ] Session history and progress tracking

## Contributing 🤝

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## Code Style

This project follows Flutter best practices:
- Use meaningful variable and function names
- Add comments for complex logic
- Follow Dart style guide
- Run `flutter analyze` before committing

## License 📄

This project is open source and available under the MIT License.

## Contact & Support 💬

For questions, issues, or suggestions:
- Open an issue on GitHub
- Check existing issues for solutions

## Acknowledgments 🙏

- Flutter team for the amazing framework
- Firebase for backend services
- Jitsi for video calling capabilities
- The open-source community

---

**Built with ❤️ using Flutter**

*Skillocity - Learn Together, Grow Together* 🌟
