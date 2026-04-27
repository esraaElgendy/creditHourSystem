import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final TextEditingController? controller;
  final bool isPassword;
  final TextInputType keyboardType;

  const CustomTextField({
    super.key,
    required this.label,
    this.controller,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
  }) ;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: theme.inputDecorationTheme.fillColor,
        floatingLabelStyle: theme.inputDecorationTheme.labelStyle,
        border: theme.inputDecorationTheme.border,
        enabledBorder: theme.inputDecorationTheme.border,
        focusedBorder: theme.inputDecorationTheme.border,
      ),
    );
  }
}
