import 'package:flutter/material.dart';

class DiarySearchBar extends StatelessWidget implements PreferredSizeWidget {
  final TextEditingController controller;
  final Function(String) onChanged;
  final VoidCallback onClose;

  const DiarySearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF131313),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Color(0xFFF1C97D)),
        onPressed: onClose,
      ),
      title: TextField(
        controller: controller,
        autofocus: true,
        style: const TextStyle(color: Color(0xFFF1C97D)),
        decoration: const InputDecoration(
          hintText: "Buscar na crônica...",
          hintStyle: TextStyle(color: Colors.white24),
          border: InputBorder.none,
        ),
        onChanged: onChanged,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
