import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/buddy_investment_model.dart';
import '../models/business_models.dart';
import 'dart:math';

class BuddyInvestmentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Generate a random 4-digit code
  String _generateRoomCode() {
    final random = Random();
    return (1000 + random.nextInt(9000)).toString();
  }

  Future<String> createInvestmentRoom({
    required BusinessModel business,
    required List<BuddyInvestment> buddies,
    required double myInvestment,
    required String mainInvestorUsername,
  }) async {
    String roomId;
    bool codeExists;

    // Keep generating codes until we find a unique one
    do {
      roomId = _generateRoomCode();
      final doc =
          await _firestore.collection('investment_rooms').doc(roomId).get();
      codeExists = doc.exists;
    } while (codeExists);

    await _firestore.collection('investment_rooms').doc(roomId).set({
      'businessId': business.businessId,
      'businessTitle': business.title,
      'lotPrice': business.pricePerLot,
      'mainInvestor': {
        'username': mainInvestorUsername,
        'amount': myInvestment,
      },
      'createdAt': FieldValue.serverTimestamp(),
      'buddies': buddies.map((b) => b.toJson()).toList(),
      'isComplete': false,
    });

    return roomId;
  }

  Stream<Map<String, dynamic>> streamInvestmentRoom(String roomId) {
    return _firestore
        .collection('investment_rooms')
        .doc(roomId)
        .snapshots()
        .map((doc) => doc.data() ?? {});
  }

  Future<Map<String, dynamic>> getInvestmentRoom(String roomId) async {
    final doc =
        await _firestore.collection('investment_rooms').doc(roomId).get();
    return doc.data() ?? {};
  }

  Future<void> acceptInvestment({
    required String roomId,
    required String username,
  }) async {
    final roomRef = _firestore.collection('investment_rooms').doc(roomId);

    await _firestore.runTransaction((transaction) async {
      final roomDoc = await transaction.get(roomRef);
      final roomData = roomDoc.data() ?? {};

      List<dynamic> buddies = roomData['buddies'] ?? [];
      bool allAccepted = true;

      final updatedBuddies = buddies.map((buddy) {
        if (buddy['username'] == username) {
          buddy['hasAccepted'] = true;
        }
        if (!buddy['hasAccepted']) {
          allAccepted = false;
        }
        return buddy;
      }).toList();

      final updates = {
        'buddies': updatedBuddies,
      };

      if (allAccepted) {
        updates['isComplete'] = [true];

        // Update the business's available lots
        final businessRef =
            _firestore.collection('business').doc(roomData['businessId']);
        final businessDoc = await transaction.get(businessRef);
        final businessData = businessDoc.data() ?? {};

        // Add null check and default value
        final currentLots = businessData['numberOfLots'] ?? 0;
        if (currentLots > 0) {
          transaction.update(businessRef, {
            'numberOfLots': currentLots - 1,
          });
        } else {
          throw Exception('No lots available');
        }

        // Create investment records for all participants
        final batch = _firestore.batch();
        final mainInvestor = roomData['mainInvestor'];

        // Record for main investor
        batch.set(_firestore.collection('investments').doc(), {
          'userId': mainInvestor['username'],
          'businessId': roomData['businessId'],
          'amount': mainInvestor['amount'],
          'timestamp': FieldValue.serverTimestamp(),
          'roomId': roomId,
          'type': 'group',
        });

        // Records for buddies
        for (final buddy in updatedBuddies) {
          batch.set(_firestore.collection('investments').doc(), {
            'userId': buddy['username'],
            'businessId': roomData['businessId'],
            'amount': buddy['amount'],
            'timestamp': FieldValue.serverTimestamp(),
            'roomId': roomId,
            'type': 'group',
          });
        }

        await batch.commit();
      }

      transaction.update(roomRef, updates);
    });
  }

  // Add method to get user's investments
  Stream<List<Map<String, dynamic>>> getUserInvestments(String userId) {
    return _firestore
        .collection('investments')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList());
  }
}
