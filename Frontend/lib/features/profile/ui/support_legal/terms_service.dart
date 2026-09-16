import 'package:flutter/material.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

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
          "Terms of Service",
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
                      Icons.gavel_rounded,
                      color: color.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "GreenPouch Terms of Service",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: color.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "Effective Date: February 26, 2026",
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: color.onSurface.withOpacity(0.45),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ─── Intro ─────────────────────────────────────────────
            Text(
              "Welcome to GreenPouch, a financial tracking and money management app. By using the app, you agree to these Terms.",
              style: theme.textTheme.bodyMedium?.copyWith(
                height: 1.65,
                color: color.onSurface.withOpacity(0.7),
              ),
            ),

            const SizedBox(height: 24),

            _section(context, "1. Eligibility", [
              _prose(context, "You must be at least 18 years old to use GreenPouch."),
            ]),

            _section(context, "2. Description of Service", [
              _bulletList(context, [
                "Expense and income tracking",
                "Budget management tools",
                "Financial insights and reports",
                "Data visualization and analytics",
              ]),
              const SizedBox(height: 6),
              _prose(context,
                  "GreenPouch does not provide banking, investment, tax, or financial advisory services."),
            ]),

            _section(context, "3. User Accounts", [
              _prose(context, "You agree to:"),
              const SizedBox(height: 6),
              _bulletList(context, [
                "Provide accurate information",
                "Keep credentials secure",
                "Notify us of unauthorized access",
              ]),
            ]),

            _section(context, "4. Financial Disclaimer", [
              _prose(context,
                  "GreenPouch is a tracking tool only. Use at your own risk."),
            ]),

            _section(context, "5. Data & Privacy", [
              _prose(context,
                  "See our Privacy Policy for full details on how we handle your data."),
            ]),

            _section(context, "6. User Responsibilities", [
              _prose(context,
                  "Do not hack, misuse, or upload harmful code to the app or its infrastructure."),
            ]),

            _section(context, "7. Subscription & Payments", [
              _prose(context,
                  "Premium subscriptions may auto-renew unless cancelled before the renewal date."),
            ]),

            _section(context, "8. Intellectual Property", [
              _prose(context,
                  "All rights, content, and trademarks belong to GreenPouch."),
            ]),

            _section(context, "9. Termination", [
              _prose(context,
                  "We may suspend or terminate access if these Terms are violated."),
            ]),

            _section(context, "10. Limitation of Liability", [
              _prose(context,
                  "We are not liable for any financial losses incurred through use of the app."),
            ]),

            _section(context, "11. Third-Party Services", [
              _prose(context,
                  "We are not responsible for the content or practices of third-party services."),
            ]),

            _section(context, "12. Changes to Terms", [
              _prose(context,
                  "These Terms may be updated at any time. Continued use constitutes acceptance."),
            ]),

            _section(context, "13. Governing Law", [
              _prose(context,
                  "These Terms are governed by applicable local laws in your jurisdiction."),
            ]),

            _section(context, "14. Contact", [
              _prose(context, "support@greenpouch.app"),
            ]),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _section(BuildContext context, String title, List<Widget> children) {
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