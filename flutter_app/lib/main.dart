import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/firebase_options.dart';
import 'package:flutter_app/providers/users_providers.dart';
import 'package:flutter_app/screens/authentication/auth.dart';
import 'package:flutter_app/screens/home_screen.dart';
import 'package:flutter_app/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    );
  }
}
