import 'package:flutter/material.dart';

Widget buildDrawerItem({
  required IconData icon,
  required String title,
  Color iconColor = Colors.white,
  Color textColor = Colors.white,
}) {
  return Material(
    color: Colors.transparent, // So we can see the highlight
    child: InkWell(
      // Colors for tap/hold effects:
      highlightColor: Colors.blue.withOpacity(0.2), // Shown on press/hold
      splashColor: Colors.blue.withOpacity(0.1), // Ripple color
      onTap: () {
        // Handle navigation
      },
      onLongPress: () {
        // Optionally handle long-press
      },
      child: ListTile(
        leading: Icon(icon, color: iconColor),
        title: Text(title, style: TextStyle(color: textColor)),
      ),
    ),
  );
}
