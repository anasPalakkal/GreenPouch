import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../data/goal_model.dart';
import '../provider/goal_provider.dart';

class CreateNewGoalScreen extends StatefulWidget {
  final GoalModel? existingGoal;

  const CreateNewGoalScreen({
    super.key,
    this.existingGoal,
  });

  @override
  State<CreateNewGoalScreen> createState() => _CreateNewGoalScreenState();
}

class _CreateNewGoalScreenState extends State<CreateNewGoalScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController titleController;
  late TextEditingController targetController;

  bool _isSaving = false;

  DateTime? selectedDate;
  String selectedCategory = "Savings";

  final List<Map<String, dynamic>> categories = [
    {"name": "Savings", "icon": Icons.trending_up_rounded},
    {"name": "Emergency", "icon": Icons.error_outline_rounded},
    {"name": "Bills", "icon": Icons.receipt_long_rounded},
    {"name": "Business", "icon": Icons.work_outline_rounded},
    {"name": "Travel", "icon": Icons.flight_takeoff_rounded},
    {"name": "Other", "icon": Icons.category_rounded},
  ];

  @override
  void initState() {
    super.initState();

    titleController =
        TextEditingController(text: widget.existingGoal?.title ?? "");

    targetController = TextEditingController(
      text: (widget.existingGoal?.targetAmount ?? 0) > 0
          ? widget.existingGoal!.targetAmount.toStringAsFixed(0)
          : "",
    );

    selectedDate = widget.existingGoal?.targetDate;

    if (widget.existingGoal != null) {
      selectedCategory = widget.existingGoal!.category;
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    targetController.dispose();
    super.dispose();
  }

  void _saveGoal() async {
    if (!_formKey.currentState!.validate() || selectedDate == null) {
      _showSnackBar(
        selectedDate == null ? "Please select a target date" : "Please fill all fields",
        isError: true,
      );
      return;
    }

    setState(() => _isSaving = true);

    final goalToSave = GoalModel(
      id: widget.existingGoal?.id ?? '',
      title: titleController.text.trim(),
      category: selectedCategory,
      targetAmount: double.parse(targetController.text),
      currentAmount: widget.existingGoal?.currentAmount ?? 0.0,
      targetDate: selectedDate!,
      status: widget.existingGoal?.status ?? 'active',
      createdAt: widget.existingGoal?.createdAt ?? DateTime.now(),
    );

    try {
      final provider = context.read<GoalProvider>();
      String? errorMessage;

      if (widget.existingGoal != null) {
        errorMessage = await provider.updateGoal(goalToSave);
      } else {
        errorMessage = await provider.createGoal(goalToSave);
      }

      if (!mounted) return;

      if (errorMessage == null) {
        Navigator.pop(context, true); 
      } else {
        _showSnackBar(errorMessage, isError: true);
      }
    } catch (e) {
      if (mounted) _showSnackBar("Network error. Please try again.", isError: true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
        backgroundColor: isError ? Colors.redAccent : const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildLabel(String text) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 2),
      child: Text(
        text,
        style: TextStyle(
          color: colors.onSurfaceVariant,
          fontSize: 13,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: colors.onSurface),
          ),
          Text(
            widget.existingGoal == null ? "Create New Goal" : "Edit Goal",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: colors.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStickySaveButton() {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, -4),
          )
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: colors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
          onPressed: _isSaving ? null : _saveGoal,
          child: _isSaving
              ? SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(color: colors.onPrimary, strokeWidth: 3),
                )
              : Text(
                  widget.existingGoal == null ? "Save Goal" : "Update Goal",
                  style: TextStyle(
                    color: colors.onPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("Goal Title"),
                      TextFormField(
                        controller: titleController,
                        style: TextStyle(color: colors.onSurface, fontWeight: FontWeight.w600, fontSize: 16),
                        decoration: InputDecoration(
                          hintText: "e.g., Summer Vacation",
                          hintStyle: TextStyle(color: colors.onSurfaceVariant.withOpacity(0.5)),
                          filled: true,
                          fillColor: colors.surfaceContainerHighest.withOpacity(0.5),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        ),
                        validator: (v) => v == null || v.isEmpty ? "Please enter a title" : null,
                      ),
                      const SizedBox(height: 24),

                      _buildLabel("Target Amount"),
                      TextFormField(
                        controller: targetController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                        ],
                        style: TextStyle(color: colors.onSurface, fontWeight: FontWeight.w600, fontSize: 16),
                        decoration: InputDecoration(
                          prefixText: "₹ ",
                          prefixStyle: TextStyle(color: colors.onSurface, fontWeight: FontWeight.bold, fontSize: 16),
                          hintText: "10000",
                          hintStyle: TextStyle(color: colors.onSurfaceVariant.withOpacity(0.5)),
                          filled: true,
                          fillColor: colors.surfaceContainerHighest.withOpacity(0.5),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        ),
                        validator: (v) => v == null || v.isEmpty ? "Please enter a target amount" : null,
                      ),
                      const SizedBox(height: 24),

                      _buildLabel("Target Date"),
                      InkWell(
                        onTap: () async {
                          final d = await showDatePicker(
                            context: context,
                            initialDate: selectedDate ?? DateTime.now().add(const Duration(days: 30)),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2100),
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: colors.copyWith(
                                    primary: colors.primary,
                                    onPrimary: colors.onPrimary,
                                    surface: colors.surface,
                                    onSurface: colors.onSurface,
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );

                          if (d != null) {
                            setState(() => selectedDate = d);
                          }
                        },
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          decoration: BoxDecoration(
                            color: colors.surfaceContainerHighest.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                selectedDate == null
                                    ? "Select Deadline"
                                    : DateFormat('MMM dd, yyyy').format(selectedDate!),
                                style: TextStyle(
                                  color: selectedDate == null ? colors.onSurfaceVariant.withOpacity(0.5) : colors.onSurface,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              Icon(Icons.calendar_month_rounded, color: colors.primary, size: 22),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      _buildLabel("Category"),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: categories.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 1.1,
                        ),
                        itemBuilder: (context, index) {
                          final category = categories[index];
                          final isSelected = selectedCategory == category["name"];

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedCategory = category["name"];
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              decoration: BoxDecoration(
                                color: isSelected ? colors.primary.withOpacity(0.1) : Colors.transparent,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected ? colors.primary : theme.dividerColor.withOpacity(0.5),
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    category["icon"], 
                                    color: isSelected ? colors.primary : colors.onSurfaceVariant,
                                    size: 28,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    category["name"],
                                    style: TextStyle(
                                      color: isSelected ? colors.primary : colors.onSurfaceVariant,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 40), 
                    ],
                  ),
                ),
              ),
            ),
            _buildStickySaveButton(),
          ],
        ),
      ),
    );
  }
}