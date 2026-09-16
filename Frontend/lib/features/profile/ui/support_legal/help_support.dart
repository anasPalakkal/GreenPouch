import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  int? expandedIndex;
  late bool _showAll;
  final GlobalKey faqKey = GlobalKey();
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, String>> _faqList = [
    {
      "q": "How do I reset my password?",
      "a": "Go to Settings > Change Password."
    },
    {
      "q": "How do I edit my profile?",
      "a": "Navigate to profile page and tap Edit."
    },
    {
      "q": "Is my data secure?",
      "a": "Yes, we use industry-standard encryption."
    },
    {
      "q": "How to add Income?",
      "a": "Go to Home > Income > Fill the fields > Save Income."
    },
    {
      "q": "How to add Expense?",
      "a": "Go to Home > Expense > Fill the fields > Save Expense."
    },
    {
      "q": "How to create a Goal?",
      "a":
          "Go to Goals page > Click the New Goal > Fill the fields > Click Save Goal."
    },
    {
      "q": "How do I create a new account?",
      "a": "Go to Assets page > Click the Add button > New Account."
    },
    {
      "q": "How do I deposit to a goal?",
      "a": "Go to the Goals page > Tap the goal you needed to deposit > Click the deposit button > Enter the amount > Confirm deposit."
    },
    {
      "q": "How do I withdraw from a goal?",
      "a": "Go to the Goals page > Tap the goal you needed to withdraw > Click the withdraw button > Enter the amount > Confirm withdraw."
    },
    {
      "q": "How can I see all the transaction history?",
      "a": "Go to Home page > In Recent Activity click See All."
    },
    {
      "q": "How can I see my analytics?",
      "a": "Go to Analytics page."
    },
  ];
  List<Map<String, String>> _filteredFaqs = [];

  @override
  void initState() {
    super.initState();
    _showAll = false;
    _filteredFaqs = _faqList;
  }

  Future<void> _launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'support@greenpouch.com',
      queryParameters: {'subject': 'Green Pouch Support Request'},
    );
    try {
      await launchUrl(emailUri);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Unable to open email app")),
      );
    }
  }

  void _searchFaq(String query) {
    final results = _faqList.where((faq) {
      final q = faq["q"]!.toLowerCase();
      final a = faq["a"]!.toLowerCase();
      return q.contains(query.toLowerCase()) || a.contains(query.toLowerCase());
    }).toList();

    setState(() {
      _filteredFaqs = results;
      expandedIndex = null;
      _showAll = false;
    });
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
          icon: Icon(
            Icons.arrow_back_ios_new,
            size: 18,
            color: color.onSurface,
          ),
        ),
        title: Text(
          "Help & Support",
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
            // ─── Contact Support ────────────────────────────────────
            _sectionLabel(context, "Contact"),
            const SizedBox(height: 10),
            _supportTile(
              context: context,
              icon: Icons.email_outlined,
              title: "Contact Support",
              subtitle: "Reach out to our support team",
              onTap: _launchEmail,
            ),

            const SizedBox(height: 28),

            // ─── FAQs ───────────────────────────────────────────────
            _sectionLabel(context, "FAQs"),
            const SizedBox(height: 12),

            TextField(
              controller: _searchController,
              onChanged: _searchFaq,
              style: theme.textTheme.bodyMedium,
              decoration: InputDecoration(
                hintText: "Search FAQs...",
                hintStyle: theme.textTheme.bodyMedium?.copyWith(
                  color: color.onSurface.withOpacity(0.4),
                ),
                prefixIcon: Icon(Icons.search,
                    size: 20, color: color.onSurface.withOpacity(0.45)),
                filled: true,
                fillColor: color.surfaceContainerHighest.withOpacity(0.5),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                      color: color.outline.withOpacity(0.25), width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: color.primary, width: 1.5),
                ),
              ),
            ),

            if (_filteredFaqs.length > 4) ...[
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _showAll = !_showAll;
                  });
                },
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    _showAll ? "Show Less" : "See All",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: color.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 16),

            if (_filteredFaqs.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.search_off_rounded,
                          size: 40, color: color.onSurface.withOpacity(0.25)),
                      const SizedBox(height: 10),
                      Text(
                        "No results found",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: color.onSurface.withOpacity(0.45),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...() {
                final visibleFaqs =
                    _showAll ? _filteredFaqs : _filteredFaqs.take(4).toList();
                return [
                  ...List.generate(
                    visibleFaqs.length,
                    (index) {
                      final faq = visibleFaqs[index];
                      final isLast = index == visibleFaqs.length - 1;
                      return Column(
                        children: [
                          _faqItem(context, index, faq["q"]!, faq["a"]!),
                          if (!isLast)
                            Divider(
                              height: 1,
                              thickness: 0.5,
                              indent: 16,
                              endIndent: 16,
                              color: color.outline.withOpacity(0.2),
                            ),
                        ],
                      );
                    },
                  ),
                ];
              }(),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(BuildContext context, String label) {
    final theme = Theme.of(context);
    final color = theme.colorScheme;
    return Text(
      label.toUpperCase(),
      style: theme.textTheme.labelSmall?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: 1.1,
        color: color.onSurface.withOpacity(0.45),
      ),
    );
  }

  Widget _supportTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final color = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(0),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
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
              Icon(Icons.chevron_right_rounded,
                  size: 20, color: color.onSurface.withOpacity(0.25)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _faqItem(
    BuildContext context,
    int index,
    String question,
    String answer,
  ) {
    final theme = Theme.of(context);
    final color = theme.colorScheme;
    final bool isExpanded = expandedIndex == index;

    return Theme(
      data: theme.copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        key: PageStorageKey(index),
        initiallyExpanded: isExpanded,
        tilePadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        childrenPadding: const EdgeInsets.only(left: 4, right: 4, bottom: 12),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        onExpansionChanged: (value) {
          setState(() {
            expandedIndex = value ? index : null;
          });
        },
        trailing: AnimatedRotation(
          turns: isExpanded ? 0.5 : 0,
          duration: const Duration(milliseconds: 200),
          child: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: color.onSurface.withOpacity(0.5),
          ),
        ),
        title: Text(
          question,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: color.onSurface,
          ),
        ),
        children: [
          Text(
            answer,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: color.onSurface.withOpacity(0.6),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}