import 'package:flutter/material.dart';
import 'package:front_end/features/profile/services/profile_service.dart';

class EditProfileScreen extends StatefulWidget {
  final String currentName;

  const EditProfileScreen({
    super.key,
    required this.currentName,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController nameController;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.currentName);
  }

  Future<void> saveProfile() async {
    if (nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a username")),
      );
      return;
    }

    setState(() => isLoading = true);

    final name = nameController.text.trim();
    final success = await ProfileService.updateProfile(name);

    if (!mounted) return;

    setState(() => isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile Updated Successfully")),
      );
      Navigator.pop(context, {"name": name});
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to update profile")),
      );
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
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
          "Edit Profile",
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

            // ─── Section Label ────────────────────────────────────
            Text(
              "DISPLAY NAME",
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: 1.1,
                color: color.onSurface.withOpacity(0.45),
              ),
            ),

            const SizedBox(height: 10),

            // ─── Name Field ───────────────────────────────────────
            TextField(
              controller: nameController,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: color.onSurface,
              ),
              decoration: InputDecoration(
                hintText: "Enter your name",
                hintStyle: theme.textTheme.bodyMedium?.copyWith(
                  color: color.onSurface.withOpacity(0.4),
                ),
                prefixIcon: Icon(
                  Icons.person_outline_rounded,
                  size: 20,
                  color: color.onSurface.withOpacity(0.45),
                ),
                filled: true,
                fillColor: color.surfaceContainerHighest.withOpacity(0.5),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                      color: color.outline.withOpacity(0.3), width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: color.primary, width: 1.5),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // ─── Save Button ──────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: isLoading ? null : saveProfile,
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
                          const Icon(Icons.check_rounded, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            "Save Changes",
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
          ],
        ),
      ),
    );
  }
}