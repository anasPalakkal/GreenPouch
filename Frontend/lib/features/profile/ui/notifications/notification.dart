import 'package:flutter/material.dart';
import 'package:front_end/core/services/sound_service.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  bool pushNotifications = true;
  bool paymentReminders = true;
  bool goalMilestones = true;
  bool weeklyReports = false;
  bool promotions = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme;
    final isLight = theme.brightness == Brightness.light;

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
          "Notifications",
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: color.onSurface,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Text(
              "PREFERENCES",
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: 1.1,
                color: color.onSurface.withOpacity(0.45),
              ),
            ),

            const SizedBox(height: 12),

            _notificationTile(
              context,
              icon: Icons.notifications_outlined,
              title: "Push Notifications",
              subtitle: "Receive general app notifications",
              value: pushNotifications,
              onChanged: (v) => setState(() => pushNotifications = v),
              isLight: isLight,
            ),

            _divider(context),

            _notificationTile(
              context,
              icon: Icons.payment_outlined,
              title: "Payment Reminders",
              subtitle: "Get reminders for upcoming payments",
              value: paymentReminders,
              onChanged: (v) => setState(() => paymentReminders = v),
              isLight: isLight,
            ),

            _divider(context),

            _notificationTile(
              context,
              icon: Icons.flag_outlined,
              title: "Goal Milestones",
              subtitle: "Notifications when you reach savings goals",
              value: goalMilestones,
              onChanged: (v) => setState(() => goalMilestones = v),
              isLight: isLight,
            ),

            _divider(context),

            _notificationTile(
              context,
              icon: Icons.bar_chart_outlined,
              title: "Weekly Reports",
              subtitle: "Receive weekly spending summaries",
              value: weeklyReports,
              onChanged: (v) => setState(() => weeklyReports = v),
              isLight: isLight,
            ),

            _divider(context),

            _notificationTile(
              context,
              icon: Icons.local_offer_outlined,
              title: "Promotions & Offers",
              subtitle: "Get notified about special offers",
              value: promotions,
              onChanged: (v) => setState(() => promotions = v),
              isLight: isLight,
            ),
            
_divider(context),

_notificationTile(
  context,
  icon: Icons.volume_up_outlined,
  title: "Transaction Sounds",
  subtitle: "Play audio feedback after each transaction",
  value: SoundService.instance.soundEnabled,
  onChanged: (val) async {
    await SoundService.instance.setSoundEnabled(val);
    setState(() {});
  },
  isLight: isLight,
),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _divider(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(left: 52),
      child: Divider(
        height: 1,
        thickness: 0.5,
        color: color.outline.withOpacity(0.2),
      ),
    );
  }

  Widget _notificationTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required bool isLight,
  }) {
    final theme = Theme.of(context);
    final color = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 22, color: color.onSurface.withOpacity(0.6)),
          const SizedBox(width: 14),
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
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: color.onSurface.withOpacity(0.45),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Transform.scale(
            scale: 0.85,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeThumbColor: isLight ? Colors.white : Colors.black,
              activeTrackColor: isLight ? Colors.black : Colors.white,
              inactiveThumbColor: isLight ? Colors.black : Colors.black,
              inactiveTrackColor: isLight ? Colors.white : Colors.white24,
            ),
          ),
        ],
      ),
    );
  }
}