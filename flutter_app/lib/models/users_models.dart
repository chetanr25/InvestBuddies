import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String? userId;
  final String? email;
  final String? phoneNumber;
  final String? displayName;
  final String? role;
  final bool profileCompleted;
  final String profileImageUrl;
  final DateTime createdAt;
  final Map<String, dynamic> additionalData;

  UserModel copyWith({
    String? userId,
    String? displayName,
    String? email,
    bool profileCompleted = false,
    String? role,
    bool? isAuthenticated,
    String? phoneNumber,
    Map<String, dynamic>? additionalData,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      role: role ?? this.role,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileCompleted: profileCompleted,
      createdAt: createdAt,
      additionalData: additionalData ?? this.additionalData,
      profileImageUrl: profileImageUrl,
    );
  }

  UserModel({
    this.userId,
    this.email,
    this.displayName,
    this.phoneNumber,
    required this.profileCompleted,
    this.profileImageUrl =
        "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png",
    this.role,
    DateTime? createdAt,
    Map<String, dynamic>? additionalData = const {},
  })  : createdAt = createdAt ?? DateTime.now(),
        additionalData = additionalData ?? const {};

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      userId: doc.id,
      profileImageUrl: data['profileImageUrl'],
      email: data['email'],
      displayName: data['displayName'],
      role: data['role'],
      profileCompleted: data['profileCompleted'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      additionalData: data['additionalData'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'name': displayName,
      'role': role,
      'profileCompleted': profileCompleted,
      'createdAt': createdAt,
      'profileImageUrl': profileImageUrl,
      'additionalData': additionalData,
      'phoneNumber': phoneNumber,
    };
  }

  UserModel dummyUser() {
    return UserModel(
      userId: 'dummy-user-123',
      email: 'test@example.com',
      additionalData: {},
      displayName: 'John Doe',
      role: 'business',
      profileCompleted: false,
      createdAt: DateTime(2024, 1, 1),
      profileImageUrl: '',
    );
  }
}
