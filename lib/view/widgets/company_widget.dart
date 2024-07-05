import 'package:flutter/material.dart';

class CompanyWidget extends StatelessWidget {
  final String name;
  final VoidCallback onTap;
  final Color? buttonColor;

  const CompanyWidget({
    super.key,
    required this.name,
    required this.onTap,
    this.buttonColor = const Color(0xFF2188FF),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 76,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(
              Radius.circular(10),
            ),
            color: buttonColor,
          ),
          child: Center(
            child: Row(
              children: [
                const SizedBox(width: 32),
                const Icon(
                  Icons.workspaces,
                  size: 24,
                  color: Colors.white,
                ),
                const SizedBox(width: 16),
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
