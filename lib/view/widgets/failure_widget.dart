import 'package:flutter/material.dart';

class FailureWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onTap;

  const FailureWidget({
    super.key,
    required this.message,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Center(
          child: Icon(
            size: 105,
            Icons.close,
            color: Colors.red,
          ),
        ),
        const SizedBox(
          height: 16,
        ),
        Text(message),
        const SizedBox(
          height: 16,
        ),
        OutlinedButton(
          onPressed: () => onTap!(),
          child: const SizedBox(
            width: 100,
            child: Text(
              "Retry",
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}
