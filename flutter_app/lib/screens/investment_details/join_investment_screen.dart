import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/buddy_investment_service.dart';
import '../../providers/users_providers.dart';
import 'investment_confirmation_screen.dart';

class JoinInvestmentScreen extends ConsumerStatefulWidget {
  const JoinInvestmentScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<JoinInvestmentScreen> createState() =>
      _JoinInvestmentScreenState();
}

class _JoinInvestmentScreenState extends ConsumerState<JoinInvestmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _joinRoom() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final buddyService = BuddyInvestmentService();
      final user = ref.read(userProvider);
      final roomData =
          await buddyService.getInvestmentRoom(_codeController.text);

      if (roomData.isEmpty) {
        setState(() {
          _error = 'Invalid investment code';
          _isLoading = false;
        });
        return;
      }

      // Check if user is part of this investment
      final buddies = (roomData['buddies'] as List<dynamic>?) ?? [];
      final buddy = buddies.firstWhere(
        (b) => b['username'] == user.userId,
        orElse: () => <String, dynamic>{},
      );

      if (buddy.isEmpty) {
        setState(() {
          _error = 'You are not part of this investment';
          _isLoading = false;
        });
        return;
      }

      // Navigate to confirmation screen
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => InvestmentConfirmationScreen(
              roomId: _codeController.text,
              roomData: roomData,
              buddyData: buddy,
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _error = 'Error joining room: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Join Investment'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _codeController,
                decoration: const InputDecoration(
                  labelText: 'Investment Code',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the investment code';
                  }
                  return null;
                },
              ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    _error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isLoading ? null : _joinRoom,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Join Investment'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
