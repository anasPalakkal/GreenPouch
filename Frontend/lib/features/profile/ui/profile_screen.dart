import 'package:flutter/material.dart';
import 'package:front_end/features/profile/ui/security/change_password.dart';
import 'package:provider/provider.dart';
import 'package:front_end/core/theme/theme_provider.dart';
import 'package:front_end/features/profile/ui/support_legal/help_support.dart';
import 'package:front_end/features/profile/ui/support_legal/privacy_policy.dart';
import 'package:front_end/features/profile/ui/support_legal/terms_service.dart';
import 'package:front_end/features/profile/ui/about/about.dart';
import 'package:front_end/features/profile/ui/share/export_data.dart';
import 'package:front_end/features/profile/ui/premium/premium_feature.dart';
import 'package:front_end/features/profile/ui/edit-profile/profile_edit.dart';
import 'package:front_end/features/profile/ui/support_legal/feedback.dart';
import 'package:front_end/core/providers/user_profile_provider.dart';
import 'package:front_end/features/profile/ui/notifications/notification.dart';
import 'package:front_end/features/profile/ui/account/delete_account_screen.dart';
import 'package:front_end/features/profile/ui/account/sign_out_screen.dart';
import 'package:front_end/core/services/sound_service.dart ';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  bool pushNotifications = true;
  bool paymentReminders = true;
  bool goalMilestones = true;
  bool twoFactorAuth = false;

  String getInitials(String name) {
    if (name.trim().isEmpty) return "U";
    final parts = name.trim().split(" ").where((e) => e.isNotEmpty).toList();
    if (parts.isEmpty) return "U";
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<UserProfileProvider>().loadUser();
    });
  }

  String _themeSubtitle(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.system:
        return "System default";
      case AppThemeMode.light:
        return "Light";
      case AppThemeMode.dark:
        return "Dark";
    }
  }

  void _showThemeDialog(BuildContext context) {
    final themeProvider = context.read<ThemeProvider>();
    AppThemeMode selected = themeProvider.appThemeMode;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final theme = Theme.of(context);
            final color = theme.colorScheme;

            return AlertDialog(
              backgroundColor: color.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                "Choose theme",
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: color.onSurface,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: AppThemeMode.values.map((mode) {
                  final label = switch (mode) {
                    AppThemeMode.system => "System default",
                    AppThemeMode.light  => "Light",
                    AppThemeMode.dark   => "Dark",
                  };
                  return RadioListTile<AppThemeMode>(
                    value: mode,
                    groupValue: selected,
                    title: Text(
                      label,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: color.onSurface,
                      ),
                    ),
                    activeColor: const Color(0xFF1A8C72),
                    contentPadding: EdgeInsets.zero,
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() => selected = val);
                      }
                    },
                  );
                }).toList(),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    "Cancel",
                    style: TextStyle(color: color.onSurface.withOpacity(0.6)),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    themeProvider.setThemeMode(selected);
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "OK",
                    style: TextStyle(
                      color: Color(0xFF1A8C72),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme;
    final user = context.watch<UserProfileProvider>();
    
    // final isLight = theme.brightness == Brightness.light;
const Color premiumGreen = Color(0xFF0F766E);
const Color premiumDarkGreen = Color(0xFF4A6B36);

    String userName = user.name;
    String email = user.email;

    return Scaffold(
      backgroundColor: color.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── AppBar ───────────────────────────────────────────
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
                color: color.surface,
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.arrow_back_ios_new,
                          size: 20, color: color.onSurface),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Profile & Settings',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: color.onSurface,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ─── Profile Card ─────────────────────────────────────
              // ─── Profile Card ─────────────────────────────────────────
Padding(
  padding: const EdgeInsets.symmetric(horizontal: 16),
  child: Container(
    clipBehavior: Clip.hardEdge,
    decoration: BoxDecoration(
 gradient: const LinearGradient(
  colors: [
    Color(0xFF1A8C72), // lighter teal-green
    Color(0xFF2D6B4A), // lighter forest
    Color(0xFF1A4D30), // lighter dark forest
  ],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
),
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF0F766E).withOpacity(0.45),
          blurRadius: 28,
          offset: const Offset(0, 12),
        ),
      ],
      border: Border.all(
        color: Colors.white.withOpacity(0.08),
        width: 1,
      ),
    ),
    child: Stack(
      children: [

        // ── Decorative circle top-right ──────────────────
        Positioned(
          top: -38,
          right: -38,
          child: Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.05),
            ),
          ),
        ),

        // ── Decorative circle bottom-left ────────────────
        Positioned(
          bottom: -24,
          left: 10,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.04),
            ),
          ),
        ),

        // ── Decorative circle bottom-right ───────────────
        Positioned(
          bottom: 20,
          right: -12,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.03),
            ),
          ),
        ),

        // ── Card content ─────────────────────────────────
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── Top label ────────────────────────────
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: Colors.white.withOpacity(0.18),
                      width: 0.8),
                ),
                child: Text(
                  "MY ACCOUNT",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.70),
                    fontSize: 10,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ── Avatar + name row ─────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: Colors.white.withOpacity(0.35),
                          width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 30,
                      backgroundColor:
                          const Color(0xFF4A6B36).withOpacity(0.8),
                      child: Text(
                        getInitials(userName),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                userName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => EditProfileScreen(
                                        currentName: userName),
                                  ),
                                );
                                if (result != null) {
                                  context
                                      .read<UserProfileProvider>()
                                      .updateProfile(
                                          newName: result["name"]);
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 5),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius:
                                      BorderRadius.circular(20),
                                  border: Border.all(
                                      color:
                                          Colors.white.withOpacity(0.30)),
                                ),
                                child: const Text(
                                  "Edit",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          email,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.60),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // ── Divider ───────────────────────────────
              Container(
                height: 0.6,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.0),
                      Colors.white.withOpacity(0.25),
                      Colors.white.withOpacity(0.0),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // ── Premium button ────────────────────────
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const PremiumUpgradeScreen()),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFF59E0B), Color(0xFFF97316)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFF97316).withOpacity(0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.workspace_premium,
                          color: Colors.white, size: 18),
                      SizedBox(width: 8),
                      Text(
                        "Upgrade to Premium",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      SizedBox(width: 6),
                      Icon(Icons.arrow_forward_ios,
                          color: Colors.white, size: 12),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  ),
),
              const SizedBox(height: 24),
              // ─── Appearance ───────────────────────────────────────
              _sectionHeader(context, "Appearance"),
              _navigationTile(
                context,
                icon: Icons.palette_outlined,
                title: "Theme",
                subtitle: _themeSubtitle(context.watch<ThemeProvider>().appThemeMode),
                onTap: () => _showThemeDialog(context),
              ),

              const SizedBox(height: 8),

              // ─── Notifications ────────────────────────────────────
              _sectionHeader(context, "Notifications"),
              _navigationTile(
                context,
                icon: Icons.tune_outlined,
                title: "Notification Settings",
                subtitle: "Manage alerts & reminders",
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const NotificationScreen()));
                },
              ),

              const SizedBox(height: 8),

              // ─── Security ─────────────────────────────────────────
              _sectionHeader(context, "Security"),
              _navigationTile(
                context,
                icon: Icons.lock_outline,
                title: "Change Password",
                subtitle: "Update your credentials",
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const ChangePasswordScreen()));
                },
              ),

              const SizedBox(height: 8),

              // ─── Data Management ──────────────────────────────────
              _sectionHeader(context, "Data Management"),
              _navigationTile(
                context,
                icon: Icons.download_outlined,
                title: "Export Data",
                subtitle: "Download your financial records",
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const ExportDataScreen()));
                },
              ),

              const SizedBox(height: 8),

              // ─── Support & Legal ──────────────────────────────────
              _sectionHeader(context, "Support & Legal"),
              _navigationTile(
                context,
                icon: Icons.help_outline,
                title: "Help & Support",
                subtitle: "FAQs and contact us",
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const HelpSupportScreen()));
                },
              ),
              _inlineDivider(context),
              _navigationTile(
                context,
                icon: Icons.feedback_outlined,
                title: "Feedback & Rate Us",
                subtitle: "Share your experience",
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const FeedbackScreen()));
                },
              ),
              _inlineDivider(context),
              _navigationTile(
                context,
                icon: Icons.privacy_tip_outlined,
                title: "Privacy Policy",
                subtitle: "How we handle your data",
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const PrivacyPolicyScreen()));
                },
              ),
              _inlineDivider(context),
              _navigationTile(
                context,
                icon: Icons.description_outlined,
                title: "Terms of Service",
                subtitle: "Usage terms and conditions",
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const TermsOfServiceScreen()));
                },
              ),

              const SizedBox(height: 8),

              // ─── Account ──────────────────────────────────────────
              _sectionHeader(context, "Account"),
              _navigationTile(
                context,
                icon: Icons.logout_rounded,
                title: "Sign Out",
                subtitle: "Log out of your account",
                iconColor: Colors.orange,
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const SignOutScreen()));
                },
              ),
              _inlineDivider(context),
              _navigationTile(
                context,
                icon: Icons.delete_outline_rounded,
                title: "Delete Account",
                subtitle: "Permanently remove your data",
                iconColor: Theme.of(context).colorScheme.error,
                titleColor: Theme.of(context).colorScheme.error,
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const DeleteAccountScreen()));
                },
              ),

              const SizedBox(height: 8),

              // ─── About ────────────────────────────────────────────
              _sectionHeader(context, "About"),
              _navigationTile(
                context,
                icon: Icons.info_outline,
                title: "About GreenPouch",
                subtitle: "Version, licenses & more",
                onTap: () {
                  Navigator.push(context,
                     MaterialPageRoute(builder: (_) => const AboutGreenPouchScreen()));
                },
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Section Header ──────────────────────────────────────────────────
  Widget _sectionHeader(BuildContext context, String label) {
    final theme = Theme.of(context);
    final color = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 2),
      child: Text(
        label.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: 1.1,
          color: color.onSurface.withOpacity(0.45),
        ),
      ),
    );
  }

  // ─── Inline Divider ───────────────────────────────────────────────────
  Widget _inlineDivider(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 68),
      child: Divider(
        height: 1,
        thickness: 0.5,
        color: Theme.of(context).dividerColor.withOpacity(0.4),
      ),
    );
  }

  // ─── Navigation Tile ─────────────────────────────────────────────────
  Widget _navigationTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    Color? iconColor,
    Color? titleColor,
  }) {
    final theme = Theme.of(context);
    final color = theme.colorScheme;
    final resolvedIconColor = iconColor ?? color.onSurface.withOpacity(0.7);

    return Material(
      color: color.surface,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              Icon(icon, size: 22, color: resolvedIconColor),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: titleColor ?? color.onSurface,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: color.onSurface.withOpacity(0.45),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: color.onSurface.withOpacity(0.25),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Switch Tile ───────────────────────────────────────────────────────
Widget _switchTile(
  BuildContext context, {
  required IconData icon,
  required String title,
  String? subtitle,
  required bool value,
  required ValueChanged<bool> onChanged,
}) {
  final theme = Theme.of(context);
  final color = theme.colorScheme;
  final isLight = theme.brightness == Brightness.light;

  return Container(
    color: color.surface,
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    child: Row(
      children: [
        Icon(icon, size: 22, color: color.onSurface.withOpacity(0.7)),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: color.onSurface,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: color.onSurface.withOpacity(0.45),
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        ),
        Transform.scale(
          scale: 0.85,
          child: Switch(
            value: value,
            activeThumbColor: isLight ? Colors.white : Colors.black,
            activeTrackColor: isLight ? Colors.black : Colors.white,
            inactiveThumbColor: isLight ? Colors.black : Colors.black,
            inactiveTrackColor: isLight ? Colors.white : Colors.white24,
            onChanged: onChanged,
          ),
        ),
      ],
    ),
  );
}