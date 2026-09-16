import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:front_end/core/widgets/custom_text_field.dart';
import 'signup_screen.dart';
import 'forgot_password_gmail.dart';
import '../../../core/services/api_config.dart';
import 'package:front_end/core/services/auth_storage.dart';
import 'package:front_end/core/providers/user_profile_provider.dart';
import 'package:front_end/core/providers/notification_provider.dart';
import 'package:provider/provider.dart';
import 'dart:io'; // for SocketException
import 'dart:async'; // for TimeoutException
import 'package:connectivity_plus/connectivity_plus.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool obscurePassword = true;
  bool isLoading = false; // 1️⃣ ADDED: Loading state variable

  // --- PREMIUM FINTECH COLORS ---
  final Color premiumGreen = const Color(0xFF10B981); // Rich modern green
  final Color premiumDark = const Color.fromARGB(255, 0, 0, 0); // Slate dark

  @override
  void initState() {
    super.initState();
    _checkAlreadyLoggedIn();
  }

  Future<void> _checkAlreadyLoggedIn() async {
    final token = await AuthStorage.getToken();
    if (token != null && token.isNotEmpty) {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/main');
    }
  }

  Future<void> loginUser() async {
    if (isLoading) return; // Prevent double-clicking

    setState(() {
      isLoading = true; // 2️⃣ ADDED: Start loading
    });

    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) {
      if (!mounted) return;
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No internet connection. Please check your network."),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/api/auth/login');

      final response = await http
          .post(
            url,
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              "email": emailController.text.trim(),
              "password": passwordController.text.trim(),
            }),
          )
          .timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data["accessToken"] != null) {
        final user = data["user"];
        final name = user["name"];
        final email = user["email"];

        await AuthStorage.saveUser(
          token: data["accessToken"],
          refreshToken: data["refreshToken"] ?? "",
          name: name,
          email: email,
        );

        if (!mounted) return;
        context.read<UserProfileProvider>().setUser(
              userName: name,
              userEmail: email,
            );

        await context.read<NotificationProvider>().initializeSocketListeners();
        await context.read<NotificationProvider>().initializeFcm();
        await context.read<NotificationProvider>().registerFcmToken();

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data["message"] ?? "Login successful"),
            backgroundColor: premiumGreen, // Matches new theme
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );

        Navigator.pushReplacementNamed(context, '/main');
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data["message"] ?? "Login failed"),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      String errorMessage = "Unable to connect to server";

      if (e is SocketException) {
        errorMessage = "No internet connection. Please check your network.";
      } else if (e is TimeoutException) {
        errorMessage = "Connection timed out. Try again.";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      // 3️⃣ ADDED: Stop loading whether it succeeds or fails
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    final textTheme = theme.textTheme;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: isLight ? const Color(0xFFF8FAFC) :premiumDark,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.08,
            vertical: 24,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: size.height * 0.08),

                // ── LOGO & BRANDING ──────────────────────────────────
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: isLight ? Colors.white : Colors.grey[800],
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: premiumGreen.withOpacity(0.25),
                              blurRadius: 24,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(2),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/login.png',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Icon(
                              Icons.eco_rounded,
                              color: premiumGreen,
                              size: 40,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Green Pouch',
                        style: textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                          color: isLight ? premiumDark : Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Secure Financial Management',
                        style: textTheme.bodyMedium?.copyWith(
                          color: isLight ? Colors.grey[600] : Colors.grey[400],
                          letterSpacing: 0.3,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: size.height * 0.08),

                // ── EMAIL ────────────────────────────────────────────
                CustomTextField(
                  hintText: 'Email Address',
                  controller: emailController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Email is required';
                    }
                    if (!value.contains('@')) {
                      return 'Enter a valid email address';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // ── PASSWORD ─────────────────────────────────────────
                TextFormField(
                  controller: passwordController,
                  obscureText: obscurePassword,
                  style: TextStyle(
                    color: isLight ? premiumDark : Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password is required';
                    }
                    if (value.length < 8) {
                      return 'Password must be at least 8 characters';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: 'Enter your password',
                    hintStyle: TextStyle(
                      color: isLight ? Colors.grey[400] : Colors.grey[600],
                      fontSize: 15,
                    ),
                    prefixIcon: Icon(
                      Icons.lock_outline_rounded,
                      color: isLight ? Colors.grey[500] : Colors.grey[400],
                      size: 22,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: isLight ? Colors.grey[500] : Colors.grey[400],
                        size: 22,
                      ),
                      onPressed: () =>
                          setState(() => obscurePassword = !obscurePassword),
                    ),
                    filled: true,
                    fillColor: isLight ? Colors.white : Colors.grey[900],
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 18,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color:
                            isLight ? Colors.grey.shade200 : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: premiumGreen,
                        width: 2,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide:
                          const BorderSide(color: Colors.redAccent, width: 1.5),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // ── SIGN IN BUTTON ───────────────────────────────────
                Container(
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: premiumGreen.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    // 4️⃣ ADDED: Disable button when loading
                    onPressed: isLoading
                        ? null
                        : () {
                            if (_formKey.currentState!.validate()) {
                              loginUser();
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: premiumGreen,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      // Keeps it green but slightly faded when disabled
                      disabledBackgroundColor: premiumGreen.withOpacity(0.7),
                    ),
                    // 5️⃣ ADDED: Show Spinner or Text based on isLoading
                    child: isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Sign In',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 16),

                // ── FORGOT PASSWORD (Centered Below Sign In) ─────────
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ForgotPasswordScreen(),
                        ),
                      );
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                    ),
                    child: Text(
                      'Forgot password?',
                      style: TextStyle(
                        color: premiumGreen,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: size.height * 0.04),

                // ── DIVIDER ──────────────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: isLight ? Colors.grey[300] : Colors.grey[800],
                        thickness: 1.5,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'NEW TO GREEN POUCH?',
                        style: textTheme.labelSmall?.copyWith(
                          color: isLight ? Colors.grey[500] : Colors.grey[400],
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: isLight ? Colors.grey[300] : Colors.grey[800],
                        thickness: 1.5,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // ── CREATE ACCOUNT ───────────────────────────────────
                SizedBox(
                  height: 56,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SignupScreen(),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: isLight
                            ? Colors.grey.shade300
                            : Colors.grey.shade700,
                        width: 2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      'Create Account',
                      style: TextStyle(
                        color: isLight ? premiumDark : Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}