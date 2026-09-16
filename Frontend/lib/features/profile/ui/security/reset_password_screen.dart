import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:front_end/core/services/auth_storage.dart';
import 'package:front_end/core/services/api_config.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  bool isLoading = false;
  bool showNewPassword = false;
  bool showConfirmPassword = false;

  Future<void> resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    final resetToken =
        ModalRoute.of(context)!.settings.arguments as String;

    final token = await AuthStorage.getToken();

    setState(() => isLoading = true);

    final response = await http.post(
      Uri.parse("${ApiConfig.baseUrl}/api/user/reset-password"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "resetToken": resetToken,
        "newPassword": newPasswordController.text,
      }),
    );

    final data = jsonDecode(response.body);

    setState(() => isLoading = false);

    final theme = Theme.of(context);
    final color = theme.colorScheme;

    if (response.statusCode == 200) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: color.surface,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            "Success",
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: color.primary,
            ),
          ),
          content: Text(
            "Password updated successfully",
            style: theme.textTheme.bodyMedium?.copyWith(
              color: color.onSurface.withOpacity(0.7),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  "/profileSettings",
                  (route) => false,
                );
              },
              child: Text(
                "OK",
                style: TextStyle(
                    color: color.primary, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: color.surface,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            "Error",
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: color.error,
            ),
          ),
          content: Text(
            data["message"],
            style: theme.textTheme.bodyMedium?.copyWith(
              color: color.onSurface.withOpacity(0.7),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "OK",
                style: TextStyle(
                    color: color.primary, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme;

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
          icon: Icon(Icons.arrow_back_ios_new,
              size: 18, color: color.onSurface),
        ),
        title: Text(
          "Reset Password",
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

              // ─── Intro label ──────────────────────────────────────
              Text(
                "SET A NEW PASSWORD",
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                  color: color.onSurface.withOpacity(0.45),
                ),
              ),

              const SizedBox(height: 20),

              // ─── New Password ─────────────────────────────────────
              _passwordField(
                controller: newPasswordController,
                label: "New Password",
                obscure: !showNewPassword,
                showToggle: true,
                toggle: () =>
                    setState(() => showNewPassword = !showNewPassword),
                validator: (value) {
                  if (value == null || value.length < 8) {
                    return "Minimum 8 characters";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // ─── Confirm Password ─────────────────────────────────
              _passwordField(
                controller: confirmPasswordController,
                label: "Confirm Password",
                obscure: !showConfirmPassword,
                showToggle: false,
                toggle: () => setState(
                    () => showConfirmPassword = !showConfirmPassword),
                validator: (value) {
                  if (value != newPasswordController.text) {
                    return "Passwords do not match";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 32),

              // ─── Submit Button ────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: isLoading ? null : resetPassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color.primary,
                    foregroundColor: color.onPrimary,
                    elevation: 2,
                    shadowColor: color.primary.withOpacity(0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: isLoading
                      ? SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: color.onPrimary,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.lock_reset_rounded, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              "Reset Password",
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
    required bool showToggle,
    required VoidCallback toggle,
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