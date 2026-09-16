import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import 'package:front_end/core/services/auth_storage.dart';
import 'package:front_end/core/services/api_config.dart';
import 'package:front_end/core/providers/user_profile_provider.dart';
import 'package:front_end/core/providers/notification_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _startApp();
  }

  Future<bool> isTokenValid(String token) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/user/profile'),
        headers: {
          "Authorization": "Bearer $token",
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<void> _startApp() async {
    try {
      // 🔔 POKE THE PROVIDER: This ensures NotificationProvider
      // is initialized immediately on startup.
      final notifProvider = context.read<NotificationProvider>();
      debugPrint("🔔 [SplashScreen] NotificationProvider initialized.");

      await Future.delayed(const Duration(milliseconds: 600));
      final token = await AuthStorage.getToken();
      final name = await AuthStorage.getName();
      final email = await AuthStorage.getEmail();

      if (!mounted) return;

      if (token == null || token.isEmpty) {
        // Run FCM even for guests to ensure device registration.
        await notifProvider.initializeFcm();
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      final isValid = await isTokenValid(token);
      if (!mounted) return;

      if (!isValid) {
        await AuthStorage.logout();
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      context.read<UserProfileProvider>().setUser(
            userName: name ?? "",
            userEmail: email ?? "",
          );

      // 🔌 INITIALIZE SERVICES: Grab the FCM token and connect
      // WebSockets before entering the main app.
      await notifProvider.initializeFcm();
      await notifProvider.initializeSocketListeners();
      await notifProvider.registerFcmToken();

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/main');
    } catch (e) {
      debugPrint("❌ Splash Error: $e");
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  // ✅ ADDED THE MISSING BUILD METHOD: This fixes your error.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0F2027),
              Color(0xFF203A43),
              Color(0xFF2C5364),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "SproutPay",
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
