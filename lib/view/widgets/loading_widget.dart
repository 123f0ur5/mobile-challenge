import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {
  final String message;
  const LoadingWidget({
    super.key,
    this.message = "Carregando...",
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Center(
          child: CircularProgressIndicator(),
        ),
        const SizedBox(
          height: 16,
        ),
        Text(message),
      ],
    );
  }
}
