import 'package:flutter/material.dart';

class InlineEditableField extends StatefulWidget {
  final String value;
  final TextStyle? style;
  final TextInputType keyboardType;
  final Function(String) onChanged;

  const InlineEditableField({
    super.key,
    required this.value,
    required this.onChanged,
    this.style,
    this.keyboardType = TextInputType.text,
  });

  @override
  State<InlineEditableField> createState() => _InlineEditableFieldState();
}

class _InlineEditableFieldState extends State<InlineEditableField> {
  late TextEditingController controller;
  late FocusNode focusNode;
  bool editing = false;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.value);
    focusNode = FocusNode();
    focusNode.addListener(() {
      if (!focusNode.hasFocus && editing) {
        save();
      }
    });
  }

  void save() {
    if (!editing) return;

    if (controller.text != widget.value) {
      widget.onChanged(controller.text);
    }

    setState(() => editing = false);
  }

  @override
  void dispose() {
    controller.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant InlineEditableField oldWidget) {
    if (oldWidget.value != widget.value) {
      controller.text = widget.value;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    if (editing) {
      return SizedBox(
        width: 200,
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          autofocus: true,
          keyboardType: widget.keyboardType,
          style: widget.style,
          onSubmitted: (_) => save(),
          decoration: const InputDecoration(
            isDense: true,
            border: UnderlineInputBorder(),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () => setState(() => editing = true),
      child: Text(
        widget.value.isEmpty ? "-" : widget.value,
        style: widget.style,
      ),
    );
  }
}
