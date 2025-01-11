import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_app/models/users_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userProvider = StateNotifierProvider<UserNotifier, UserModel>((ref) {
  return UserNotifier();
});

class UserNotifier extends StateNotifier<UserModel> {
  UserNotifier()
      : super(UserModel(
          userId: '',
          email: '',
          displayName: '',
          profileCompleted: false,
          role: '',
        )) {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        _loadUserData(user.uid);
      } else {
        state = UserModel(
          userId: '',
          email: '',
          displayName: '',
          profileCompleted: false,
          role: '',
        );
      }
    });
  }
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _loadUserData(String uid) async {
    try {
      final docSnapshot = await _firestore.collection('users').doc(uid).get();
      if (docSnapshot.exists) {
        final data = docSnapshot.data()!;
        state = UserModel(
          profileCompleted: data['profileCompleted'],
          additionalData: data['additionalData'],
        );
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }
}
