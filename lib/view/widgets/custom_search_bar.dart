import 'package:flutter/material.dart';

class CustomSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onChanged;

  const CustomSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: SizedBox(
        width: size.width * 0.85,
        child: TextFormField(
          controller: controller,
          onChanged: (_) => onChanged(),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.only(left: 15, bottom: 11, top: 13, right: 15),
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(4),
            ),
            filled: true,
            fillColor: Colors.grey.withOpacity(.20),
            prefixIcon: const Icon(Icons.search),
            hintText: "Buscar Ativo ou Local",
            hintStyle: const TextStyle(
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
