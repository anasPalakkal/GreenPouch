import 'package:flutter/material.dart';

class ExportDataScreen extends StatefulWidget {
  const ExportDataScreen({super.key});

  @override
  State<ExportDataScreen> createState() => _ExportDataScreenState();
}

class _ExportDataScreenState extends State<ExportDataScreen> {
  DateTimeRange? selectedRange;
  String selectedFormat = "CSV";
  bool isLoading = false;

  Future<void> _pickDateRange() async {
    final now = DateTime.now();

    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: now,
    );

    if (range != null) {
      setState(() {
        selectedRange = range;
      });
    }
  }

  Future<void> _exportData() async {
    final theme = Theme.of(context);

    if (selectedRange == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Please select a date range"),
          backgroundColor: theme.colorScheme.primary,
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    setState(() => isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Data exported successfully as $selectedFormat"),
        backgroundColor: theme.colorScheme.primary,
      ),
    );
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
          "Export Data",
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

            // ─── Date Range ───────────────────────────────────────
            _sectionLabel(context, "Date Range"),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: _pickDateRange,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 15),
                decoration: BoxDecoration(
                  color: color.surfaceContainerHighest.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: selectedRange != null
                        ? color.primary
                        : color.outline.withOpacity(0.3),
                    width: selectedRange != null ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_month_outlined,
                      size: 20,
                      color: selectedRange != null
                          ? color.primary
                          : color.onSurface.withOpacity(0.45),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        selectedRange == null
                            ? "Choose date range"
                            : "${selectedRange!.start.toString().split(' ')[0]}  →  ${selectedRange!.end.toString().split(' ')[0]}",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: selectedRange != null
                              ? color.onSurface
                              : color.onSurface.withOpacity(0.4),
                        ),
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 20,
                      color: color.onSurface.withOpacity(0.25),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),
            Divider(
                height: 1,
                thickness: 0.5,
                color: color.outline.withOpacity(0.2)),
            const SizedBox(height: 24),

            // ─── Export Format ────────────────────────────────────
            _sectionLabel(context, "Export Format"),
            const SizedBox(height: 10),
            ...["CSV", "PDF"].map((format) {
              final isSelected = selectedFormat == format;
              return GestureDetector(
                onTap: () => setState(() => selectedFormat = format),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? color.primary.withOpacity(0.07)
                        : color.surfaceContainerHighest.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? color.primary
                          : color.outline.withOpacity(0.3),
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        format == "CSV"
                            ? Icons.table_chart_outlined
                            : Icons.picture_as_pdf_outlined,
                        size: 20,
                        color: isSelected
                            ? color.primary
                            : color.onSurface.withOpacity(0.55),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          format,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                            color: isSelected
                                ? color.primary
                                : color.onSurface,
                          ),
                        ),
                      ),
                      if (isSelected)
                        Icon(Icons.check_circle_rounded,
                            size: 18, color: color.primary),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 32),

            // ─── Export Button ────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: isLoading ? null : _exportData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: color.primary,
                  foregroundColor: color.onPrimary,
                  elevation: 2,
                  shadowColor: color.primary.withOpacity(0.4),
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
                          color: color.onPrimary,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.download_rounded, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            "Export Data",
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: color.onPrimary,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 32),
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
}