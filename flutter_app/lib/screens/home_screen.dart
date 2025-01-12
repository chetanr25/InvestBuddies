import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/models/business_models.dart';
import 'package:flutter_app/models/users_models.dart';
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
  int _selectedIndex = 0;
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
      Center(
        child: ElevatedButton(
          onPressed: () {
            if (profileData != null) {
              FinbotServer.generateQuestion(profileData!);
            }
          },
          child: const Text('Generate Questions'),
        ),
      ),
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
    // print('index: $index, _selectedIndex: $_selectedIndex');
    if (_selectedIndex != index && isDrawer) Navigator.pop(context);
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(_screenTitles[_selectedIndex]),
        ),
        body: _screens[_selectedIndex],
        // bottomNavigationBar: BottomNavigationBar(
        //   type: BottomNavigationBarType
        //       .fixed, // This is important for more than 3 items
        //   currentIndex: _selectedIndex,

        //   unselectedItemColor: Colors.grey,
        //   onTap: _onItemTapped,
        //   items: const [
        //     BottomNavigationBarItem(
        //       icon: Icon(Icons.home),
        //       label: 'Home',
        //     ),
        //     BottomNavigationBarItem(
        //       icon: Icon(Icons.chat),
        //       label: 'Chatbot',
        //     ),
        //     BottomNavigationBarItem(
        //       icon: Icon(Icons.quiz),
        //       label: 'Quiz',
        //     ),
        //     BottomNavigationBarItem(
        //       icon: Icon(Icons.add_circle_outline),
        //       label: 'Invest',
        //     ),
        //     BottomNavigationBarItem(
        //       icon: Icon(Icons.account_balance_wallet),
        //       label: 'Portfolio',
        //     ),
        //     BottomNavigationBarItem(
        //       icon: Icon(Icons.description),
        //       label: 'Terms',
        //     ),
        //     BottomNavigationBarItem(
        //       icon: Icon(Icons.business),
        //       label: 'Business',
        //     ),
        //   ],
        // ),
        // Move Terms to AppBar menu
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(
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
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.home),
                title: const Text('Home'),
                selected: _selectedIndex == 0,
                onTap: () => _onItemTapped(0, isDrawer: true),
              ),
              ListTile(
                leading: const Icon(Icons.chat),
                title: const Text('Chatbot'),
                selected: _selectedIndex == 1,
                onTap: () => _onItemTapped(1, isDrawer: true),
              ),
              ListTile(
                leading: const Icon(Icons.quiz),
                title: const Text('Quiz'),
                selected: _selectedIndex == 2,
                onTap: () => _onItemTapped(2, isDrawer: true),
              ),
              ListTile(
                leading: const Icon(Icons.add_circle_outline),
                title: const Text('Start Investment'),
                selected: _selectedIndex == 3,
                onTap: () => _onItemTapped(3, isDrawer: true),
              ),
              ListTile(
                leading: const Icon(Icons.account_balance_wallet),
                title: const Text('Your Investment'),
                selected: _selectedIndex == 4,
                onTap: () => _onItemTapped(4, isDrawer: true),
              ),
              ListTile(
                leading: const Icon(Icons.description),
                title: const Text('Terms and Conditions'),
                selected: _selectedIndex == 5,
                onTap: () => _onItemTapped(5, isDrawer: true),
              ),
              ListTile(
                leading: const Icon(Icons.business),
                title: const Text('Business Application'),
                selected: _selectedIndex == 6,
                onTap: () => _onItemTapped(6, isDrawer: true),
              ),
              ListTile(
                leading: const Icon(Icons.join_full),
                title: const Text('Join Investment'),
                selected: _selectedIndex == 7,
                onTap: () => _onItemTapped(7, isDrawer: true),
              ),
            ],
          ),
        ),
        // drawer: Drawer(
        //   child: ListView(
        //     children: [
        //       const DrawerHeader(
        //         child: Column(
        //           crossAxisAlignment: CrossAxisAlignment.start,
        //           mainAxisAlignment: MainAxisAlignment.end,
        //           children: [
        //             CircleAvatar(
        //               radius: 30,
        //               backgroundColor: Colors.white,
        //               child: Icon(Icons.person, size: 35),
        //             ),
        //             SizedBox(height: 10),
        //             Text(
        //               'Settings',
        //               style: TextStyle(
        //                 color: Colors.white,
        //                 fontSize: 24,
        //               ),
        //             ),
        //           ],
        //         ),
        //       ),
        //   ListTile(
        //     leading: const Icon(Icons.description),
        //     title: const Text('Terms and Conditions'),
        //     onTap: () => _onItemTapped(5),
        //   ),
        // ],
        // ),
        // ),
      ),
    );
  }
}
