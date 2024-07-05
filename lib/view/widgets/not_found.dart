import 'package:flutter/material.dart';

class NotFound extends StatelessWidget {
  final String message;
  const NotFound({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Text(
          message,
          style: const TextStyle(
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}
