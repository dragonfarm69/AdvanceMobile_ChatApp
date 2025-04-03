import 'package:flutter/material.dart';

Widget chatHistoryItem({
  required String modelName,
  required String title,
  required String date,
  required context,
  String subtitle = '',
}) {
  return Container(
    decoration: BoxDecoration(
      border: Border(
        bottom: BorderSide(color: Colors.grey.withOpacity(0.2), width: 0.5),
      ),
    ),
    child: ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            modelName,
            style: TextStyle(color: Colors.grey[400], fontSize: 14),
          ),
          Text(date, style: TextStyle(color: Colors.grey[400], fontSize: 14)),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (subtitle.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                subtitle,
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
      onTap: () {
        // Handle navigation to the specific chat
        Navigator.pushNamed(context, '/chat', arguments: {'chatTitle': title});
      },
    ),
  );
}
