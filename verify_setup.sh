#!/bin/bash

# Skillocity Setup Verification Script
# This script checks if the Flutter project is properly configured

echo "========================================"
echo "  Skillocity Project Setup Verification"
echo "========================================"
echo ""

# Check if Dart is available
echo "📦 Checking Dart installation..."
if command -v dart &> /dev/null; then
    dart --version
    echo "✅ Dart is installed"
else
    echo "❌ Dart is not installed"
fi
echo ""

# Check Flutter (expected to not be available in Replit)
echo "📱 Checking Flutter installation..."
if command -v flutter &> /dev/null; then
    flutter --version
    echo "✅ Flutter is installed"
else
    echo "⚠️  Flutter is not available in this environment"
    echo "   This is expected - Flutter mobile apps should be developed locally"
fi
echo ""

# Verify project structure
echo "📁 Verifying project structure..."
REQUIRED_FILES=(
    "pubspec.yaml"
    "lib/main.dart"
    "lib/models/user_model.dart"
    "lib/services/auth_service.dart"
    "lib/services/db_service.dart"
    "lib/services/match_service.dart"
    "lib/screens/login_screen.dart"
    "lib/screens/signup_screen.dart"
    "lib/screens/profile_screen.dart"
    "lib/screens/dashboard_screen.dart"
    "lib/screens/chat_screen.dart"
    "lib/screens/video_call_screen.dart"
    "lib/widgets/custom_button.dart"
    "lib/widgets/custom_text_field.dart"
    "lib/widgets/user_card.dart"
    "README.md"
    "FIREBASE_SETUP.md"
)

ALL_PRESENT=true
for file in "${REQUIRED_FILES[@]}"; do
    if [ -f "$file" ]; then
        echo "  ✅ $file"
    else
        echo "  ❌ Missing: $file"
        ALL_PRESENT=false
    fi
done
echo ""

# Check for Firebase config templates
echo "🔥 Checking Firebase configuration templates..."
if [ -f "android/app/google-services.json.template" ]; then
    echo "  ✅ Android Firebase template"
else
    echo "  ❌ Missing: android/app/google-services.json.template"
fi

if [ -f "ios/Runner/GoogleService-Info.plist.template" ]; then
    echo "  ✅ iOS Firebase template"
else
    echo "  ❌ Missing: ios/Runner/GoogleService-Info.plist.template"
fi
echo ""

# Summary
echo "========================================"
echo "  Summary"
echo "========================================"
if [ "$ALL_PRESENT" = true ]; then
    echo "✅ All core project files are present!"
else
    echo "⚠️  Some files are missing"
fi
echo ""
echo "📖 Next Steps:"
echo "   1. Download this project to your local machine"
echo "   2. Install Flutter SDK: https://flutter.dev/docs/get-started/install"
echo "   3. Follow setup guide in README.md"
echo "   4. Configure Firebase using FIREBASE_SETUP.md"
echo "   5. Run: flutter pub get"
echo "   6. Run: flutter run"
echo ""
echo "📱 This Flutter mobile app is ready for local development!"
echo "========================================"
