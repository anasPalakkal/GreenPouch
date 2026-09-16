import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';
import 'dart:io';
import 'package:http/http.dart' as http;

// --- NATIVE SPLASH ---
import 'package:flutter_native_splash/flutter_native_splash.dart';

// --- YOUR SERVICES & PROVIDERS ---
import 'core/theme/theme_provider.dart';
import 'core/theme/light_theme.dart';
import 'core/theme/dark_theme.dart';
import 'features/auth/ui/login_screen.dart';
import 'core/services/auth_storage.dart';
import 'core/services/api_config.dart';
import 'navigation/navigation_service.dart'; // Ensure this points to your MainNavigation
import 'features/analytics/provider/analytics_provider.dart';
import 'core/providers/user_profile_provider.dart';
import 'core/providers/transaction_provider.dart';
import 'core/providers/account_provider.dart';
import 'features/goals/provider/goal_provider.dart';
import 'core/providers/transfer_provider.dart';
import 'package:front_end/core/providers/notification_provider.dart';
import 'features/profile/ui/security/otp_verification_screen.dart';
import 'features/profile/ui/security/reset_password_screen.dart';
import 'features/profile/ui/profile_screen.dart';
import 'core/services/notification_channel_service.dart';

// --- FIREBASE ---
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'core/services/sound_service.dart';
// ── 1. GLOBAL KEYS & ROUTING ───────────────────────────────────────────
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
Widget? initialScreen;

// ── 2. BACKGROUND HANDLER ──────────────────────────────────────────────
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
}

// ── 3. FCM ROUTING LOGIC ───────────────────────────────────────────────
Future<void> setupFCMInteractions() async {
  RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
  if (initialMessage != null) {
    _handleNotificationRouting(initialMessage);
  }
  FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationRouting);
}

void _handleNotificationRouting(RemoteMessage message) {
  final type = message.data['type'];
  String? route;
  if (type == 'transaction' || type == 'wallet' || type == 'goal') route = '/main';
  route ??= message.data['route'];
  
  if (route != null && navigatorKey.currentState != null) {
    navigatorKey.currentState!.pushNamed(route);
  }
}

// ── 4. MAIN ENTRY POINT ────────────────────────────────────────────────
void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await SoundService.instance.init(); 

  final bool isMobile = !kIsWeb && (Platform.isAndroid || Platform.isIOS);
  
  if (isMobile) {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    await NotificationChannelService.initialize();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    setupFCMInteractions();
  }

  // AUTO-LOGIN LOGIC
  try {
    final token = await AuthStorage.getToken();
    if (token != null && token.isNotEmpty) {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/user/profile'),
        headers: {"Authorization": "Bearer $token"},
      ).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        initialScreen = const MainNavigation();
      } else {
        await AuthStorage.logout();
        initialScreen = const LoginScreen();
      }
    } else {
      initialScreen = const LoginScreen();
    }
  } catch (e) {
    initialScreen = const LoginScreen();
  }

  // Branding delay
  await Future.delayed(const Duration(milliseconds:250));

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NotificationProvider(), lazy: false),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => UserProfileProvider()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ChangeNotifierProvider(create: (_) => AccountProvider()),
        ChangeNotifierProvider(create: (_) => GoalProvider()),
        ChangeNotifierProvider(create: (_) => AnalyticsProvider()),
        ChangeNotifierProvider(create: (_) => TransferProvider()),
      ],
      child: const GreenPouch(),
    ),
  );

  FlutterNativeSplash.remove();
}

// ── 5. ROOT APP WIDGET ─────────────────────────────────────────────────
class GreenPouch extends StatelessWidget {
  const GreenPouch({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return ToastificationWrapper(
      child: MaterialApp(
        navigatorKey: navigatorKey, // <--- Fixed: navigatorKey is now defined!
        debugShowCheckedModeBanner: false,
        title: 'GreenPouch',
        theme: LightTheme.theme,
        darkTheme: DarkTheme.theme,
        themeMode: themeProvider.themeMode,
        
        home: initialScreen ?? const LoginScreen(),

        routes: {
          '/login': (_) => const LoginScreen(),
          '/main': (_) => const MainNavigation(),
          '/otpVerification': (_) => const OtpVerificationScreen(),
          '/resetPassword': (_) => const ResetPasswordScreen(),
          '/profileSettings': (_) => const ProfileSettingsScreen(),
        },
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: const TextScaler.linear(1.0),
            ),
            child: child ?? const SizedBox(),
          );
        },
      ),
    );
  }
}