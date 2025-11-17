import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../widgets/user_card.dart';
import '../services/auth_service.dart';
import '../services/match_service.dart';
import '../services/socket_service.dart';
import '../main.dart'; // For navigatorKey
import 'chat_screen.dart';
import 'login_screen.dart';
import 'profile_screen.dart';
import 'incoming_call_screen.dart';

/// Dashboard screen showing potential matches and existing matches
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  UserModel? _currentUser;
  List<UserModel> _potentialMatches = [];
  List<UserModel> _myMatches = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
    _setupIncomingCallListener();
  }

  /// Set up incoming call listener (runs when dashboard loads)
  void _setupIncomingCallListener() {
    final socketService = SocketService.instance;
    
    // Remove any existing listeners to avoid duplicates
    socketService.removeAllListeners();
    
    // Set up incoming call listener
    socketService.onIncomingCall((data) {
      print('📞 Incoming call on dashboard: ${data['callId']}');
      if (mounted && navigatorKey.currentContext != null) {
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

  /// Load user data and matches from API
  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final matchService = Provider.of<MatchService>(context, listen: false);

      // Load current user
      await authService.loadCurrentUser();
      _currentUser = authService.currentUser;

      if (_currentUser != null) {
        // Load potential matches
        _potentialMatches = await matchService.findPotentialMatches(_currentUser!);

        // Load existing matches
        _myMatches = await matchService.getMatchedUsers(_currentUser!.uid);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading data: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Handle matching with a user
  Future<void> _handleMatch(UserModel otherUser) async {
    try {
      final matchService = Provider.of<MatchService>(context, listen: false);
      final success = await matchService.createMatch(_currentUser!, otherUser);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Matched with ${otherUser.name}!')),
          );
          // Refresh data
          _loadData();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Match already exists or failed')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating match: $e')),
        );
      }
    }
  }

  /// Handle logout
  Future<void> _handleSignOut() async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      await authService.signOut();

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error signing out: $e')),
        );
      }
    }
  }

  /// Open chat with a user
  void _openChat(UserModel otherUser) {
    if (_currentUser == null) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          currentUser: _currentUser!,
          otherUser: otherUser,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Skillocity'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
              // Refresh data after profile update
              _loadData();
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleSignOut,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : IndexedStack(
              index: _selectedIndex,
              children: [
                _buildDiscoverTab(),
                _buildMatchesTab(),
              ],
            ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: 'Discover',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: 'My Matches',
          ),
        ],
      ),
    );
  }

  /// Build discover tab (potential matches)
  Widget _buildDiscoverTab() {
    if (_potentialMatches.isEmpty) {
      return _emptyState(
        icon: Icons.search_off,
        title: 'No potential matches found',
        subtitle: 'Try again later or update your skills!',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        itemCount: _potentialMatches.length,
        itemBuilder: (context, index) {
          final user = _potentialMatches[index];
          return UserCard(
            user: user,
            onTap: () => _showMatchDialog(user),
          );
        },
      ),
    );
  }

  /// Build matches tab (existing matches)
  Widget _buildMatchesTab() {
    if (_myMatches.isEmpty) {
      return _emptyState(
        icon: Icons.people_outline,
        title: 'No matches yet',
        subtitle: 'Start discovering people to match with!',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        itemCount: _myMatches.length,
        itemBuilder: (context, index) {
          final user = _myMatches[index];
          return UserCard(
            user: user,
            onTap: () => _openChat(user),
          );
        },
      ),
    );
  }

  /// Reusable empty view
  Widget _emptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Theme.of(context).colorScheme.outline),
          const SizedBox(height: 16),
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  /// Show match dialog
  void _showMatchDialog(UserModel user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Match with ${user.name}?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user.bio),
            const SizedBox(height: 16),
            const Text('Skills to Teach:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            ...user.skillsToTeach.map((skill) => Text('• $skill')),
            const SizedBox(height: 12),
            const Text('Skills to Learn:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            ...user.skillsToLearn.map((skill) => Text('• $skill')),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _handleMatch(user);
            },
            child: const Text('Match'),
          ),
        ],
      ),
    );
  }
}
