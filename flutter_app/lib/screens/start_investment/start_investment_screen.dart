// import 'package:flutter/material.dart';

// class StartInvestmentScreen extends StatelessWidget {
//   const StartInvestmentScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return const Center(
//       child: Text('Start Investment Screen'),
//     );
//   }
// }
// ... existing imports ...
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/models/business_models.dart';
import 'package:flutter_app/screens/investment_details/company_details_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_app/models/business_model.dart'; // Add this model

class StartInvestmentScreen extends ConsumerStatefulWidget {
  const StartInvestmentScreen({super.key});

  @override
  _StartInvestmentScreenState createState() => _StartInvestmentScreenState();
}

class _StartInvestmentScreenState extends ConsumerState<StartInvestmentScreen> {
  List<BusinessModel> _opportunities = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchOpportunities();
  }

  Future<void> _fetchOpportunities() async {
    setState(() => _isLoading = true);

    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('business').get();

      setState(() {
        _opportunities = snapshot.docs
            .map((doc) => BusinessModel.fromFirestore(doc))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching opportunities: $e')),
      );
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Investment Opportunities'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _opportunities.length,
              itemBuilder: (context, index) {
                return _buildOpportunityCard(_opportunities[index]);
              },
            ),
    );
  }

  Widget _buildOpportunityCard(BusinessModel opportunity) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              opportunity.title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(opportunity.description),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Industry: ${opportunity.industry}'),
                    Text('Price per Lot: ₹${opportunity.pricePerLot}'),
                    Text('Available Lots: ${opportunity.numberOfLots}'),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Total Goal: ₹${opportunity.totalFundingGoal}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 4,
              children: opportunity.tags
                  .map((tag) => Chip(
                        label: Text(tag),
                        backgroundColor: Colors.blue,
                        labelStyle: const TextStyle(color: Colors.white),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _showInvestmentDialog(opportunity),
              child: const Text('Invest Now'),
            ),
          ],
        ),
      ),
    );
  }

  void _showInvestmentDialog(BusinessModel opportunity) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CompanyDetailsScreen(
          business: opportunity,
        ),
      ),
    );
  }

  Future<void> _processInvestment(BusinessModel opportunity, int lots) async {}
}
