import 'package:flutter/material.dart';

class CustomTextfield extends StatelessWidget {
  final TextEditingController? controller; // Thêm controller
  final bool obscureText;
  final String hintText;
  final IconData icon;

  const CustomTextfield({
    super.key,
    this.controller,
    required this.obscureText,
    required this.hintText,
    required this.icon,
    required String? Function(dynamic value) validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
