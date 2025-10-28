import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/db_service.dart';
import '../services/match_service.dart';
import '../widgets/user_card.dart';
import 'profile_screen.dart';
import 'chat_screen.dart';
import 'login_screen.dart';

/// Main dashboard showing matches, potential matches, and navigation
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final AuthService _authService = AuthService();
  final DatabaseService _dbService = DatabaseService();
  final MatchService _matchService = MatchService();
  
  int _selectedIndex = 0;
  UserModel? _currentUser;
  List<UserModel> _potentialMatches = [];
  List<UserModel> _myMatches = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  /// Load user data and matches
  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      final user = _authService.currentUser;
      if (user != null) {
        // Load user profile
        final profile = await _dbService.getUserProfile(user.uid);
        
        if (profile != null) {
          // Load potential matches
          final potentialMatches = await _matchService.findPotentialMatches(profile);
          
          // Load existing matches
          final myMatches = await _matchService.getMatchedUsers(profile.uid);
          
          if (mounted) {
            setState(() {
              _currentUser = profile;
              _potentialMatches = potentialMatches;
              _myMatches = myMatches;
              _isLoading = false;
            });
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load data: $e')),
        );
      }
    }
  }

  /// Handle creating a match with a user
  Future<void> _handleMatch(UserModel otherUser) async {
    if (_currentUser == null) return;

    try {
      bool created = await _matchService.createMatch(_currentUser!, otherUser);
      
      if (created && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Matched with ${otherUser.name}!')),
        );
        _loadData(); // Reload data to update lists
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You are already matched!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create match: $e')),
        );
      }
    }
  }

  /// Navigate to chat with a matched user
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

  /// Sign out user
  Future<void> _handleSignOut() async {
    await _authService.signOut();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
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
              _loadData(); // Reload after profile edit
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

  /// Build discover tab showing potential matches
  Widget _buildDiscoverTab() {
    if (_potentialMatches.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 80,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'No potential matches found',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Update your skills to find people who can help you learn!',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
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

  /// Build matches tab showing existing matches
  Widget _buildMatchesTab() {
    if (_myMatches.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 80,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'No matches yet',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Start discovering people to match with!',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
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

  /// Show dialog to confirm matching with a user
  void _showMatchDialog(UserModel user) {
    if (_currentUser == null) return;
    
    final commonSkills = _matchService.getCommonSkills(_currentUser!, user);
    
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
            const Text(
              'Common Skills:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ...commonSkills.map((skill) => Text('• $skill')),
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
