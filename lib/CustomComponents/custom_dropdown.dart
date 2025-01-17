import 'package:flutter/material.dart';

class CustomDropdown extends StatelessWidget {
  final String? value;
  final List<Map<String, String>> items;
  final String hint;
  final ValueChanged<String?> onChanged;

  const CustomDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.hint,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: Colors.white,
          width: 1,
        ),
      ),
      child: DropdownButton<String>(
        value: value,
        hint: Text(
          hint,
          style: TextStyle(color: Colors.white.withOpacity(0.5)),
        ),
        isExpanded: true,
        underline: const SizedBox(),
        dropdownColor: const Color(0xFF1a237e),
        icon: Icon(Icons.arrow_drop_down, color: Colors.white.withOpacity(0.5)),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontFamily: 'Poppins',
        ),
        items: items.map((item) {
          return DropdownMenuItem<String>(
            value: item['code'],
            child: Text(item['status']!),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }
}

class CustomDropdownField extends StatelessWidget {
  final String? label;
  final String? value;
  final List<Map<String, String>> items;
  final String hint;
  final ValueChanged<String?> onChanged;

  const CustomDropdownField({
    super.key,
    this.label, // label is optional
    required this.value,
    required this.items,
    required this.hint,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(10.0, 8, 8, 8),
            child: Text(
              label!,
              style: const TextStyle(
                fontSize: 20,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
        CustomDropdown(
          value: value,
          items: items,
          hint: hint,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
