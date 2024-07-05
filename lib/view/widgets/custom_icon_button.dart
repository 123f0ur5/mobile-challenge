import 'package:flutter/material.dart';

class CustomIconButton extends StatelessWidget {
  final Widget text;
  final Icon icon;
  final Color backgroundColor;
  final Color borderColor;
  final VoidCallback onPressed;

  const CustomIconButton({
    super.key,
    required this.text,
    required this.icon,
    required this.onPressed,
    this.backgroundColor = Colors.white,
    this.borderColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () => onPressed(),
      style: OutlinedButton.styleFrom(
        backgroundColor: backgroundColor,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(3),
          ),
        ),
        side: BorderSide(color: borderColor),
      ),
      child: Row(
        children: [
          icon,
          const SizedBox(
            width: 10,
          ),
          text,
        ],
      ),
    );
  }
}
