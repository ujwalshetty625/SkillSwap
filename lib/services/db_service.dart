import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../models/user_model.dart';

/// Database service for all Firestore operations
/// Handles user profiles, messages, and matches
class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Collection references
  CollectionReference get _usersCollection => _firestore.collection('users');
  CollectionReference get _messagesCollection => _firestore.collection('messages');
  CollectionReference get _matchesCollection => _firestore.collection('matches');

  /// Create a new user profile in Firestore
  Future<void> createUserProfile(UserModel user) async {
    try {
      await _usersCollection.doc(user.uid).set(user.toJson());
    } catch (e) {
      throw Exception('Failed to create user profile: ${e.toString()}');
    }
  }

  /// Get user profile by user ID
  Future<UserModel?> getUserProfile(String uid) async {
    try {
      DocumentSnapshot doc = await _usersCollection.doc(uid).get();
      if (doc.exists) {
        return UserModel.fromJson(doc.data() as Map<String, dynamic>);
      }
    } catch (e) {
      throw Exception('Failed to fetch user profile: ${e.toString()}');
    }
    return null;
  }

  /// Update user profile
  Future<void> updateUserProfile(UserModel user) async {
    try {
      await _usersCollection.doc(user.uid).update(user.toJson());
    } catch (e) {
      throw Exception('Failed to update user profile: ${e.toString()}');
    }
  }

  /// Update user's last active timestamp
  Future<void> updateUserLastActive(String uid) async {
    try {
      await _usersCollection.doc(uid).update({
        'lastActive': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to update last active: ${e.toString()}');
    }
  }

  /// Upload profile photo to Firebase Storage
  /// Returns the download URL of the uploaded image
  Future<String?> uploadProfilePhoto(String uid, File imageFile) async {
    try {
      // Create a reference to the storage location
      Reference storageRef = _storage.ref().child('profile_photos/$uid.jpg');
      
      // Upload the file
      UploadTask uploadTask = storageRef.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;
      
      // Get download URL
      String downloadUrl = await snapshot.ref.getDownloadURL();
      
      // Update user profile with photo URL
      await _usersCollection.doc(uid).update({'photoUrl': downloadUrl});
      
      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload profile photo: ${e.toString()}');
    }
  }

  /// Get all users except the current user (for matching)
  Future<List<UserModel>> getAllUsers(String currentUserId) async {
    try {
      QuerySnapshot snapshot = await _usersCollection
          .where('uid', isNotEqualTo: currentUserId)
          .get();
      
      return snapshot.docs
          .map((doc) => UserModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch users: ${e.toString()}');
    }
  }

  /// Send a message between users
  Future<void> sendMessage(MessageModel message) async {
    try {
      // Create a chat room ID (consistent for both users)
      String chatRoomId = _getChatRoomId(message.senderId, message.receiverId);
      
      // Save message to chat room
      await _messagesCollection
          .doc(chatRoomId)
          .collection('messages')
          .doc(message.id)
          .set(message.toJson());
    } catch (e) {
      throw Exception('Failed to send message: ${e.toString()}');
    }
  }

  /// Get real-time message stream for a chat
  Stream<List<MessageModel>> getMessages(String userId, String otherUserId) {
    String chatRoomId = _getChatRoomId(userId, otherUserId);
    
    return _messagesCollection
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MessageModel.fromJson(doc.data()))
            .toList());
  }

  /// Create a unique chat room ID for two users
  String _getChatRoomId(String userId1, String userId2) {
    // Sort user IDs alphabetically to ensure consistent chat room ID
    List<String> ids = [userId1, userId2]..sort();
    return '${ids[0]}_${ids[1]}';
  }

  /// Save a match between two users
  Future<void> createMatch(MatchModel match) async {
    try {
      await _matchesCollection.doc(match.matchId).set(match.toJson());
    } catch (e) {
      throw Exception('Failed to create match: ${e.toString()}');
    }
  }

  /// Get all matches for a user
  Future<List<MatchModel>> getUserMatches(String userId) async {
    try {
      // Find matches where user is either user1 or user2
      QuerySnapshot snapshot1 = await _matchesCollection
          .where('user1Id', isEqualTo: userId)
          .get();
      
      QuerySnapshot snapshot2 = await _matchesCollection
          .where('user2Id', isEqualTo: userId)
          .get();
      
      List<MatchModel> matches = [];
      
      // Combine both query results
      matches.addAll(snapshot1.docs
          .map((doc) => MatchModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList());
      
      matches.addAll(snapshot2.docs
          .map((doc) => MatchModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList());
      
      return matches;
    } catch (e) {
      throw Exception('Failed to fetch matches: ${e.toString()}');
    }
  }

  /// Check if a match already exists between two users
  Future<bool> matchExists(String userId1, String userId2) async {
    try {
      QuerySnapshot snapshot = await _matchesCollection
          .where('user1Id', whereIn: [userId1, userId2])
          .get();
      
      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        if ((data['user1Id'] == userId1 && data['user2Id'] == userId2) ||
            (data['user1Id'] == userId2 && data['user2Id'] == userId1)) {
          return true;
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
