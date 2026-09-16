import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:ui';
import '../../core/constants/app_colors.dart';
import '../../core/providers/notification_provider.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  void _confirmDeleteAll(BuildContext context) async {
    HapticFeedback.mediumImpact();
    final bool? result = await showDialog<bool>(
      context: context,
      builder: (ctx) => const _ConfirmDialog(
        title: "Clear All Notifications?",
        message: "This will permanently delete all your notifications. This action cannot be undone.",
      ),
    );
    if (result == true && context.mounted) {
      context.read<NotificationProvider>().clearAllHistory();
      HapticFeedback.lightImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final notifications = context.watch<NotificationProvider>().notifications;
    final isLoading = context.watch<NotificationProvider>().isLoading;
    final unreadCount = notifications.where((n) => n["isRead"] == false).length;

    // Premium subtle tones
    final textSec = isDark ? const Color(0xFF8B90A7) : const Color(0xFF8A94A6);
    final bgGradientColors = isDark
        ? [const Color(0xFF0A0C14), const Color(0xFF121622)]
        : [const Color(0xFFF8FAFC), const Color(0xFFF1F5F9)];

    final cardBg = isDark ? const Color(0xFF1A1D2B) : Colors.white;

    return Scaffold(
      backgroundColor: Colors.transparent, 
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: bgGradientColors,
            stops: const [0.0, 1.0],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // ── PREMIUM HEADER ──
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 20, 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: Icon(Icons.arrow_back_ios_new_rounded, color: colorScheme.onSurface, size: 18),
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              Navigator.pop(context);
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Notifications",
                              style: TextStyle(
                                color: colorScheme.onSurface,
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.8,
                              ),
                            ),
                            if (unreadCount > 0) ...[
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(color: colorScheme.primary, shape: BoxShape.circle),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    "$unreadCount unread",
                                    style: TextStyle(
                                      color: colorScheme.primary,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                    if (notifications.isNotEmpty)
                      Row(
                        children: [
                          _buildActionIcon(
                            icon: Icons.done_all_rounded,
                            color: colorScheme.primary,
                            bgColor: colorScheme.primary.withOpacity(0.1),
                            onTap: () {
                              HapticFeedback.lightImpact();
                              context.read<NotificationProvider>().markAllAsRead();
                            },
                          ),
                          const SizedBox(width: 12),
                          _buildActionIcon(
                            icon: Icons.delete_outline_rounded,
                            color: Colors.redAccent,
                            bgColor: Colors.redAccent.withOpacity(0.1),
                            onTap: () => _confirmDeleteAll(context),
                          ),
                        ],
                      ),
                  ],
                ),
              ),

              // ── LIST VIEW ──
              Expanded(
                child: isLoading
                    ? Center(child: CircularProgressIndicator(color: colorScheme.primary, strokeWidth: 2.5))
                    : notifications.isEmpty
                        ? _buildEmptyState(colorScheme, textSec, isDark)
                        : ListView.builder(
                            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
                            itemCount: notifications.length,
                            itemBuilder: (context, index) {
                              final notif = notifications[index];
                              return _AnimatedListItem(
                                index: index,
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: _NotificationTile(
                                    notif: notif,
                                    colorScheme: colorScheme,
                                    cardBg: cardBg,
                                    textSec: textSec,
                                    isDark: isDark,
                                    onTap: () {
                                      HapticFeedback.lightImpact();
                                      if (notif["isRead"] == false) {
                                        context.read<NotificationProvider>().markSingleAsRead(notif["_id"]);
                                      }
                                    },
                                    onDelete: () {
                                      HapticFeedback.mediumImpact();
                                      context.read<NotificationProvider>().removeNotification(notif["_id"]);
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionIcon({required IconData icon, required Color color, required Color bgColor, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
        child: Icon(icon, size: 20, color: color),
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme, Color textSec, bool isDark) {
    return Center(
      child: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeOutQuart,
        tween: Tween<double>(begin: 0, end: 1),
        builder: (context, value, child) {
          return Opacity(
            opacity: value,
            child: Transform.translate(
              offset: Offset(0, 20 * (1 - value)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDark ? Colors.white.withOpacity(0.02) : Colors.black.withOpacity(0.02),
                      border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05)),
                    ),
                    child: Icon(Icons.notifications_none_rounded, size: 56, color: textSec.withOpacity(0.5)),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    "You're all caught up!",
                    style: TextStyle(color: colorScheme.onSurface, fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.5),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "No new notifications at the moment.",
                    style: TextStyle(color: textSec, fontSize: 15, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Animated Staggered List Item (Smoother Curve)
// ─────────────────────────────────────────────
class _AnimatedListItem extends StatelessWidget {
  final int index;
  final Widget child;

  const _AnimatedListItem({required this.index, required this.child});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 500 + (index * 50).clamp(0, 500)), // Subtle stagger
      curve: Curves.easeOutQuart, // Premium Apple-like curve
      tween: Tween<double>(begin: 0, end: 1),
      child: child,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - value)),
            child: child,
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
// Reusable Modern Notification Tile
// ─────────────────────────────────────────────
class _NotificationTile extends StatelessWidget {
  final Map<String, dynamic> notif;
  final ColorScheme colorScheme;
  final Color cardBg;
  final Color textSec;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _NotificationTile({
    required this.notif,
    required this.colorScheme,
    required this.cardBg,
    required this.textSec,
    required this.isDark,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final bool isRead = notif["isRead"] ?? false;

    IconData iconData = Icons.notifications_active_rounded;
    Color iconColor = colorScheme.primary;

    if (notif["category"] == "WALLET_TRANSACTION") {
      iconColor = AppColors.expenseAmount;
      iconData = Icons.account_balance_wallet_rounded;
    } else if (notif["category"] == "AUTH_SECURITY") {
      iconColor = Colors.orangeAccent;
      iconData = Icons.security_rounded;
    }

    String dateStr = "";
    if (notif["createdAt"] is Map && notif["createdAt"].containsKey("\$date")) {
      dateStr = notif["createdAt"]["\$date"];
    } else {
      dateStr = notif["createdAt"] ?? "";
    }

    return Dismissible(
      key: Key(notif["_id"].toString()),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        HapticFeedback.mediumImpact();
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => const _ConfirmDialog(
            title: "Remove Notification?",
            message: "Are you sure you want to delete this notification?",
          ),
        );
      },
      onDismissed: (direction) => onDelete(),
      background: Container(
        padding: const EdgeInsets.only(right: 28),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 28),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: isRead ? cardBg.withOpacity(0.4) : cardBg,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isRead ? Colors.transparent : iconColor.withOpacity(0.12),
              width: 1,
            ),
            boxShadow: isRead || isDark
                ? []
                : [
                    BoxShadow(
                      color: iconColor.withOpacity(0.06),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
          ),
          child: Stack(
            children: [
              // Sleeker Left Accent Line
              if (!isRead)
                Positioned(
                  left: 0,
                  top: 24,
                  bottom: 24,
                  child: Container(
                    width: 3,
                    decoration: BoxDecoration(
                      color: iconColor,
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(4),
                        bottomRight: Radius.circular(4),
                      ),
                      boxShadow: [
                        BoxShadow(color: iconColor.withOpacity(0.5), blurRadius: 8, offset: const Offset(2, 0)),
                      ],
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Premium Icon Badge
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            iconColor.withOpacity(0.15),
                            iconColor.withOpacity(0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: iconColor.withOpacity(0.1)),
                      ),
                      child: Icon(iconData, color: iconColor, size: 24),
                    ),
                    const SizedBox(width: 16),
                    // Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            notif["title"] ?? "",
                            style: TextStyle(
                              color: isRead ? textSec : colorScheme.onSurface,
                              fontSize: 16,
                              fontWeight: isRead ? FontWeight.w600 : FontWeight.w800,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            notif["message"] ?? "",
                            style: TextStyle(
                              color: isRead ? textSec.withOpacity(0.8) : textSec,
                              fontSize: 14,
                              height: 1.4,
                              fontWeight: isRead ? FontWeight.w400 : FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(Icons.schedule_rounded, size: 14, color: textSec.withOpacity(0.5)),
                              const SizedBox(width: 6),
                              Text(
                                _formatTime(dateStr),
                                style: TextStyle(
                                  color: textSec.withOpacity(0.7),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(String iso) {
    if (iso.isEmpty) return "";
    try {
      final date = DateTime.parse(iso).toLocal();
      final now = DateTime.now();
      final diff = now.difference(date);
      if (diff.inMinutes < 1) return "Just now";
      if (diff.inMinutes < 60) return "${diff.inMinutes}m ago";
      if (diff.inHours < 24) return "${diff.inHours}h ago";
      if (diff.inDays < 7) return "${diff.inDays}d ago";
      return DateFormat('MMM dd, yyyy • h:mm a').format(date);
    } catch (_) {
      return "";
    }
  }
}

// ─────────────────────────────────────────────
// Premium Confirm Dialog
// ─────────────────────────────────────────────
class _ConfirmDialog extends StatelessWidget {
  final String title;
  final String message;

  const _ConfirmDialog({required this.title, required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF161925).withOpacity(0.9) : Colors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: Colors.white.withOpacity(isDark ? 0.05 : 0.2), width: 1.5),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 40, offset: const Offset(0, 20)),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.delete_sweep_rounded, color: Colors.redAccent, size: 36),
                ),
                const SizedBox(height: 24),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: colorScheme.onSurface, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: -0.5),
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 15, height: 1.5, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          Navigator.pop(context, false);
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.04),
                          foregroundColor: colorScheme.onSurface,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Text("Cancel", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          Navigator.pop(context, true);
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        child: const Text("Remove", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}