import 'package:flutter/material.dart';

Widget buildEditableField(
  String label,
  TextEditingController controller, {
  int maxLines = 1,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(color: Colors.white, fontSize: 16),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[800],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[700]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[700]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: const Color(0xFF5C6BC0)),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Divider(color: Colors.grey[800]),
      ],
    ),
  );
}
