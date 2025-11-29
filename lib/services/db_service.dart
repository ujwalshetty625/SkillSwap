import 'dart:io';
import '../models/user_model.dart';
import 'api_service.dart';

/// Database service for all REST API operations
/// Handles user profiles, messages, and matches
class DatabaseService {
  final ApiService _apiService = ApiService();

  /// Create a new user profile
  Future<void> createUserProfile(UserModel user) async {
    try {
      // User is created during signup, so this is mainly for updates
      await updateUserProfile(user);
    } catch (e) {
      throw Exception('Failed to create user profile: ${e.toString()}');
    }
  }

  /// Get user profile by user ID
  Future<UserModel?> getUserProfile(String uid) async {
    try {
      final response = await _apiService.get('/users/profile/$uid');
      if (response['success'] == true) {
        return UserModel.fromJson(response['user']);
      }
    } catch (e) {
      throw Exception('Failed to fetch user profile: ${e.toString()}');
    }
    return null;
  }

  /// Update user profile
  Future<void> updateUserProfile(UserModel user) async {
    try {
      final response = await _apiService.put('/users/me', {
        'name': user.name,
        'bio': user.bio,
        'skillsToTeach': user.skillsToTeach,
        'skillsToLearn': user.skillsToLearn,
      });

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Failed to update profile');
      }
    } catch (e) {
      throw Exception('Failed to update user profile: ${e.toString()}');
    }
  }

  /// Update user's last active timestamp
  Future<void> updateUserLastActive(String uid) async {
    try {
      // Last active is updated automatically on API calls
      // This method is kept for compatibility
    } catch (e) {
      throw Exception('Failed to update last active: ${e.toString()}');
    }
  }

  /// Upload profile photo
  /// Returns the download URL of the uploaded image
  Future<String?> uploadProfilePhoto(String uid, File imageFile) async {
    try {
      final response = await _apiService.uploadFile(
        '/users/me/photo',
        imageFile,
        'photo',
      );

      if (response['success'] == true) {
        return response['photoUrl'];
      } else {
        throw Exception(response['message'] ?? 'Failed to upload photo');
      }
    } catch (e) {
      throw Exception('Failed to upload profile photo: ${e.toString()}');
    }
  }

  /// Get all users except the current user (for matching)
  Future<List<UserModel>> getAllUsers(String currentUserId) async {
    try {
      final response = await _apiService.get('/users/all');
      if (response['success'] == true) {
        final users = response['users'] as List;
        return users.map((user) => UserModel.fromJson(user)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch users: ${e.toString()}');
    }
  }

  /// Send a message between users
  Future<void> sendMessage(MessageModel message) async {
    try {
      final response = await _apiService.post('/messages/send', {
        'receiverId': message.receiverId,
        'message': message.message,
      });

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Failed to send message');
      }
    } catch (e) {
      throw Exception('Failed to send message: ${e.toString()}');
    }
  }

  /// Get messages between two users (returns list, not stream)
  /// For real-time updates, use Socket.IO in chat_screen.dart
  Future<List<MessageModel>> getMessages(String userId, String otherUserId) async {
    try {
      final response = await _apiService.get('/messages/$otherUserId');
      if (response['success'] == true) {
        final messages = response['messages'] as List;
        return messages.map((msg) => MessageModel.fromJson(msg)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch messages: ${e.toString()}');
    }
  }

  /// Save a match between two users
  Future<void> createMatch(MatchModel match) async {
    try {
      final response = await _apiService.post('/matches/create', {
        'otherUserId': match.user1Id == match.user1Id ? match.user2Id : match.user1Id,
      });

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Failed to create match');
      }
    } catch (e) {
      throw Exception('Failed to create match: ${e.toString()}');
    }
  }

  /// Get all matches for a user
  Future<List<MatchModel>> getUserMatches(String userId) async {
    try {
      final response = await _apiService.get('/matches/my-matches');
      if (response['success'] == true) {
        final matches = response['matches'] as List;
        return matches.map((matchData) {
          final user = matchData['user'] as Map<String, dynamic>;
          final match = matchData['match'] as Map<String, dynamic>;
          return MatchModel(
            matchId: match['matchId'],
            user1Id: userId,
            user2Id: user['uid'],
            commonSkills: List<String>.from(match['commonSkills'] ?? []),
            matchedAt: DateTime.parse(match['matchedAt']),
          );
        }).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch matches: ${e.toString()}');
    }
  }

  /// Check if a match already exists between two users
  Future<bool> matchExists(String userId1, String userId2) async {
    try {
      final matches = await getUserMatches(userId1);
      return matches.any((match) =>
          (match.user1Id == userId1 && match.user2Id == userId2) ||
          (match.user1Id == userId2 && match.user2Id == userId1));
    } catch (e) {
      return false;
    }
  }

  /// Generate a deterministic room name for two users
  /// This ensures both users always get the same room name for a given pair
  static String generateRoomName(String userId1, String userId2) {
    // Sort user IDs to ensure same room name regardless of order
    final ids = [userId1, userId2]..sort();
    // Create a clean room name using sorted IDs
    // Remove any special characters and create a valid Jitsi room name
    final cleanId1 = ids[0].replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
    final cleanId2 = ids[1].replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
    return 'skillocity_${cleanId1}_${cleanId2}';
  }
}
