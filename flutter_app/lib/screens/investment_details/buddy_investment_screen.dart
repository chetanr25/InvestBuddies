import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/buddy_investment_model.dart';
import '../../models/business_models.dart';
import '../../services/buddy_investment_service.dart';
import '../../providers/users_providers.dart';
import '../../screens/investment_details/investment_room_screen.dart';

class BuddyInvestmentScreen extends ConsumerStatefulWidget {
  final BusinessModel business;

  const BuddyInvestmentScreen({Key? key, required this.business})
      : super(key: key);

  @override
  ConsumerState<BuddyInvestmentScreen> createState() =>
      _BuddyInvestmentScreenState();
}

class _BuddyInvestmentScreenState extends ConsumerState<BuddyInvestmentScreen> {
  final List<BuddyInvestment> buddies = [];
  late final double lotPrice;
  double totalAmount = 0.0;
  double remainingAmount = 0.0;
  double myInvestment = 0.0;

  @override
  void initState() {
    super.initState();
    lotPrice = widget.business.pricePerLot.toDouble();
    calculateAmounts();
  }

  void calculateAmounts() {
    totalAmount =
        myInvestment + buddies.fold(0.0, (sum, buddy) => sum + buddy.amount);
    remainingAmount = lotPrice - (totalAmount % lotPrice);
    if (remainingAmount == lotPrice) {
      remainingAmount = 0;
    }
  }

  void addBuddy() {
    setState(() {
      buddies.add(BuddyInvestment(username: '', amount: 0.0));
      calculateAmounts();
    });
  }

  bool isValidInvestment() {
    return totalAmount > 0 && remainingAmount == 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Investment Buddies')),
      body: Column(
        children: [
          // Investment Summary Card
          Card(
            margin: const EdgeInsets.all(16.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Lot Price: ₹${lotPrice.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Total Invested: ₹${totalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  if (remainingAmount > 0)
                    Text(
                      'Remaining for next lot: ₹${remainingAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  else if (totalAmount > 0)
                    const Text(
                      'Perfect! Amount matches lot price',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ),
          ),
          // My Investment Card
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your Investment',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    initialValue: myInvestment.toString(),
                    decoration: const InputDecoration(
                      labelText: 'Investment Amount',
                      border: OutlineInputBorder(),
                      prefixText: '₹',
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        myInvestment = double.tryParse(value) ?? 0.0;
                        calculateAmounts();
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Buddies Section
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Investment Buddies',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: buddies.length,
              itemBuilder: (context, index) {
                return BuddyInvestmentTile(
                  buddy: buddies[index],
                  onUsernameChanged: (value) {
                    setState(() {
                      buddies[index].username = value;
                    });
                  },
                  onAmountChanged: (value) {
                    setState(() {
                      buddies[index].amount = double.tryParse(value) ?? 0.0;
                      calculateAmounts();
                    });
                  },
                  onRemove: () {
                    setState(() {
                      buddies.removeAt(index);
                      calculateAmounts();
                    });
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: addBuddy,
                  child: const Text('Add Buddy'),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: isValidInvestment()
                      ? () async {
                          final buddyService = BuddyInvestmentService();
                          final user = ref.read(userProvider);

                          final roomId =
                              await buddyService.createInvestmentRoom(
                            business: widget.business,
                            buddies: buddies,
                            myInvestment: myInvestment,
                            mainInvestorUsername: user.userId!,
                          );

                          if (mounted) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => InvestmentRoomScreen(
                                  business: widget.business,
                                  buddies: buddies,
                                  myInvestment: myInvestment,
                                  roomId: roomId,
                                ),
                              ),
                            );
                          }
                        }
                      : null,
                  child: const Text('Create Investment Room'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BuddyInvestmentTile extends StatelessWidget {
  final BuddyInvestment buddy;
  final Function(String) onUsernameChanged;
  final Function(String) onAmountChanged;
  final VoidCallback? onRemove;

  const BuddyInvestmentTile({
    Key? key,
    required this.buddy,
    required this.onUsernameChanged,
    required this.onAmountChanged,
    this.onRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: buddy.username,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: onUsernameChanged,
                  ),
                ),
                if (onRemove !=
                    null) // Only show delete button if onRemove is provided
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: onRemove,
                    color: Colors.red,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(
              initialValue: buddy.amount.toString(),
              decoration: const InputDecoration(
                labelText: 'Investment Amount',
                border: OutlineInputBorder(),
                prefixText: '₹',
              ),
              keyboardType: TextInputType.number,
              onChanged: onAmountChanged,
            ),
          ],
        ),
      ),
    );
  }
}
