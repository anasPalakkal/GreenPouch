import 'package:flutter/material.dart';
import 'features/auth/ui/login_screen.dart';

void main() {
  runApp(const WalletCareApp());
}

class WalletCareApp extends StatelessWidget {
  const WalletCareApp({super.key});

  @override
  Widget build(BuildContext context){
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Moneycart',
      home: const LoginScreen(),
      routes: {
        '/signup': (context) => const Scaffold(
              body: Center(child: Text('Signup Screen')),
            ),
        '/forgot-password': (context) => const Scaffold(
              body: Center(child: Text('Forgot Password')),
            ),
      },
    );
  }
}