import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'services/auth_service.dart';
import 'services/db_service.dart';
import 'services/match_service.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';

/// Main entry point for the Skillocity app
void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  // Note: You need to add your Firebase configuration files
  // - android/app/google-services.json for Android
  // - ios/Runner/GoogleService-Info.plist for iOS
  await Firebase.initializeApp();
  
  runApp(const SkillocityApp());
}

/// Root widget for the Skillocity application
class SkillocityApp extends StatelessWidget {
  const SkillocityApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Provide services for app-wide access
        Provider<AuthService>(
          create: (_) => AuthService(),
        ),
        Provider<DatabaseService>(
          create: (_) => DatabaseService(),
        ),
        Provider<MatchService>(
          create: (_) => MatchService(),
        ),
      ],
      child: MaterialApp(
        title: 'Skillocity',
        debugShowCheckedModeBanner: false,
        
        // Material 3 theme configuration
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            brightness: Brightness.light,
          ),
          cardTheme: CardTheme(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        
        // Dark theme configuration
        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            brightness: Brightness.dark,
          ),
          cardTheme: CardTheme(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        
        // Use system theme mode preference
        themeMode: ThemeMode.system,
        
        // Authentication wrapper to show appropriate screen
        home: const AuthWrapper(),
      ),
    );
  }
}

/// Authentication wrapper widget
/// Shows LoginScreen or DashboardScreen based on auth state
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    
    return StreamBuilder(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        // Show loading while checking authentication state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        // If user is logged in, show dashboard
        if (snapshot.hasData) {
          return const DashboardScreen();
        }
        
        // Otherwise, show login screen
        return const LoginScreen();
      },
    );
  }
}
