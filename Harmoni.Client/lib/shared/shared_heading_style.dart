import 'package:flutter/material.dart';

class SharedHeadingStyle extends StatelessWidget {
  const SharedHeadingStyle(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: Theme.of(context).textTheme.headlineMedium);
  }
}