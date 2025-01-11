import 'package:flutter/material.dart';
import 'package:flutter_app/screens/chatbot_screen.dart';
import 'package:flutter_app/screens/quiz_screen.dart';
import 'package:flutter_app/screens/start_investment_screen.dart';
import 'package:flutter_app/screens/your_investment_screen.dart';
import 'package:flutter_app/screens/terms_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final List<Widget> _screens = [
    const Center(child: Text('Home Screen Content')),
    const ChatbotScreen(),
    const QuizScreen(),
    const StartInvestmentScreen(),
    const YourInvestmentScreen(),
    const TermsScreen(),
  ];

  void _onItemTapped(int index, {bool isDrawer = false}) {
    // print('index: $index, _selectedIndex: $_selectedIndex');
    if (_selectedIndex != index && isDrawer) Navigator.pop(context);
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invest Buddies'),
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType
            .fixed, // This is important for more than 3 items
        currentIndex: _selectedIndex,

        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chatbot',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.quiz),
            label: 'Quiz',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: 'Invest',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Portfolio',
          ),
        ],
      ),
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
    );
  }
}
