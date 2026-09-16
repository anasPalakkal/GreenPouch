import 'package:flutter/material.dart';

import 'forgot-password-otp-verification.dart';
import '../services/authentication_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();

  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

    final email = emailController.text.trim();

    setState(() => isLoading = true);

    final message = await AuthService.forgotPassword(email);

    if (message == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to send OTP")),
      );
      setState(() => isLoading = false);
      return;
    }

    if (!mounted) return;

    setState(() => isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("If the email exists, an OTP has been sent"),
      ),
    );

    await Future.delayed(const Duration(milliseconds: 300));

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OtpVerificationScreen(email: email),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // --- PREMIUM FINTECH COLORS (Matching Login & Signup) ---
    const Color premiumGreen = Color(0xFF10B981);
    const Color premiumDark = Color.fromARGB(255, 0, 0, 0);

    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final isLight = theme.brightness == Brightness.light;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: isLight ? const Color(0xFFF8FAFC) : premiumDark,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.06,
            vertical: 24,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: size.height * 0.05),

                    // ── LOGO & HEADING ───────────────────────────────
                    Center(
                      child: Column(
                        children: [
                          Container(
                            width: 110,
                            height: 110,
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
                                'assets/images/GrassHopper.png',
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Icon(
                                  Icons.eco_rounded,
                                  color: premiumGreen,
                                  size: 50,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Forgot Password?',
                            style: textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                              color: isLight ? premiumDark : Colors.white,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'No worries, we\'ll send you a 6-digit OTP',
                            textAlign: TextAlign.center,
                            style: textTheme.bodyMedium?.copyWith(
                              color: isLight ? Colors.grey[600] : Colors.grey[400],
                              letterSpacing: 0.3,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: size.height * 0.06),

                    // ── EMAIL FIELD ──────────────────────────────────
                    TextFormField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: TextStyle(
                        color: isLight ? premiumDark : Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Enter your email";
                        }
                        if (!value.contains("@")) {
                          return "Enter a valid email";
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: 'Enter your email address',
                        hintStyle: TextStyle(
                          color: isLight ? Colors.grey[400] : Colors.grey[600],
                          fontSize: 15,
                        ),
                        prefixIcon: Icon(
                          Icons.mail_outline_rounded,
                          color: isLight ? Colors.grey[500] : Colors.grey[400],
                          size: 22,
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
                            color: isLight ? Colors.grey.shade200 : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: premiumGreen,
                            width: 2,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                              color: Colors.redAccent, width: 1.5),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                              color: Colors.redAccent, width: 1.5),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // ── SEND OTP BUTTON ──────────────────────────────
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
                        onPressed: isLoading ? null : _sendOtp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: premiumGreen,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          disabledBackgroundColor: premiumGreen.withOpacity(0.6),
                        ),
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
                                'Send OTP',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // ── BACK TO SIGN IN ──────────────────────────────
                    SizedBox(
                      height: 56,
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(
                          Icons.arrow_back_rounded,
                          size: 20,
                          color: isLight ? premiumDark : Colors.white,
                        ),
                        label: Text(
                          'Back to Sign In',
                          style: TextStyle(
                            color: isLight ? premiumDark : Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
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
                      ),
                    ),

                    const SizedBox(height: 32),

                    // ── OTP VALIDITY NOTE ────────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 13,
                          color: isLight ? Colors.grey[500] : Colors.grey[400],
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'OTP will be valid for 15 minutes',
                          style: textTheme.bodySmall?.copyWith(
                            color: isLight ? Colors.grey[500] : Colors.grey[400],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}