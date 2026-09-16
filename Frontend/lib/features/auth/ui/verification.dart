import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:front_end/core/services/auth_storage.dart';
import 'package:front_end/core/providers/user_profile_provider.dart';
import 'package:front_end/navigation/navigation_service.dart';

import '../services/auth_service.dart';

class VerificationScreen extends StatefulWidget {
  final String email;

  const VerificationScreen({
    super.key,
    required this.email,
  });

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());

  final List<FocusNode> _focusNodes =
      List.generate(6, (_) => FocusNode());

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _handleInput(String value, int index) {
    if (_errorMessage != null) {
      setState(() => _errorMessage = null);
    }

    if (value.length > 1) {
      final digits = value.replaceAll(RegExp(r'\D'), '').split('');
      for (int i = 0; i < digits.length && i < 6; i++) {
        _controllers[i].text = digits[i];
      }
      _focusNodes.last.requestFocus();
      return;
    }

    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }

    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  Future<void> _verifyCode() async {
    if (_isLoading) return;

    final code = _controllers.map((e) => e.text).join();

    if (code.length != 6) {
      setState(() => _errorMessage = "Please enter the 6 digit code");
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await AuthService.verifyOtp(widget.email, code);

      if (!mounted) return;

      if (data["accessToken"] != null) {
        final user = data["user"] ?? {};

        await AuthStorage.saveUser(
          token: data["accessToken"],
          refreshToken: data["refreshToken"] ?? "",
          name: user["name"] ?? "",
          email: user["email"] ?? "",
        );

        context.read<UserProfileProvider>().setUser(
              userName: user["name"] ?? "",
              userEmail: user["email"] ?? "",
            );

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const MainNavigation()),
          (route) => false,
        );
      } else {
        setState(() =>
            _errorMessage = data["message"] ?? "OTP verification failed");
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = "Unable to verify OTP. Try again.");
      debugPrint("VERIFY OTP ERROR: $e");
    }

    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _resendOtp() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await AuthService.resendOtp(widget.email);

      if (!mounted) return;

      if (data["success"] == true) {
        for (var c in _controllers) {
          c.clear();
        }
        _focusNodes.first.requestFocus();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data["message"] ?? "OTP resent"),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      } else {
        setState(() =>
            _errorMessage = data["message"] ?? "Failed to resend OTP");
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = "Unable to resend OTP");
      debugPrint("RESEND OTP ERROR: $e");
    }

    if (mounted) setState(() => _isLoading = false);
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.06,
            vertical: 24,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: size.height * 0.06),

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
                          'Verify Your Email',
                          style: textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                            color: isLight ? premiumDark : Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Enter the 6-digit OTP sent to',
                          style: textTheme.bodyMedium?.copyWith(
                            color: isLight ? Colors.grey[600] : Colors.grey[400],
                            letterSpacing: 0.3,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.email,
                          style: textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isLight ? premiumDark : Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: size.height * 0.05),

                  // ── OTP BOXES ────────────────────────────────────
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final boxWidth =
                          max(48.0, (constraints.maxWidth - 40) / 6);

                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(6, (index) {
                          return SizedBox(
                            width: boxWidth,
                            height: 58,
                            child: TextField(
                              controller: _controllers[index],
                              focusNode: _focusNodes[index],
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              maxLength: 1,
                              autofillHints: const [AutofillHints.oneTimeCode],
                              textInputAction: index == 5
                                  ? TextInputAction.done
                                  : TextInputAction.next,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: isLight ? premiumDark : Colors.white,
                              ),
                              decoration: InputDecoration(
                                counterText: '',
                                filled: true,
                                fillColor: isLight
                                    ? Colors.white
                                    : Colors.grey[900],
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 14),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color: isLight
                                        ? Colors.grey.shade200
                                        : Colors.transparent,
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
                              ),
                              onChanged: (v) {
                                _handleInput(v, index);
                                final code = _controllers
                                    .map((e) => e.text)
                                    .join();
                                if (code.length == 6 && !_isLoading) {
                                  _verifyCode();
                                }
                              },
                            ),
                          );
                        }),
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  // ── ERROR MESSAGE ────────────────────────────────
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: textTheme.bodySmall?.copyWith(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                  // ── RESEND ROW ───────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Didn't receive the code?",
                        style: textTheme.bodySmall?.copyWith(
                          color: isLight ? Colors.grey[600] : Colors.grey[400],
                        ),
                      ),
                      TextButton(
                        onPressed: _isLoading ? null : _resendOtp,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                        ),
                        child: Text(
                          'Resend',
                          style: textTheme.bodySmall?.copyWith(
                            color: premiumGreen,
                            fontWeight: FontWeight.w700,
                            decoration: TextDecoration.underline,
                            decorationColor: premiumGreen,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ── VERIFY BUTTON ────────────────────────────────
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
                      onPressed: _isLoading ? null : _verifyCode,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: premiumGreen,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        disabledBackgroundColor: premiumGreen.withOpacity(0.6),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Verify & Continue',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // ── BACK BUTTON ──────────────────────────────────
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
                        'Back',
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

                  // ── EXPIRY NOTE ──────────────────────────────────
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
                        'OTP expires in 1 minute',
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
    );
  }
}