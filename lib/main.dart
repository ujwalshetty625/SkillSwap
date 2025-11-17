import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/auth_service.dart';
import 'services/db_service.dart';
import 'services/match_service.dart';
import 'services/socket_service.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/incoming_call_screen.dart';

// Global navigator key for navigation from anywhere
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// Main entry point for the Skillocity app
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SkillocityApp());
}

/// Root widget for the Skillocity application
class SkillocityApp extends StatelessWidget {
  const SkillocityApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => AuthService()),
        Provider<DatabaseService>(create: (_) => DatabaseService()),
        Provider<MatchService>(create: (_) => MatchService()),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        title: 'Skillocity',
        debugShowCheckedModeBanner: false,

        // ✅ Light Theme
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            brightness: Brightness.light,
          ),
          cardTheme: const CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
          ),
        ),

        // ✅ Dark Theme
        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            brightness: Brightness.dark,
          ),
          cardTheme: const CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
          ),
        ),

        themeMode: ThemeMode.system,

        home: const AuthWrapper(),
      ),
    );
  }
}

/// Authentication wrapper widget
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    await authService.loadCurrentUser();
    
    // Connect to Socket.IO if user is logged in
    if (authService.currentUser != null) {
      final socketService = SocketService.instance;
      socketService.connect(authService.currentUser!.uid);
      
      // Wait a bit for socket to connect
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Listen for incoming calls - use global navigator
      socketService.onIncomingCall((data) {
        print('📞 Incoming call received: ${data['callId']}');
        if (navigatorKey.currentContext != null) {
          Navigator.of(navigatorKey.currentContext!).push(
            MaterialPageRoute(
              builder: (_) => IncomingCallScreen(
                callId: data['callId'],
                callerId: data['callerId'],
                callerName: data['callerName'] ?? 'Unknown',
                roomName: data['roomName'],
              ),
            ),
          );
        }
      });
    }
    
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final authService = Provider.of<AuthService>(context, listen: false);

    return StreamBuilder(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          return const DashboardScreen();
        }
        return const LoginScreen();
      },
    );
  }
}
