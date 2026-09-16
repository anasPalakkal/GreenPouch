import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final bool obscureText;
  final String? Function(String?)? validator;
  final Widget? suffixIcon;

  const CustomTextField({
    super.key,
    required this.hintText,
    required this.controller,
    this.obscureText = false,
    this.validator,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,

      cursorColor: theme.textSelectionTheme.cursorColor, // ✅ no red cursor

      style: TextStyle(
        color: theme.brightness == Brightness.dark
            ? Colors.white
            : Colors.black,
      ),

      decoration: InputDecoration(
        hintText: hintText,
        suffixIcon: suffixIcon,

        // ✅ removes weird red spacing if error appears
        errorMaxLines: 2,
      ),
    );
  }
}