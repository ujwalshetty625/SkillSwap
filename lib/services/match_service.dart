import '../models/user_model.dart';
import 'db_service.dart';
import 'package:uuid/uuid.dart';

/// Match service that finds potential skill exchange partners
/// Implements the mutual matching algorithm
class MatchService {
  final DatabaseService _dbService = DatabaseService();
  final Uuid _uuid = const Uuid();

  /// Find potential matches for a user
  /// Returns users who teach what the current user wants to learn
  /// AND who want to learn what the current user teaches (mutual match)
  Future<List<UserModel>> findPotentialMatches(UserModel currentUser) async {
    try {
      // Get all other users
      List<UserModel> allUsers = await _dbService.getAllUsers(currentUser.uid);
      
      // Filter for mutual matches
      List<UserModel> potentialMatches = [];
      
      for (UserModel otherUser in allUsers) {
        if (_isMutualMatch(currentUser, otherUser)) {
          potentialMatches.add(otherUser);
        }
      }
      
      return potentialMatches;
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
      // Check if match already exists
      bool exists = await _dbService.matchExists(user1.uid, user2.uid);
      if (exists) {
        return false; // Match already exists
      }
      
      // Get common skills
      List<String> commonSkills = getCommonSkills(user1, user2);
      
      // Create match model
      MatchModel match = MatchModel(
        matchId: _uuid.v4(),
        user1Id: user1.uid,
        user2Id: user2.uid,
        commonSkills: commonSkills,
      );
      
      // Save match to database
      await _dbService.createMatch(match);
      
      return true;
    } catch (e) {
      throw Exception('Failed to create match: ${e.toString()}');
    }
  }

  /// Get all matched users for the current user
  Future<List<UserModel>> getMatchedUsers(String currentUserId) async {
    try {
      // Get all matches for current user
      List<MatchModel> matches = await _dbService.getUserMatches(currentUserId);
      
      // Get user profiles for each match
      List<UserModel> matchedUsers = [];
      
      for (MatchModel match in matches) {
        // Determine which user ID is the other person
        String otherUserId = match.user1Id == currentUserId 
            ? match.user2Id 
            : match.user1Id;
        
        // Fetch their profile
        UserModel? user = await _dbService.getUserProfile(otherUserId);
        if (user != null) {
          matchedUsers.add(user);
        }
      }
      
      return matchedUsers;
    } catch (e) {
      throw Exception('Failed to get matched users: ${e.toString()}');
    }
  }
}
