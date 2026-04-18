import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    required this.controller,
    required this.label,
    required this.onChanged,
    this.hintText,
    this.maxLines = 1,
    super.key,
  });

  final TextEditingController controller;
  final String label;
  final String? hintText;
  final ValueChanged<String> onChanged;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
      ),
    );
  }
}
