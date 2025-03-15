import 'package:flutter/material.dart';

class CustomFiled extends StatelessWidget {
  final String hintText;
  final bool isObscureText;
  final TextEditingController? controller;
  final bool readOnly;
  final VoidCallback? onTap;
  const CustomFiled({
    super.key,
    required this.hintText,
    required this.controller,
    this.isObscureText = false,
    this.readOnly = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onTap: onTap,
      readOnly: readOnly,
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
      ),
      validator: (value) {
        if (value!.trim().isEmpty) {
          return "$hintText is missing!";
        } else {
          return null;
        }
      },
      obscureText: isObscureText,
    );
  }
}
