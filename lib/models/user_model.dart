/// Models for Skillocity App
/// Compatible with both Firestore and Offline Mock Data

class UserModel {
  final String uid;
  final String email;
  final String name;
  final String bio;
  final List<String> skillsToTeach;
  final List<String> skillsToLearn;
  final String? photoUrl;
  final DateTime createdAt;
  final DateTime lastActive;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    this.bio = '',
    this.skillsToTeach = const [],
    this.skillsToLearn = const [],
    this.photoUrl,
    DateTime? createdAt,
    DateTime? lastActive,
  })  : createdAt = createdAt ?? DateTime.now(),
        lastActive = lastActive ?? DateTime.now();

  /// ✅ Helper for mock/offline data compatibility
  List<String> get allSkills => [...skillsToTeach, ...skillsToLearn];

  /// Convert UserModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'bio': bio,
      'skillsToTeach': skillsToTeach,
      'skillsToLearn': skillsToLearn,
      'photoUrl': photoUrl,
      'createdAt': createdAt.toIso8601String(),
      'lastActive': lastActive.toIso8601String(),
    };
  }

  /// Create from Firestore or mock JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      bio: json['bio'] ?? '',
      skillsToTeach: List<String>.from(
        json['skillsToTeach'] ?? json['skills'] ?? [],
      ),
      skillsToLearn: List<String>.from(
        json['skillsToLearn'] ?? json['interests'] ?? [],
      ),
      photoUrl: json['photoUrl'],
      createdAt: _parseDate(json['createdAt']),
      lastActive: _parseDate(json['lastActive']),
    );
  }

  /// Safe date parsing
  static DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (_) {
        return DateTime.now();
      }
    }
    return DateTime.now();
  }

  /// Copy helper
  UserModel copyWith({
    String? uid,
    String? email,
    String? name,
    String? bio,
    List<String>? skillsToTeach,
    List<String>? skillsToLearn,
    String? photoUrl,
    DateTime? createdAt,
    DateTime? lastActive,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      bio: bio ?? this.bio,
      skillsToTeach: skillsToTeach ?? this.skillsToTeach,
      skillsToLearn: skillsToLearn ?? this.skillsToLearn,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      lastActive: lastActive ?? this.lastActive,
    );
  }
}

/// Message model for chat
class MessageModel {
  final String id;
  final String senderId;
  final String receiverId;
  final String message;
  final DateTime timestamp;
  final bool isRead;

  MessageModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.message,
    DateTime? timestamp,
    this.isRead = false,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'receiverId': receiverId,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
    };
  }

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] ?? '',
      senderId: json['senderId'] ?? '',
      receiverId: json['receiverId'] ?? '',
      message: json['message'] ?? '',
      timestamp: UserModel._parseDate(json['timestamp']),
      isRead: json['isRead'] ?? false,
    );
  }
}

/// Match model for connecting users
class MatchModel {
  final String matchId;
  final String user1Id;
  final String user2Id;
  final List<String> commonSkills;
  final DateTime matchedAt;

  MatchModel({
    required this.matchId,
    required this.user1Id,
    required this.user2Id,
    this.commonSkills = const [],
    DateTime? matchedAt,
  }) : matchedAt = matchedAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'matchId': matchId,
      'user1Id': user1Id,
      'user2Id': user2Id,
      'commonSkills': commonSkills,
      'matchedAt': matchedAt.toIso8601String(),
    };
  }

  factory MatchModel.fromJson(Map<String, dynamic> json) {
    return MatchModel(
      matchId: json['matchId'] ?? '',
      user1Id: json['user1Id'] ?? '',
      user2Id: json['user2Id'] ?? '',
      commonSkills: List<String>.from(json['commonSkills'] ?? []),
      matchedAt: UserModel._parseDate(json['matchedAt']),
    );
  }
}
