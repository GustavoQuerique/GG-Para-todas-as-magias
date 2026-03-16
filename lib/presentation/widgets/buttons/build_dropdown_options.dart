import 'package:flutter/material.dart';

class SheetDropdownOption {
  final String value;
  final String label;

  SheetDropdownOption({
    required this.value,
    required this.label,
  });
}

class SheetDropdown extends StatelessWidget {
  final String label;
  final String? currentValue;
  final List<SheetDropdownOption> options;
  final Function(String?) onChanged;

  const SheetDropdown({
    super.key,
    required this.label,
    required this.currentValue,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: currentValue,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: options.map((option) {
        return DropdownMenuItem<String>(
          value: option.value,
          child: Text(option.label),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}
