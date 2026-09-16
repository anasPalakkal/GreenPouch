import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:front_end/core/services/api_config.dart';
import 'package:front_end/core/services/auth_storage.dart';
import 'package:front_end/features/auth/ui/login_screen.dart';

class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  final passwordController = TextEditingController();
  bool isLoading = false;
  bool obscurePassword = true;

  Future<void> deleteAccount() async {
    if (passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter your password")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final token = await AuthStorage.getToken();

      if (token == null) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Session expired. Please login again")),
        );
        return;
      }

      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/api/user/account'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({"password": passwordController.text.trim()}),
      );

      final data = jsonDecode(response.body);

      setState(() => isLoading = false);

      if (!mounted) return;

      if (response.statusCode == 200) {
        await AuthStorage.logout();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              data["message"] ??
                  "Account scheduled for deletion. Login within 14 days to restore.",
            ),
          ),
        );

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data["message"] ?? "Delete failed")),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Server error")),
      );
    }
  }

  Future<void> confirmDelete() async {
    final confirm = await showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        final color = theme.colorScheme;
        return AlertDialog(
          backgroundColor: color.surface,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            "Confirm Deletion",
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: color.error,
            ),
          ),
          content: Text(
            "Are you sure you want to delete your account?\n\n"
            "Your account will be permanently deleted after 14 days. "
            "You can restore it anytime by logging in again within this period.",
            style: theme.textTheme.bodyMedium?.copyWith(
              color: color.onSurface.withOpacity(0.7),
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                "Cancel",
                style: TextStyle(color: color.onSurface.withOpacity(0.6)),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(
                "Delete",
                style: TextStyle(
                    color: color.error, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      deleteAccount();
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
          "Delete Account",
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: color.onSurface,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            // ─── Icon ──────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: color.error.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.delete_outline_rounded,
                size: 48,
                color: color.error,
              ),
            ),

            const SizedBox(height: 20),

            // ─── Title ─────────────────────────────────────────────
            Text(
              "Delete Your Account",
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: color.onSurface,
              ),
            ),

            const SizedBox(height: 10),

            // ─── Description ───────────────────────────────────────
            Text(
              "This will deactivate your account. It will be permanently deleted after 14 days unless you log in again.",
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: color.onSurface.withOpacity(0.55),
                height: 1.6,
              ),
            ),

            const SizedBox(height: 12),

            // ─── Warning Chip ──────────────────────────────────────
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: color.error.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: color.error.withOpacity(0.2), width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.warning_amber_rounded,
                      size: 16, color: color.error),
                  const SizedBox(width: 8),
                  Text(
                    "This action cannot be undone after 14 days",
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: color.error,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ─── Password Field ────────────────────────────────────
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "CONFIRM PASSWORD",
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                  color: color.onSurface.withOpacity(0.45),
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: passwordController,
              obscureText: obscurePassword,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: color.onSurface),
              decoration: InputDecoration(
                hintText: "Enter your password",
                hintStyle: theme.textTheme.bodyMedium?.copyWith(
                  color: color.onSurface.withOpacity(0.4),
                ),
                filled: true,
                fillColor: color.surfaceContainerHighest.withOpacity(0.5),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                      color: color.outline.withOpacity(0.3), width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      BorderSide(color: color.primary, width: 1.5),
                ),
                prefixIcon: Icon(Icons.lock_outline,
                    size: 20, color: color.onSurface.withOpacity(0.45)),
                suffixIcon: IconButton(
                  icon: Icon(
                    obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    size: 20,
                    color: color.onSurface.withOpacity(0.45),
                  ),
                  onPressed: () =>
                      setState(() => obscurePassword = !obscurePassword),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // ─── Delete Button ─────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: isLoading ? null : confirmDelete,
                style: ElevatedButton.styleFrom(
                  backgroundColor: color.error,
                  foregroundColor: color.onError,
                  elevation: 2,
                  shadowColor: color.error.withOpacity(0.4),
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
                          color: color.onError,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.delete_outline_rounded,
                              size: 18),
                          const SizedBox(width: 8),
                          Text(
                            "Delete Account",
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: color.onError,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 12),

            // ─── Cancel Button ─────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 54,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: color.onSurface,
                  side: BorderSide(
                      color: color.outline.withOpacity(0.4), width: 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  "Cancel",
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: color.onSurface.withOpacity(0.7),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}