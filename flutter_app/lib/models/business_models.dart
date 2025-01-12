import 'package:cloud_firestore/cloud_firestore.dart';

class BusinessModel {
  final String userId;
  final String userEmail;
  final String businessId;
  final String title;
  final String description;
  final int numberOfLots;
  final double pricePerLot;
  final double totalFundingGoal;
  final double currentFunding;
  final String industry;
  final List<String> tags;
  final DateTime createdAt;
  final String businessPlan;
  final List<String> financialDocuments;
  final String email;

  BusinessModel({
    required this.userId,
    required this.userEmail,
    required this.businessId,
    required this.title,
    required this.description,
    required this.numberOfLots,
    required this.pricePerLot,
    required this.totalFundingGoal,
    required this.currentFunding,
    required this.industry,
    required this.tags,
    required this.createdAt,
    required this.businessPlan,
    required this.financialDocuments,
    required this.email,
  });

  factory BusinessModel.fromMap(Map<String, dynamic> map) {
    return BusinessModel(
      userId: map['userId'] ?? '',
      userEmail: map['userEmail'] ?? '',
      businessId: map['businessId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      numberOfLots: map['numberOfLots'] ?? 0,
      pricePerLot: (map['pricePerLot'] ?? 0).toDouble(),
      totalFundingGoal: (map['totalFundingGoal'] ?? 0).toDouble(),
      currentFunding: (map['currentFunding'] ?? 0).toDouble(),
      industry: map['industry'] ?? '',
      tags: List<String>.from(map['tags'] ?? []),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      businessPlan: map['businessPlan'] ?? '',
      financialDocuments: List<String>.from(map['financialDocuments'] ?? []),
      email: map['email'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userEmail': userEmail,
      'businessId': businessId,
      'title': title,
      'description': description,
      'numberOfLots': numberOfLots,
      'pricePerLot': pricePerLot,
      'totalFundingGoal': totalFundingGoal,
      'currentFunding': currentFunding,
      'industry': industry,
      'tags': tags,
      'createdAt': createdAt,
      'businessPlan': businessPlan,
      'financialDocuments': financialDocuments,
      'email': email,
    };
  }

  BusinessModel copyWith({
    String? userId,
    String? userEmail,
    String? businessId,
    String? title,
    String? description,
    int? numberOfLots,
    double? pricePerLot,
    double? totalFundingGoal,
    double? currentFunding,
    String? industry,
    List<String>? tags,
    DateTime? createdAt,
    String? businessPlan,
    List<String>? financialDocuments,
    String? email,
  }) {
    return BusinessModel(
      userId: userId ?? this.userId,
      userEmail: userEmail ?? this.userEmail,
      businessId: businessId ?? this.businessId,
      title: title ?? this.title,
      description: description ?? this.description,
      numberOfLots: numberOfLots ?? this.numberOfLots,
      pricePerLot: pricePerLot ?? this.pricePerLot,
      totalFundingGoal: totalFundingGoal ?? this.totalFundingGoal,
      currentFunding: currentFunding ?? this.currentFunding,
      industry: industry ?? this.industry,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      businessPlan: businessPlan ?? this.businessPlan,
      financialDocuments: financialDocuments ?? this.financialDocuments,
      email: email ?? this.email,
    );
  }

  factory BusinessModel.fromFirestore(DocumentSnapshot doc) {
    return BusinessModel.fromMap(doc.data() as Map<String, dynamic>);
  }
}
