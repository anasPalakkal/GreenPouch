import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,

        child: isLoading
            ? CircularProgressIndicator(
                strokeWidth: 2,
                color: theme.colorScheme.onPrimary, // ✅ auto color
              )
            : Text(
                text,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onPrimary, // ✅ auto color
                ),
              ),
      ),
    );
  }
}