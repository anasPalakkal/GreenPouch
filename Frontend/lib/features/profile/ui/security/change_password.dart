import 'package:flutter/material.dart';
import 'package:front_end/features/profile/services/change_password_service.dart';
import 'package:front_end/core/services/auth_storage.dart';
import 'package:http/http.dart' as http;
import 'package:front_end/core/services/api_config.dart';
import 'package:front_end/core/services/auth_service.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController currentPasswordController =
      TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool obscureCurrent = true;
  bool obscureNew = true;
  bool obscureConfirm = true;

  String? currentPasswordError;

  void showSuccessAlert(String message) {
    final theme = Theme.of(context);
    final color = theme.colorScheme;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: color.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          "Success",
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: color.primary,
          ),
        ),
        content: Text(
          message,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: color.onSurface.withOpacity(0.7),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text(
              "OK",
              style: TextStyle(
                color: color.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _changePassword() async {
    setState(() {
      currentPasswordError = null;
    });

    if (!_formKey.currentState!.validate()) return;

    try {
      final result = await ChangePasswordService.changePassword(
        currentPasswordController.text.trim(),
        newPasswordController.text.trim(),
      );

      if (result["accessToken"] != null && result["refreshToken"] != null) {
        final name = await AuthStorage.getName();
        final email = await AuthStorage.getEmail();

        await AuthStorage.saveUser(
          token: result["accessToken"],
          refreshToken: result["refreshToken"],
          name: name ?? "",
          email: email ?? "",
        );
      }

      showSuccessAlert(
        result["message"] ?? "Password updated successfully",
      );
    } catch (e) {
      final message = e.toString().replaceAll("Exception: ", "");

      if (message.toLowerCase().contains("current password")) {
        setState(() {
          currentPasswordError = message;
        });

        _formKey.currentState!.validate();
      }
    }
  }

  @override
  void dispose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: color.surface,
      appBar: AppBar(
        backgroundColor: color.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          padding: EdgeInsets.zero,
          icon: Icon(
            Icons.arrow_back_ios_new,
            size: 18,
            color: color.onSurface,
          ),
        ),
        title: Text(
          "Change Password",
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: color.onSurface,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ─── Header Card ──────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: color.primary.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: color.primary.withOpacity(0.12),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: color.primary.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.lock_outline_rounded,
                        size: 22,
                        color: color.primary,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Update your password",
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: color.onSurface,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            "Choose a strong password to keep your account secure",
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: color.onSurface.withOpacity(0.5),
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ─── Section Label ────────────────────────────────────
              Text(
                "CURRENT PASSWORD",
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                  color: color.onSurface.withOpacity(0.45),
                ),
              ),

              const SizedBox(height: 10),

              // ─── Current Password ─────────────────────────────────
              _passwordField(
                controller: currentPasswordController,
                label: "Current Password",
                obscure: obscureCurrent,
                errorText: currentPasswordError,
                toggle: () => setState(() => obscureCurrent = !obscureCurrent),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Enter current password";
                  }
                  return currentPasswordError;
                },
              ),

              // ─── Forgot Password ──────────────────────────────────
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () async {
                    String? token = await AuthStorage.getToken();

                    http.Response response = await http.post(
                      Uri.parse(
                          "${ApiConfig.baseUrl}/api/user/forgot-password"),
                      headers: {
                        "Content-Type": "application/json",
                        "Authorization": "Bearer $token",
                      },
                    );

                    if (response.statusCode == 401) {
                      final newToken =
                          await AuthService.refreshAccessToken();

                      if (newToken == null) {
                        await AuthStorage.logout();
                        return;
                      }

                      response = await http.post(
                        Uri.parse(
                            "${ApiConfig.baseUrl}/api/user/forgot-password"),
                        headers: {
                          "Content-Type": "application/json",
                          "Authorization": "Bearer $newToken",
                        },
                      );
                    }

                    if (response.statusCode == 200) {
                      Navigator.pushNamed(context, "/otpVerification");
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Failed to send OTP")),
                      );
                    }
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    "Forgot Password?",
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: color.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Divider(
                height: 1,
                thickness: 0.5,
                color: color.outline.withOpacity(0.2),
              ),

              const SizedBox(height: 24),

              // ─── Section Label ────────────────────────────────────
              Text(
                "NEW PASSWORD",
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                  color: color.onSurface.withOpacity(0.45),
                ),
              ),

              const SizedBox(height: 10),

              // ─── New Password ─────────────────────────────────────
              _passwordField(
                controller: newPasswordController,
                label: "New Password",
                obscure: obscureNew,
                toggle: () => setState(() => obscureNew = !obscureNew),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Enter new password";
                  }
                  if (value.length < 8) {
                    return "Password must be at least 8 characters";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // ─── Confirm Password ─────────────────────────────────
              _passwordField(
                controller: confirmPasswordController,
                label: "Confirm Password",
                obscure: obscureConfirm,
                showToggle: false,
                toggle: () =>
                    setState(() => obscureConfirm = !obscureConfirm),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Confirm your password";
                  }
                  if (value != newPasswordController.text) {
                    return "Passwords do not match";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 12),

              // ─── Password Hint ────────────────────────────────────
              Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 13,
                    color: color.onSurface.withOpacity(0.4),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    "Must be at least 8 characters long",
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: color.onSurface.withOpacity(0.4),
                    ),
                  ),
                ],
              ),

              SizedBox(height: size.height * 0.06),

              // ─── Submit Button ────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _changePassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color.primary,
                    foregroundColor: color.onPrimary,
                    elevation: 2,
                    shadowColor: color.primary.withOpacity(0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.lock_reset_rounded, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        "Update Password",
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: color.onPrimary,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ─── Security Note ────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shield_outlined,
                    size: 13,
                    color: color.onSurface.withOpacity(0.35),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    "Your password is encrypted and stored securely",
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: color.onSurface.withOpacity(0.35),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _passwordField({
    required TextEditingController controller,
    required String label,
    required bool obscure,
    String? errorText,
    required VoidCallback toggle,
    bool showToggle = true,
    required String? Function(String?) validator,
  }) {
    final theme = Theme.of(context);
    final color = theme.colorScheme;

    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator,
      style: theme.textTheme.bodyMedium?.copyWith(color: color.onSurface),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: theme.textTheme.bodyMedium?.copyWith(
          color: color.onSurface.withOpacity(0.55),
        ),
        errorText: errorText,
        filled: true,
        fillColor: color.surfaceContainerHighest.withOpacity(0.5),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              BorderSide(color: color.outline.withOpacity(0.3), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: color.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: color.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: color.error, width: 1.5),
        ),
        suffixIcon: showToggle
            ? IconButton(
                icon: Icon(
                  obscure
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 20,
                  color: color.onSurface.withOpacity(0.45),
                ),
                onPressed: toggle,
              )
            : null,
      ),
    );
  }
}