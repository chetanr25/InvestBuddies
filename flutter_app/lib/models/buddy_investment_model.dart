class BuddyInvestment {
  String username;
  double amount;
  bool hasAccepted;

  BuddyInvestment({
    required this.username,
    required this.amount,
    this.hasAccepted = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'amount': amount,
      'hasAccepted': hasAccepted,
    };
  }

  factory BuddyInvestment.fromJson(Map<String, dynamic> json) {
    return BuddyInvestment(
      username: json['username'],
      amount: json['amount'],
      hasAccepted: json['hasAccepted'],
    );
  }
}
