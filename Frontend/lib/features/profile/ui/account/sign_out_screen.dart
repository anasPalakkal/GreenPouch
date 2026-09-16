import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:front_end/core/providers/user_profile_provider.dart';
import 'package:front_end/core/services/auth_storage.dart';
import 'package:front_end/features/auth/ui/login_screen.dart';

class SignOutScreen extends StatelessWidget {
  const SignOutScreen({super.key});

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
          "Sign Out",
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
                color: Colors.orange.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.logout_rounded,
                size: 48,
                color: Colors.orange,
              ),
            ),

            const SizedBox(height: 20),

            // ─── Title ─────────────────────────────────────────────
            Text(
              "Sign Out",
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: color.onSurface,
              ),
            ),

            const SizedBox(height: 10),

            // ─── Description ───────────────────────────────────────
            Text(
              "Are you sure you want to sign out of your account?",
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: color.onSurface.withOpacity(0.55),
                height: 1.6,
              ),
            ),

            const SizedBox(height: 48),

            // ─── Sign Out Button ───────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () async {
                  await AuthStorage.logout();
                  if (!context.mounted) return;
                  context.read<UserProfileProvider>().clearUser();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shadowColor: Colors.orange.withOpacity(0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.logout_rounded, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      "Sign Out",
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.white,
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