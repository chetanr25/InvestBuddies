import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/buddy_investment_service.dart';
import '../../models/business_models.dart';

class InvestmentConfirmationScreen extends ConsumerStatefulWidget {
  final String roomId;
  final Map<String, dynamic> roomData;
  final Map<String, dynamic> buddyData;

  const InvestmentConfirmationScreen({
    Key? key,
    required this.roomId,
    required this.roomData,
    required this.buddyData,
  }) : super(key: key);

  @override
  ConsumerState<InvestmentConfirmationScreen> createState() =>
      _InvestmentConfirmationScreenState();
}

class _InvestmentConfirmationScreenState
    extends ConsumerState<InvestmentConfirmationScreen> {
  bool _isLoading = false;
  late final BusinessModel business;

  @override
  void initState() {
    super.initState();
    // Fetch business details using businessId from roomData
    _fetchBusinessDetails();
  }

  Future<void> _fetchBusinessDetails() async {
    // Implement fetching business details from Firebase
    // You can add this method to your business service
  }

  Future<void> _acceptInvestment() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final buddyService = BuddyInvestmentService();
      await buddyService.acceptInvestment(
        roomId: widget.roomId,
        username: widget.buddyData['username'],
      );

      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Investment accepted successfully')),
        );
      }
    } catch (e) {
      print(e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error accepting investment: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final mainInvestor = widget.roomData['mainInvestor'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm Investment'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.roomData['businessTitle'] ?? '',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Lot Price: ₹${widget.roomData['lotPrice']}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Investment Details',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      title: Text('Main Investor: ${mainInvestor['username']}'),
                      subtitle: Text('Amount: ₹${mainInvestor['amount']}'),
                    ),
                    const Divider(),
                    ListTile(
                      title: const Text('Your Investment'),
                      subtitle: Text('Amount: ₹${widget.buddyData['amount']}'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _acceptInvestment,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text(
                        'Accept Investment',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
