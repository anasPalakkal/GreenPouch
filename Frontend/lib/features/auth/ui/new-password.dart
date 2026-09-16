import 'package:flutter/material.dart';
import '../services/authentication_service.dart';

class NewPasswordScreen extends StatefulWidget {
  final String email;
  final String resetToken;

  const NewPasswordScreen({
    super.key,
    required this.email,
    required this.resetToken,
  });

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmController = TextEditingController();

  bool showPassword = false;
  bool isLoading = false;

  @override
  void dispose() {
    passwordController.dispose();
    confirmController.dispose();
    super.dispose();
  }

  Future<void> handleReset() async {
    final password = passwordController.text.trim();
    final confirm = confirmController.text.trim();

    if (password.isEmpty || confirm.isEmpty) {
      _showSnack("Fill all fields");
      return;
    }

    if (password.length < 8) {
      _showSnack("Minimum 8 characters");
      return;
    }

    if (password != confirm) {
      _showSnack("Passwords do not match");
      return;
    }

    setState(() => isLoading = true);

    final success =
        await AuthService.resetPassword(widget.resetToken, password);

    if (!mounted) return;

    setState(() => isLoading = false);

    if (success == true) {
      _showSnack("Password reset successful");
      Navigator.popUntil(context, (route) => route.isFirst);
    } else if (success == false) {
      _showSnack("New password cannot be the same as old password");
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
                  SizedBox(height: size.height * 0.05),

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
                          'Set New Password',
                          style: textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                            color: isLight ? premiumDark : Colors.white,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          widget.email,
                          style: textTheme.bodyMedium?.copyWith(
                            color: isLight ? Colors.grey[600] : Colors.grey[400],
                            letterSpacing: 0.3,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: size.height * 0.05),

                  // ── NEW PASSWORD ─────────────────────────────────
                  _passwordField(
                    controller: passwordController,
                    hint: 'New Password',
                    isLight: isLight,
                    premiumGreen: premiumGreen,
                    premiumDark: premiumDark,
                  ),

                  const SizedBox(height: 14),

                  // ── CONFIRM PASSWORD ─────────────────────────────
                  _passwordField(
                    controller: confirmController,
                    hint: 'Confirm Password',
                    isLight: isLight,
                    premiumGreen: premiumGreen,
                    premiumDark: premiumDark,
                  ),

                  const SizedBox(height: 10),

                  // ── SHOW/HIDE TOGGLE ─────────────────────────────
                  GestureDetector(
                    onTap: () => setState(() => showPassword = !showPassword),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          showPassword ? 'Hide passwords' : 'Show passwords',
                          style: textTheme.bodySmall?.copyWith(
                            color: isLight ? Colors.grey[600] : Colors.grey[400],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 7),
                        Icon(
                          showPassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          size: 18,
                          color: isLight ? Colors.grey[600] : Colors.grey[400],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ── SET PASSWORD BUTTON ──────────────────────────
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
                      onPressed: isLoading ? null : handleReset,
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
                              'Set Password',
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
                        'Your new password will be encrypted',
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

  Widget _passwordField({
    required TextEditingController controller,
    required String hint,
    required bool isLight,
    required Color premiumGreen,
    required Color premiumDark,
  }) {
    return TextField(
      controller: controller,
      obscureText: !showPassword,
      style: TextStyle(
        color: isLight ? premiumDark : Colors.white,
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: isLight ? Colors.grey[400] : Colors.grey[600],
          fontSize: 15,
        ),
        prefixIcon: Icon(
          Icons.lock_outline_rounded,
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
          borderSide: BorderSide(
            color: premiumGreen,
            width: 2,
          ),
        ),
      ),
    );
  }
}