import '../models/user_model.dart';
import 'api_service.dart';

/// Match service that finds potential skill exchange partners
/// Uses REST API for matching operations
class MatchService {
  final ApiService _apiService = ApiService();

  /// Find potential matches for a user
  /// Returns users who teach what the current user wants to learn
  /// AND who want to learn what the current user teaches (mutual match)
  Future<List<UserModel>> findPotentialMatches(UserModel currentUser) async {
    try {
      final response = await _apiService.get('/matches/potential');
      if (response['success'] == true) {
        final matches = response['matches'] as List;
        return matches.map((user) => UserModel.fromJson(user)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to find matches: ${e.toString()}');
    }
  }

  /// Check if two users have a mutual skill match
  /// A mutual match occurs when:
  /// - User A teaches what User B wants to learn
  /// - User B teaches what User A wants to learn
  bool _isMutualMatch(UserModel user1, UserModel user2) {
    // Find skills user1 teaches that user2 wants to learn
    List<String> user1TeachesUser2Learns = user1.skillsToTeach
        .where((skill) => user2.skillsToLearn.contains(skill))
        .toList();
    
    // Find skills user2 teaches that user1 wants to learn
    List<String> user2TeachesUser1Learns = user2.skillsToTeach
        .where((skill) => user1.skillsToLearn.contains(skill))
        .toList();
    
    // Mutual match exists if both lists are not empty
    return user1TeachesUser2Learns.isNotEmpty && 
           user2TeachesUser1Learns.isNotEmpty;
  }

  /// Get common skills between two users (for display)
  List<String> getCommonSkills(UserModel user1, UserModel user2) {
    List<String> common = [];
    
    // Skills user1 teaches that user2 wants
    common.addAll(user1.skillsToTeach
        .where((skill) => user2.skillsToLearn.contains(skill)));
    
    // Skills user2 teaches that user1 wants
    common.addAll(user2.skillsToTeach
        .where((skill) => user1.skillsToLearn.contains(skill)));
    
    return common.toSet().toList(); // Remove duplicates
  }

  /// Create a match between two users
  Future<bool> createMatch(UserModel user1, UserModel user2) async {
    try {
      final response = await _apiService.post('/matches/create', {
        'otherUserId': user2.uid,
      });

      if (response['success'] == true) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      throw Exception('Failed to create match: ${e.toString()}');
    }
  }

  /// Get all matched users for the current user
  Future<List<UserModel>> getMatchedUsers(String currentUserId) async {
    try {
      final response = await _apiService.get('/matches/my-matches');
      if (response['success'] == true) {
        final matches = response['matches'] as List;
        return matches.map((matchData) {
          final user = matchData['user'] as Map<String, dynamic>;
          return UserModel.fromJson(user);
        }).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to get matched users: ${e.toString()}');
    }
  }
}
