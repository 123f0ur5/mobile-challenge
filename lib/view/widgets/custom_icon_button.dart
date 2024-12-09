import 'package:flutter/material.dart';

class CustomIconButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final bool isActive;
  final VoidCallback onPressed;

  const CustomIconButton({
    super.key,
    required this.text,
    required this.icon,
    required this.isActive,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () => onPressed(),
      style: OutlinedButton.styleFrom(
        backgroundColor: isActive ? const Color(0xFF2188FF) : Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(3),
          ),
        ),
        side: BorderSide(
          color: isActive ? const Color(0xFF2188FF) : const Color(0xFF77818C),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: isActive ? Colors.white : const Color(0xFF77818C),
          ),
          const SizedBox(
            width: 10,
          ),
          Text(
            text,
            style: TextStyle(
              color: isActive ? Colors.white : const Color(0xFF77818C),
            ),
          ),
        ],
      ),
    );
  }
}
