import 'package:flutter/material.dart';

class SharedTextField extends StatefulWidget {
  const SharedTextField({
    super.key,
    required this.obscure,
    required this.label,
    required this.keyboardType,
    this.maxLines = 1,
    this.controller,
  });

  final bool obscure;
  final String label;
  final TextInputType keyboardType;
  final dynamic maxLines;
  final TextEditingController? controller;

  @override
  State<SharedTextField> createState() => _SharedTextFieldState();
}

class _SharedTextFieldState extends State<SharedTextField> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: widget.obscure,
      keyboardType: widget.keyboardType,
      maxLines: widget.maxLines,
      decoration: InputDecoration(
        labelText: widget.label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}