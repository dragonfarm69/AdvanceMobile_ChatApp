import 'package:flutter/material.dart';

Widget buildBotCard({
  required IconData icon,
  required String name,
  required String description,
}) {
  return Container(
    width: 160,
    margin: const EdgeInsets.only(right: 16),
    padding: const EdgeInsets.all(12), // Reduced padding for better space usage
    decoration: BoxDecoration(
      color: Color(0xFF212121),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Color(0xFF424242), width: 1),
    ),
    child: LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, // Use minimum space needed
          children: [
            Icon(icon, size: 28, color: Colors.white), // Slightly smaller icon
            const SizedBox(height: 8), // Reduced spacing
            Text(
              name,
              style: const TextStyle(
                fontSize: 15, // Slightly smaller font
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              maxLines: 1, // Limit to one line
              overflow: TextOverflow.ellipsis, // Handle potential overflow
            ),
            const SizedBox(height: 4),
            Flexible(
              child: Text(
                description,
                style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        );
      }
    ),
  );
}