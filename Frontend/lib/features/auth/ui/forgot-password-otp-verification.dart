import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/authentication_service.dart';
import 'new-password.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String? email;

  const OtpVerificationScreen({
    super.key,
    this.email,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> controllers =
      List.generate(6, (_) => TextEditingController());

  final List<FocusNode> focusNodes = List.generate(6, (_) => FocusNode());

  Timer? timer;
  int resendSeconds = 60;
  bool canResend = false;
  bool isLoading = false;

  String getOtp() => controllers.map((e) => e.text).join();

  @override
  void initState() {
    super.initState();
    startTimer();
    // listen for clipboard paste on each focus node
    for (int i = 0; i < 6; i++) {
      focusNodes[i].addListener(() => _onFocusChange(i));
    }
  }

  // auto-paste when a box gains focus and clipboard has 6 digits
  void _onFocusChange(int index) async {
    if (!focusNodes[index].hasFocus) return;
    final data = await Clipboard.getData('text/plain');
    if (data == null || data.text == null) return;
    final text = data.text!.trim();
    if (text.length == 6 && RegExp(r'^\d{6}$').hasMatch(text)) {
      _pasteOtp(text);
    }
  }

  // fill all 6 boxes from a 6-digit string and auto-verify
  void _pasteOtp(String otp) {
    for (int i = 0; i < 6; i++) {
      controllers[i].text = otp[i];
    }
    // move focus to last box
    focusNodes[5].requestFocus();
    setState(() {});
    // slight delay so UI updates before verify
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) verifyOtp();
    });
  }

  void startTimer() {
    setState(() {
      resendSeconds = 60;
      canResend = false;
    });
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (resendSeconds == 0) {
        t.cancel();
        setState(() => canResend = true);
      } else {
        setState(() => resendSeconds--);
      }
    });
  }

  Future<void> verifyOtp() async {
    final otp = getOtp();

    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter valid OTP")),
      );
      return;
    }

    if (widget.email == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email missing")),
      );
      return;
    }

    setState(() => isLoading = true);

    final resetToken = await AuthService.verifyOtp(widget.email!, otp);

    if (!mounted) return;

    setState(() => isLoading = false);

    if (resetToken != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => NewPasswordScreen(
            email: widget.email!,
            resetToken: resetToken,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid or expired OTP")),
      );
    }
  }

  Future<void> resendOtp() async {
    if (!canResend) return;

    if (widget.email == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email not found")),
      );
      return;
    }

    final success = await AuthService.resendOtp(widget.email!);

    if (!mounted) return;

    if (success) {
      for (var c in controllers) {
        c.clear();
      }
      focusNodes.first.requestFocus();
      startTimer();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("New OTP sent to email")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please wait before retrying")),
      );
    }
  }

  Widget otpBox(int index, bool isLight) {
    // --- PREMIUM FINTECH COLORS (Matching Login & Signup) ---
    const Color premiumGreen = Color(0xFF10B981);
    const Color premiumDark = Color.fromARGB(255, 0, 0, 0);

    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        height: 58,
        child: KeyboardListener(
          focusNode: FocusNode(),
          onKeyEvent: (event) {
            // handle physical backspace key (desktop/hardware keyboard)
            if (event is KeyDownEvent &&
                event.logicalKey == LogicalKeyboardKey.backspace) {
              if (controllers[index].text.isEmpty && index > 0) {
                controllers[index - 1].clear();
                focusNodes[index - 1].requestFocus();
              }
            }
          },
          child: TextField(
            controller: controllers[index],
            focusNode: focusNodes[index],
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            maxLength: 1,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: isLight ? premiumDark : Colors.white,
            ),
            decoration: InputDecoration(
              counterText: '',
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
              filled: true,
              fillColor: isLight ? Colors.white : Colors.grey[900],
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
              focusedBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(16)),
                borderSide: BorderSide(
                  color: premiumGreen,
                  width: 2,
                ),
              ),
            ),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (value) {
              if (value.length > 1) {
                // handle paste via onChanged (some Android keyboards)
                if (value.length == 6 && RegExp(r'^\d{6}$').hasMatch(value)) {
                  _pasteOtp(value);
                  return;
                }
                // truncate to 1 digit
                controllers[index].text = value[0];
                controllers[index].selection = TextSelection.fromPosition(
                  TextPosition(offset: controllers[index].text.length),
                );
              }

              if (value.isNotEmpty && index < 5) {
                // advance to next box
                focusNodes[index + 1].requestFocus();
              }

              if (value.isEmpty && index > 0) {
                // go back to previous box
                focusNodes[index - 1].requestFocus();
              }

              // auto-verify when all 6 filled
              if (getOtp().length == 6) {
                Future.delayed(const Duration(milliseconds: 100), () {
                  if (mounted) verifyOtp();
                });
              }
            },
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    for (var c in controllers) {
      c.dispose();
    }
    for (var f in focusNodes) {
      f.dispose();
    }
    super.dispose();
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

                  // ── ICON & HEADING ───────────────────────────────
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
                          'Verify OTP',
                          style: textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                            color: isLight ? premiumDark : Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Enter the 6-digit code sent to',
                          style: textTheme.bodyMedium?.copyWith(
                            color: isLight ? Colors.grey[600] : Colors.grey[400],
                            letterSpacing: 0.3,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.email ?? 'your email',
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
                  Row(
                    children: List.generate(6, (i) => otpBox(i, isLight)),
                  ),

                  const SizedBox(height: 32),

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
                      onPressed: isLoading ? null : verifyOtp,
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
                              'Verify OTP',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── RESEND ROW ───────────────────────────────────
                  Center(
                    child: canResend
                        ? GestureDetector(
                            onTap: resendOtp,
                            child: Text(
                              'Resend OTP',
                              style: textTheme.bodyMedium?.copyWith(
                                color: premiumGreen,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
                                decorationColor: premiumGreen,
                              ),
                            ),
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.access_time_rounded,
                                size: 14,
                                color: isLight ? Colors.grey[500] : Colors.grey[400],
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Resend OTP in ${resendSeconds}s',
                                style: textTheme.bodySmall?.copyWith(
                                  color: isLight ? Colors.grey[500] : Colors.grey[400],
                                ),
                              ),
                            ],
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

                  // ── SECURITY NOTE ────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.lock_outline_rounded,
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
    );
  }
}