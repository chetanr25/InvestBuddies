import 'package:flutter/material.dart';
import 'package:flutter_app/screens/investment_details/buddy_investment_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/business_models.dart';

class CompanyDetailsScreen extends ConsumerWidget {
  final BusinessModel business;

  const CompanyDetailsScreen({Key? key, required this.business})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(business.title),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                business.description,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Industry: ${business.industry}'),
                      Text('Price per Lot: ₹${business.pricePerLot}'),
                      Text('Available Lots: ${business.numberOfLots}'),
                      Text('Total Goal: ₹${business.totalFundingGoal}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 4,
                children: business.tags
                    .map((tag) => Chip(
                          label: Text(tag),
                          backgroundColor: Colors.blue,
                          labelStyle: const TextStyle(color: Colors.white),
                        ))
                    .toList(),
              ),
            ],
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BuddyInvestmentScreen(
                          business: business,
                        ),
                      ),
                    );
                  },
                  child: const Text('Buy a lot with buddies'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // Implement direct buy logic
                  },
                  child: const Text('Buy a lot'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
