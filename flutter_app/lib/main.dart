import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/firebase_options.dart';
import 'package:flutter_app/providers/users_providers.dart';
import 'package:flutter_app/screens/authentication/auth.dart';
import 'package:flutter_app/screens/authentication/registeration.dart';
import 'package:flutter_app/screens/core/business/business_application.dart';
import 'package:flutter_app/screens/home_screen.dart';
import 'package:flutter_app/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_app/screens/legal/terms_and_conditions_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    ProviderScope(
      child: Consumer(
        builder: (context, ref, _) {
          final user = ref.watch(userProvider);
          print(user.email);
          return MyApp(
            initialScreen: user.email != null && user.email != ''
                ? const HomeScreen()
                : const Auth(),
          );
        },
      ),
    ),
  );
}

class MyApp extends ConsumerWidget {
  final Widget initialScreen;
  const MyApp({super.key, required this.initialScreen});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Invest Buddies',
      home: initialScreen,
      theme: theme,
      routes: {
        '/terms': (context) => const TermsAndConditionsScreen(),
      },
    );
  }
}

// class _MyAppState extends ConsumerState<MyApp> {
//   @override
//   // void initState() {
//   //   super.initState();
//   //   final user = ref.read(userProvider);
//   //   if (user.email != null) {
//   //     Navigator.pushReplacement(
//   //       context,
//   //       MaterialPageRoute(builder: (context) => HomeScreen()),
//   //     );
//   //   }
//   // }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Invest Buddies',
//       home: const Auth(),
//       // home: const BusinessApplicationScreen(),
//       theme: theme,
//     );
//   }
// }
