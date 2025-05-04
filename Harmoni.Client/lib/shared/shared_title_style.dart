import 'package:flutter/material.dart';

class SharedTitleStyle extends StatelessWidget {
  const SharedTitleStyle(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: Theme.of(context).textTheme.titleMedium);
  }
}