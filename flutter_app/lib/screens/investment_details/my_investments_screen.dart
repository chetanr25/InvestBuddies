import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/buddy_investment_service.dart';
import '../../providers/users_providers.dart';

class MyInvestmentsScreen extends ConsumerWidget {
  const MyInvestmentsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final buddyService = BuddyInvestmentService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Investments'),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: buddyService.getUserInvestments(user.userId!),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final investments = snapshot.data!;

          return ListView.builder(
            itemCount: investments.length,
            itemBuilder: (context, index) {
              final investment = investments[index];
              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text(investment['businessId']),
                  subtitle: Text('Amount: ₹${investment['amount']}'),
                  trailing: Text(investment['type']),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
