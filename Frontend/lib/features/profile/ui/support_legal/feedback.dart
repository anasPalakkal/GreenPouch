import 'package:flutter/material.dart';
import 'package:front_end/features/profile/services/feedback_service.dart';
import 'package:front_end/core/services/auth_storage.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _feedbackController = TextEditingController();
  final TextEditingController _transactionController = TextEditingController();

  int _rating = 0;
  bool _isSubmitting = false;

  String? _selectedCategory;

  late List<AnimationController> _starControllers;
  late List<Animation<double>> _starScales;

  final List<String> _categories = [
    "Bug Report",
    "Feature Request",
    "UI/UX Issue",
    "Transaction Issue",
    "Security Concern",
    "Other",
  ];

  final List<IconData> _categoryIcons = [
    Icons.bug_report_outlined,
    Icons.lightbulb_outline,
    Icons.palette_outlined,
    Icons.receipt_long_outlined,
    Icons.shield_outlined,
    Icons.more_horiz_outlined,
  ];

  @override
  void initState() {
    super.initState();
    _starControllers = List.generate(
      5,
      (_) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 200),
      ),
    );
    _starScales = _starControllers
        .map((c) => Tween<double>(begin: 1.0, end: 1.35).animate(
              CurvedAnimation(parent: c, curve: Curves.elasticOut),
            ))
        .toList();
  }

  Future<void> _submitFeedback() async {
    if (!_formKey.currentState!.validate()) return;

    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a rating ⭐")),
      );
      return;
    }

    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a category")),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final token = await AuthStorage.getToken();

      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Session expired. Please login again.")),
        );
        return;
      }

      await FeedbackService.updateRating(_rating, token);

      await FeedbackService.submitFeedback(
        token: token,
        category: _selectedCategory!,
        description: _feedbackController.text.trim(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Feedback Submitted Successfully ✅")),
      );

      _feedbackController.clear();
      _transactionController.clear();

      setState(() {
        _rating = 0;
        _selectedCategory = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  Widget _buildStar(int index) {
    final theme = Theme.of(context);
    final isSelected = index <= _rating;
    final animIndex = index - 1;

    return ScaleTransition(
      scale: _starScales[animIndex],
      child: GestureDetector(
        onTap: () async {
          _starControllers[animIndex].forward().then(
                (_) => _starControllers[animIndex].reverse(),
              );
          setState(() {
            _rating = index;
          });
          try {
            final token = await AuthStorage.getToken();
            if (token != null) {
              await FeedbackService.updateRating(index, token);
            }
          } catch (e) {
            debugPrint("Rating error: $e");
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Icon(
            isSelected ? Icons.star_rounded : Icons.star_outline_rounded,
            size: 40,
            color: isSelected
                ? const Color(0xFFFFC107)
                : theme.colorScheme.onSurface.withOpacity(0.2),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    _transactionController.dispose();
    for (final c in _starControllers) {
      c.dispose();
    }
    super.dispose();
  }

  String _ratingLabel() {
    switch (_rating) {
      case 1:
        return "Poor";
      case 2:
        return "Fair";
      case 3:
        return "Good";
      case 4:
        return "Great";
      case 5:
        return "Excellent!";
      default:
        return "Tap a star to rate";
    }
  }

  Widget _sectionLabel(String label) {
    final theme = Theme.of(context);
    final color = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 13,
            decoration: BoxDecoration(
              color: color.primary,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 7),
          Text(
            label.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
              color: color.onSurface.withOpacity(0.45),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme;

    // ─── GreenPouch brand green ───────────────────────────────────
    const gpGreen = Color(0xFF2E7D32);

    return Scaffold(
      backgroundColor: color.surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: color.surface,
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
          "Feedback & Rate Us",
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: color.onSurface,
          ),
        ),
        centerTitle: false,
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
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ─── Hero Banner ─────────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      gpGreen,
                      Color(0xFF43A047),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: gpGreen.withOpacity(0.28),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Share Your Experience",
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Your feedback helps us improve GreenPouch",
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white.withOpacity(0.85),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.rate_review_outlined,
                        size: 44, color: Colors.white.withOpacity(0.8)),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ─── Rating Card ─────────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                decoration: BoxDecoration(
                  color: gpGreen.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: gpGreen.withOpacity(0.15),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    _sectionLabel("Rate Your Experience"),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (i) => _buildStar(i + 1)),
                    ),
                    const SizedBox(height: 8),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: Text(
                        _ratingLabel(),
                        key: ValueKey(_rating),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: _rating > 0
                              ? const Color(0xFFFFC107)
                              : color.onSurface.withOpacity(0.45),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              Divider(height: 1, thickness: 0.5, color: color.outline.withOpacity(0.15)),
              const SizedBox(height: 24),

              // ─── Category ────────────────────────────────────────────
              _sectionLabel("Category"),
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                hint: Text(
                  "Select a category",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: color.onSurface.withOpacity(0.45),
                  ),
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: gpGreen.withOpacity(0.04),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: gpGreen.withOpacity(0.25), width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: gpGreen, width: 1.5),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: color.error, width: 1.5),
                  ),
                ),
                dropdownColor: color.surface,
                borderRadius: BorderRadius.circular(12),
                items: _categories.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final val = entry.value;
                  return DropdownMenuItem(
                    value: val,
                    child: Row(
                      children: [
                        Icon(_categoryIcons[idx], size: 18, color: gpGreen),
                        const SizedBox(width: 12),
                        Text(val),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedCategory = val),
                validator: (v) => v == null ? "Please select a category" : null,
              ),

              const SizedBox(height: 24),
              Divider(height: 1, thickness: 0.5, color: color.outline.withOpacity(0.15)),
              const SizedBox(height: 24),

              // ─── Feedback ────────────────────────────────────────────
              _sectionLabel("Your Feedback"),
              TextFormField(
                controller: _feedbackController,
                maxLines: 5,
                style: theme.textTheme.bodyMedium,
                decoration: InputDecoration(
                  hintText: "Describe your experience in detail...",
                  hintStyle: theme.textTheme.bodyMedium?.copyWith(
                    color: color.onSurface.withOpacity(0.4),
                  ),
                  filled: true,
                  fillColor: gpGreen.withOpacity(0.04),
                  contentPadding: const EdgeInsets.all(16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: gpGreen.withOpacity(0.25), width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: gpGreen, width: 1.5),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: color.error, width: 1.5),
                  ),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? "Please enter your feedback" : null,
              ),

              const SizedBox(height: 32),

              // ─── Submit Button ────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitFeedback,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: gpGreen,
                    foregroundColor: Colors.white,
                    elevation: 2,
                    shadowColor: gpGreen.withOpacity(0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.send_rounded, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              "Submit Feedback",
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
            ],
          ),
        ),
      ),
    );
  }
}