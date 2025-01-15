import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/models/business_models.dart';
import 'package:flutter_app/models/users_models.dart';
import 'package:flutter_app/providers/navigation_provider.dart';
import 'package:flutter_app/providers/users_providers.dart';
import 'package:flutter_app/screens/authentication/auth.dart';
import 'package:flutter_app/screens/chat/chat_screen.dart';
import 'package:flutter_app/screens/core/business/business_application.dart';
import 'package:flutter_app/screens/finbot/finbot_screen.dart';
import 'package:flutter_app/screens/investment_details/buddy_investment_screen.dart';
import 'package:flutter_app/screens/investment_details/join_investment_screen.dart';
import 'package:flutter_app/screens/terms_and_conditions/terms_and_conditions_screen.dart';
import 'package:flutter_app/screens/quiz/quiz_screen.dart';
// import 'package:flutter_app/screens/quiz/quiz_screen.dart';
import 'package:flutter_app/screens/start_investment/start_investment_screen.dart';
import 'package:flutter_app/screens/portfolio/portfolio_screen.dart';
import 'package:flutter_app/screens/welcome/welcome_screen.dart';
// import 'package:flutter_app/screens/terms_and_conditions/terms_screen.dart';
import 'package:flutter_app/server/finbot_server.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  var profileData;
  late final List<Widget> _screens;
  List<String> _screenTitles = [
    'Home',
    'Financial Assistant',
    'Quiz',
    'Start Investment',
    'Your Investment',
    'Terms and Conditions',
    'Business Application',
    'Join Investment',
  ];

  @override
  void initState() {
    super.initState();
    profileData = ref.read(userProvider.notifier).state.additionalData;
    _screens = [
      const WelcomeScreen(),
      const ChatScreen(),
      const QuizScreen(),
      const StartInvestmentScreen(),
      const YourInvestmentScreen(),
      const TermsAndConditionsScreen(),
      const BusinessApplicationScreen(),
      const JoinInvestmentScreen(),
      BuddyInvestmentScreen(
        business: BusinessModel(
          userId: '1',
          userEmail: 'test@test.com',
          numberOfLots: 10,
          totalFundingGoal: 1000,
          currentFunding: 0,
          industry: 'Test',
          tags: ['Test'],
          createdAt: DateTime.now(),
          businessPlan: 'Test',
          businessId: '1',
          title: 'Test',
          description: 'Test',
          pricePerLot: 100,
          financialDocuments: [],
          email: 'test@test.com',
        ),
      ),
    ];
  }

  void _onItemTapped(int index, {bool isDrawer = false}) {
    if (index == 8) {
      FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Auth()),
      );
      return;
    }
    if (ref.read(navigationProvider) != index && isDrawer) {
      Navigator.pop(context);
    }
    ref.read(navigationProvider.notifier).setIndex(index);
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(navigationProvider);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(_screenTitles[selectedIndex]),
        ),
        body: _screens[selectedIndex],
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, size: 35),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Invest Buddies',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                      ),
                    ),
                    Text(
                      ref.read(userProvider).email ?? 'User ID',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.home),
                title: const Text('Home'),
                selected: selectedIndex == 0,
                onTap: () => _onItemTapped(0, isDrawer: true),
              ),
              ListTile(
                leading: const Icon(Icons.chat),
                title: const Text('Chatbot'),
                selected: selectedIndex == 1,
                onTap: () => _onItemTapped(1, isDrawer: true),
              ),
              ListTile(
                leading: const Icon(Icons.quiz),
                title: const Text('Quiz'),
                selected: selectedIndex == 2,
                onTap: () => _onItemTapped(2, isDrawer: true),
              ),
              ListTile(
                leading: const Icon(Icons.add_circle_outline),
                title: const Text('Start Investment'),
                selected: selectedIndex == 3,
                onTap: () => _onItemTapped(3, isDrawer: true),
              ),
              ListTile(
                leading: const Icon(Icons.account_balance_wallet),
                title: const Text('Your Investment'),
                selected: selectedIndex == 4,
                onTap: () => _onItemTapped(4, isDrawer: true),
              ),
              ListTile(
                leading: const Icon(Icons.description),
                title: const Text('Terms and Conditions'),
                selected: selectedIndex == 5,
                onTap: () => _onItemTapped(5, isDrawer: true),
              ),
              ListTile(
                leading: const Icon(Icons.business),
                title: const Text('Business Application'),
                selected: selectedIndex == 6,
                onTap: () => _onItemTapped(6, isDrawer: true),
              ),
              ListTile(
                leading: const Icon(Icons.join_full),
                title: const Text('Join Investment'),
                selected: selectedIndex == 7,
                onTap: () => _onItemTapped(7, isDrawer: true),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
