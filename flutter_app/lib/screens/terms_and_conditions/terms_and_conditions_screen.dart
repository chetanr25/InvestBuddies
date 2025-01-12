import 'package:flutter/material.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Investment Terms and Conditions',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            _buildSection(
              'Risk Disclosure',
              [
                'All investments carry risk and may result in partial or complete loss of investment.',
                'Past performance is not indicative of future results.',
                'Users should carefully evaluate their financial situation and risk tolerance before investing.',
              ],
            ),
            _buildSection(
              'Group Investment Rules',
              [
                'All buddy investors must confirm their participation within 48 hours.',
                'Investment rooms expire if not completed within the specified timeframe.',
                'Main investors are responsible for verifying buddy identities.',
                'All participants must complete KYC verification before investing.',
              ],
            ),
            _buildSection(
              'Investment Limits',
              [
                'Minimum investment amount is determined by lot size.',
                'Maximum investment limits may apply based on regulatory requirements.',
                'Users can participate in multiple investment groups simultaneously.',
              ],
            ),
            _buildSection(
              'Cancellation & Refunds',
              [
                'Investments cannot be cancelled once all buddies have confirmed.',
                'Pending investments can be cancelled before group completion.',
                'Refunds for cancelled investments will be processed within 5-7 business days.',
              ],
            ),
            _buildSection(
              'Legal Compliance',
              [
                'All investments are subject to applicable securities laws and regulations.',
                'Users must comply with anti-money laundering (AML) regulations.',
                'False information provision may result in account termination.',
              ],
            ),
            _buildSection(
              'Investment Distribution',
              [
                'Profits and losses will be distributed proportionally based on investment amounts.',
                'All transaction fees and charges will be clearly disclosed.',
                'Tax implications are the responsibility of individual investors.',
              ],
            ),
            _buildSection(
              'Platform Rights',
              [
                'We reserve the right to suspend or terminate investment activities.',
                'Investment opportunities may be modified or removed.',
                'User verification requirements may be updated.',
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<String> points) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...points.map((point) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(fontSize: 16)),
                  Expanded(
                    child: Text(
                      point,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            )),
        const SizedBox(height: 16),
      ],
    );
  }
}
