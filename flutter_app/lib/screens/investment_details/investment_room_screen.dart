import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/buddy_investment_model.dart';
import '../../models/business_models.dart';
import '../../services/buddy_investment_service.dart';

class InvestmentRoomScreen extends ConsumerStatefulWidget {
  final BusinessModel business;
  final List<BuddyInvestment> buddies;
  final double myInvestment;
  final String roomId;

  const InvestmentRoomScreen({
    Key? key,
    required this.business,
    required this.buddies,
    required this.myInvestment,
    required this.roomId,
  }) : super(key: key);

  @override
  ConsumerState<InvestmentRoomScreen> createState() =>
      _InvestmentRoomScreenState();
}

class _InvestmentRoomScreenState extends ConsumerState<InvestmentRoomScreen> {
  late Stream<Map<String, dynamic>> roomStream;

  @override
  void initState() {
    super.initState();
    final buddyService = BuddyInvestmentService();
    roomStream = buddyService.streamInvestmentRoom(widget.roomId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Investment Room'),
      ),
      body: StreamBuilder<Map<String, dynamic>>(
        stream: roomStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final roomData = snapshot.data!;
          final List<dynamic> buddies = roomData['buddies'] ?? [];

          return Padding(
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
                        const Text(
                          'Investment Code',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              widget.roomId,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 4,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.copy),
                              onPressed: () {
                                Clipboard.setData(
                                    ClipboardData(text: widget.roomId));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text('Code copied to clipboard')),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Investment Status',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        ListTile(
                          title: const Text('Your Investment'),
                          trailing: Text('₹${widget.myInvestment}'),
                          leading: const Icon(Icons.check_circle,
                              color: Colors.green),
                        ),
                        ...buddies.map((buddy) => ListTile(
                              title: Text(buddy['username'] ?? ''),
                              trailing: Text('₹${buddy['amount']}'),
                              leading: Icon(
                                buddy['hasAccepted']
                                    ? Icons.check_circle
                                    : Icons.pending,
                                color: buddy['hasAccepted']
                                    ? Colors.green
                                    : Colors.orange,
                              ),
                            )),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
