import 'package:flutter/material.dart';

Widget buildStationField({
  required TextEditingController controller,
  required FocusNode focusNode,
  required String labelText,
  required String hintText,
  required IconData icon,
  required Color iconColor,
  required Function(String) onChanged,
  required VoidCallback onEditingComplete,
  String? Function(String?)? validator,
  Key? key,
}) {
  return Flexible(
    child: TextFormField(
      key: key,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      controller: controller,
      focusNode: focusNode,
      style: const TextStyle(fontSize: 11),
      decoration: InputDecoration(isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
        labelText: labelText,
        hintText: hintText,
        hintStyle: const TextStyle(fontSize: 11),
        labelStyle: const TextStyle(fontSize: 11),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(width: 0.5),
        ),
        prefixIcon: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Icon(
            icon,
            color: iconColor,
            size: 16,
          ),
        ),
        prefixIconConstraints: const BoxConstraints(
          minWidth: 32, // Ensures icon space
          minHeight: 32,
        ),
      ),
      onChanged: onChanged,
      onEditingComplete: onEditingComplete,
      validator: validator,
    ),
  );
}
