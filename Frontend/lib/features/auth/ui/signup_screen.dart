import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'package:front_end/features/auth/ui/verification.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool agreeTerms = false;
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  bool isLoading = false;

  // --- PREMIUM FINTECH COLORS (Matching Login) ---
  final Color premiumGreen = const Color(0xFF10B981);
 final Color premiumDark = const Color.fromARGB(255, 0, 0, 0);

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (!agreeTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must agree to the Terms & Privacy Policy'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (isLoading) return;

    setState(() => isLoading = true);

    try {
      final data = await AuthService.signup(
        nameController.text.trim(),
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      if (!mounted) return;

      if (data["success"] == true) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => VerificationScreen(
              email: emailController.text.trim(),
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data["message"]),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong"),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  // --- REUSABLE FIELD DECORATOR (Matching Login Style) ---
  InputDecoration _fieldDecoration({
    required String hint,
    required IconData prefixIcon,
    required bool isLight,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: isLight ? Colors.grey[400] : Colors.grey[600],
        fontSize: 15,
      ),
      prefixIcon: Icon(
        prefixIcon,
        color: isLight ? Colors.grey[500] : Colors.grey[400],
        size: 22,
      ),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: isLight ? Colors.white : Colors.grey[900],
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
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
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    final textTheme = theme.textTheme;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: isLight ? const Color(0xFFF8FAFC) : premiumDark,
      // ── BACK BUTTON ──────────────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: isLight ? premiumDark : Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.08,
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
                    SizedBox(height: size.height * 0.02),

                    // ── PREMIUM LOGO & HEADING ───────────────────────
                    Center(
                      child: Column(
                        children: [
                          Container(
                            width: 110, // Slightly smaller than login for spacing
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
                            'Create Account',
                            style: textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                              color: isLight ? premiumDark : Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Start your financial journey with Green Pouch',
                            style: textTheme.bodyMedium?.copyWith(
                              color: isLight ? Colors.grey[600] : Colors.grey[400],
                              letterSpacing: 0.3,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: size.height * 0.05),

                    // ── FULL NAME ────────────────────────────────────
                    TextFormField(
                      controller: nameController,
                      style: TextStyle(
                        color: isLight ? premiumDark : Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Full Name is required';
                        }
                        return null;
                      },
                      decoration: _fieldDecoration(
                        hint: 'Full Name',
                        prefixIcon: Icons.person_outline_rounded,
                        isLight: isLight,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── EMAIL ────────────────────────────────────────
                    TextFormField(
                      controller: emailController,
                      style: TextStyle(
                        color: isLight ? premiumDark : Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Email is required';
                        }
                        if (!value.contains('@')) {
                          return 'Enter a valid email address';
                        }
                        return null;
                      },
                      decoration: _fieldDecoration(
                        hint: 'Email Address',
                        prefixIcon: Icons.mail_outline_rounded,
                        isLight: isLight,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── PASSWORD ─────────────────────────────────────
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
                      decoration: _fieldDecoration(
                        hint: 'Password',
                        prefixIcon: Icons.lock_outline_rounded,
                        isLight: isLight,
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: isLight ? Colors.grey[500] : Colors.grey[400],
                            size: 22,
                          ),
                          onPressed: () => setState(() {
                            obscurePassword = !obscurePassword;
                          }),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── CONFIRM PASSWORD ─────────────────────────────
                    TextFormField(
                      controller: confirmPasswordController,
                      obscureText: obscureConfirmPassword,
                      style: TextStyle(
                        color: isLight ? premiumDark : Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your password';
                        }
                        if (value != passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                      decoration: _fieldDecoration(
                        hint: 'Confirm Password',
                        prefixIcon: Icons.lock_outline_rounded,
                        isLight: isLight,
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscureConfirmPassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: isLight ? Colors.grey[500] : Colors.grey[400],
                            size: 22,
                          ),
                          onPressed: () => setState(() {
                            obscureConfirmPassword = !obscureConfirmPassword;
                          }),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── TERMS CHECKBOX ───────────────────────────────
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: Checkbox(
                            value: agreeTerms,
                            activeColor: premiumGreen, // Use brand color
                            checkColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            side: BorderSide(
                              color: isLight ? Colors.grey[400]! : Colors.grey[600]!,
                              width: 1.5,
                            ),
                            onChanged: (v) =>
                                setState(() => agreeTerms = v ?? false),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'I agree to the Terms of Service and Privacy Policy',
                            style: textTheme.bodySmall?.copyWith(
                              color: isLight ? Colors.grey[600] : Colors.grey[400],
                              height: 1.4,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // ── CREATE ACCOUNT BUTTON ────────────────────────
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
                        onPressed: isLoading ? null : _submit,
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
                                'Create Account',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── DIVIDER ──────────────────────────────────────
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
                            'ALREADY HAVE AN ACCOUNT?',
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
                            color: isLight ? Colors.grey.shade300 : Colors.grey.shade700,
                            width: 2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // ── SECURITY BADGE ───────────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.lock_outline_rounded,
                          size: 14,
                          color: isLight ? Colors.grey[500] : Colors.grey[400],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Your information is secure and encrypted',
                          style: textTheme.bodySmall?.copyWith(
                            color: isLight ? Colors.grey[500] : Colors.grey[400],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),
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