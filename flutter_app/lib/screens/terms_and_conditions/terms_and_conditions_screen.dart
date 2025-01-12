import 'package:flutter/material.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        cardTheme: CardTheme(
          elevation: 4,
          shadowColor: Colors.black.withOpacity(0.3),
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.grey[900],
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              backgroundColor: Colors.grey[900],
              expandedHeight: 200.0,
              floating: false,
              pinned: true,
              stretch: true,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
                title: const Text(
                  'Terms & Conditions',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                stretchModes: const [
                  StretchMode.zoomBackground,
                  StretchMode.blurBackground,
                ],
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Theme.of(context).primaryColor.withOpacity(0.7),
                            Theme.of(context).primaryColor.withOpacity(0.4),
                          ],
                        ),
                      ),
                    ),
                    Center(
                      child: Icon(
                        Icons.security,
                        size: 80,
                        color: Colors.white.withOpacity(0.3),
                      ),
                    ),
                    // Add decorative pattern
                    Positioned.fill(
                      child: CustomPaint(
                        painter: GridPainter(
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Your existing sections with enhanced styling
                    ...buildSections(context),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> buildSections(BuildContext context) {
    return [
      _buildAnimatedSection(
        context,
        index: 0,
        icon: Icons.warning_amber_rounded,
        title: 'Risk Disclosure',
        points: [
          'All investments carry risk and may result in partial or complete loss of investment.',
          'Past performance is not indicative of future results.',
          'Users should carefully evaluate their financial situation and risk tolerance before investing.',
        ],
      ),
      _buildAnimatedSection(
        context,
        index: 1,
        icon: Icons.group,
        title: 'Group Investment Rules',
        points: [
          'All buddy investors must confirm their participation within 48 hours.',
          'Investment rooms expire if not completed within the specified timeframe.',
          'Main investors are responsible for verifying buddy identities.',
          'All participants must complete KYC verification before investing.',
        ],
      ),
      _buildAnimatedSection(
        context,
        index: 2,
        icon: Icons.attach_money,
        title: 'Investment Limits',
        points: [
          'Minimum investment amount is determined by lot size.',
          'Maximum investment limits may apply based on regulatory requirements.',
          'Users can participate in multiple investment groups simultaneously.',
        ],
      ),
      _buildAnimatedSection(
        context,
        index: 3,
        icon: Icons.cancel_outlined,
        title: 'Cancellation & Refunds',
        points: [
          'Investments cannot be cancelled once all buddies have confirmed.',
          'Pending investments can be cancelled before group completion.',
          'Refunds for cancelled investments will be processed within 5-7 business days.',
        ],
      ),
      _buildAnimatedSection(
        context,
        index: 4,
        icon: Icons.gavel,
        title: 'Legal Compliance',
        points: [
          'All investments are subject to applicable securities laws and regulations.',
          'Users must comply with anti-money laundering (AML) regulations.',
          'False information provision may result in account termination.',
        ],
      ),
      _buildAnimatedSection(
        context,
        index: 5,
        icon: Icons.pie_chart,
        title: 'Investment Distribution',
        points: [
          'Profits and losses will be distributed proportionally based on investment amounts.',
          'All transaction fees and charges will be clearly disclosed.',
          'Tax implications are the responsibility of individual investors.',
        ],
      ),
    ];
  }

  Widget _buildAnimatedSection(
    BuildContext context, {
    required int index,
    required IconData icon,
    required String title,
    required List<String> points,
  }) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 400 + (index * 100)),
      builder: (context, double value, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: _buildSection(context, icon: icon, title: title, points: points),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required IconData icon,
    required String title,
    required List<String> points,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.grey[850]!,
              Colors.grey[900]!,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: Theme.of(context).primaryColor),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(
                  height: 1,
                  color: Colors.grey,
                ),
              ),
              ...points.map((point) => _buildPoint(context, point)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPoint(BuildContext context, String point) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              point,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.5,
                    color: Colors.grey[300],
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  final Color color;

  GridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;

    for (var i = 0; i < size.width; i += 20) {
      canvas.drawLine(
        Offset(i.toDouble(), 0),
        Offset(i.toDouble(), size.height),
        paint,
      );
    }

    for (var i = 0; i < size.height; i += 20) {
      canvas.drawLine(
        Offset(0, i.toDouble()),
        Offset(size.width, i.toDouble()),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
