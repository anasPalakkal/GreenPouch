import 'package:flutter/material.dart';

class PremiumUpgradeScreen extends StatelessWidget {
  const PremiumUpgradeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme;

    return Scaffold(
      backgroundColor: color.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ─── AppBar ───────────────────────────────────────────
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFF59E0B),
                    Color(0xFFF97316),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new,
                        color: Colors.white, size: 18),
                  ),
                  const Text(
                    "Upgrade to Premium",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // ─── Content ──────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [

                    // ─── Icon ──────────────────────────────────
                    Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFF59E0B), Color(0xFFF97316)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFF97316).withOpacity(0.35),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.workspace_premium_rounded,
                        size: 48,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ─── Title ─────────────────────────────────
                    Text(
                      "Premium Plans",
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: color.onSurface,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF59E0B).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        "Coming Soon 🚀",
                        style: TextStyle(
                          color: Color(0xFFF97316),
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    Divider(
                        height: 1,
                        thickness: 0.5,
                        color: color.outline.withOpacity(0.2)),

                    const SizedBox(height: 24),

                    Text(
                      "We're working on exciting premium features to help you manage your finances even better. Stay tuned!",
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        height: 1.7,
                        color: color.onSurface.withOpacity(0.6),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // ─── Feature Previews ───────────────────────
                    ...[
                      (Icons.insights_outlined, "Advanced Analytics"),
                      (Icons.cloud_sync_outlined, "Cloud Backup"),
                      (Icons.block_outlined, "Ad-Free Experience"),
                      (Icons.support_agent_outlined, "Priority Support"),
                    ].map((item) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF59E0B)
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(item.$1,
                                    size: 18,
                                    color: const Color(0xFFF97316)),
                              ),
                              const SizedBox(width: 14),
                              Text(
                                item.$2,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                  color: color.onSurface.withOpacity(0.75),
                                ),
                              ),
                              const Spacer(),
                              Icon(Icons.lock_outline_rounded,
                                  size: 16,
                                  color:
                                      color.onSurface.withOpacity(0.25)),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}