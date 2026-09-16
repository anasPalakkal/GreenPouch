import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

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
          icon: Icon(
            Icons.arrow_back_ios_new,
            size: 18,
            color: color.onSurface,
          ),
        ),
        title: Text(
          "Privacy Policy",
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: color.onSurface,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(
            height: 1,
            thickness: 0.6,
            color: color.outline.withOpacity(0.15),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ─── Header Card ───────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: color.primary.withOpacity(0.07),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: color.primary.withOpacity(0.18),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.primary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.verified_user_rounded,
                      color: color.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "GreenPouch Privacy Policy",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: color.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "Last updated: February 26, 2026",
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: color.onSurface.withOpacity(0.45),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            _section(context, "1. Information We Collect", [
              _subsection(context, "Personal Information", [
                "Name",
                "Email address",
                "Login credentials (encrypted)",
              ]),
              _subsection(context, "Financial Information", [
                "Income and expense entries",
                "Transaction notes and categories",
                "We do NOT collect bank passwords or PINs.",
              ]),
              _subsection(context, "Technical Information", [
                "Device information",
                "Usage logs",
                "Crash reports",
              ]),
            ]),

            _section(context, "2. How We Use Your Information", [
              _bulletList(context, [
                "Manage your account",
                "Store financial transactions",
                "Improve app performance",
                "Provide support",
                "Secure authentication",
              ]),
            ]),

            _section(context, "3. Data Security", [
              _prose(context,
                  "We use encrypted passwords, HTTPS communication, and secure backend systems. No system is 100% secure."),
            ]),

            _section(context, "4. Data Sharing", [
              _prose(context,
                  "We do NOT sell your data. We share only when legally required or for infrastructure services."),
            ]),

            _section(context, "5. Your Rights", [
              _bulletList(context, [
                "Update your account",
                "Request deletion",
                "Stop using the app anytime",
              ]),
            ]),

            _section(context, "6. Authentication", [
              _prose(context, "Secure email-based authentication is used."),
            ]),

            _section(context, "7. Children's Privacy", [
              _prose(context, "Not intended for users under 13."),
            ]),

            _section(context, "8. Policy Updates", [
              _prose(context, "This policy may be updated anytime."),
            ]),

            _section(context, "9. Contact", [
              _prose(context, "Developer: Syamjith\nEmail: support@greenpouch.app"),
            ]),

            _section(context, "10. Consent", [
              _prose(context,
                  "By using GreenPouch, you agree to this policy."),
            ]),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _section(
      BuildContext context, String title, List<Widget> children) {
    final theme = Theme.of(context);
    final color = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 3.5,
                height: 16,
                decoration: BoxDecoration(
                  color: color.primary,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: color.onSurface,
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
          const SizedBox(height: 8),
          Divider(
            height: 1,
            thickness: 0.5,
            color: color.outline.withOpacity(0.15),
          ),
        ],
      ),
    );
  }

  Widget _subsection(
      BuildContext context, String label, List<String> points) {
    final theme = Theme.of(context);
    final color = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: color.onSurface.withOpacity(0.75),
            ),
          ),
          const SizedBox(height: 6),
          ...points.map((p) => _bulletRow(context, p)),
        ],
      ),
    );
  }

  Widget _bulletList(BuildContext context, List<String> points) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: points.map((p) => _bulletRow(context, p)).toList(),
    );
  }

  Widget _bulletRow(BuildContext context, String text) {
    final theme = Theme.of(context);
    final color = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 7, right: 9),
            child: Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: color.primary,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(
                height: 1.65,
                color: color.onSurface.withOpacity(0.72),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _prose(BuildContext context, String text) {
    final theme = Theme.of(context);
    final color = theme.colorScheme;

    return Text(
      text,
      style: theme.textTheme.bodyMedium?.copyWith(
        height: 1.7,
        color: color.onSurface.withOpacity(0.72),
      ),
    );
  }
}