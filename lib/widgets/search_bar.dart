import 'package:flutter/material.dart';

class SearchBarWidget extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const SearchBarWidget({super.key, required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final isFocused = FocusScope.of(context).hasFocus;
    return Material(
      elevation: 3,
      borderRadius: BorderRadius.circular(18),
      color: Colors.transparent,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          hintText: 'Suche nach einem deutschen oder portugiesischen Wort...',
          prefixIcon: Focus(
            child: Icon(
              Icons.search,
              color: isFocused ? const Color(0xFFFFD700) : Colors.black54,
              size: 26,
            ),
          ),
          filled: true,
          fillColor: Colors.white.withOpacity(0.92),
          contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: Color(0xFFFFD700), width: 2),
          ),
        ),
      ),
    );
  }
} 