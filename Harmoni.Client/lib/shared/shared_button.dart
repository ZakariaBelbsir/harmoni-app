import 'package:flutter/material.dart';
import 'package:harmoni/theme.dart';

class SharedButton extends StatelessWidget {
  const SharedButton({
    super.key,
    required this.onPressed,
    required this.child,
    required this.backgroundColor,
  });

  final Function()? onPressed;
  final Widget child;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith<Color>(
              (Set<WidgetState> states) {
            if (states.contains(WidgetState.disabled)) {
              return backgroundColor.withOpacity(0.6);
            }
            return backgroundColor;
          },
        ),
        foregroundColor: WidgetStateProperty.all(AppColors.offWhite),
        padding: WidgetStateProperty.all(
          const EdgeInsets.symmetric(horizontal: 60, vertical: 12),
        ),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      onPressed: onPressed,
      child: child,
    );
  }
}