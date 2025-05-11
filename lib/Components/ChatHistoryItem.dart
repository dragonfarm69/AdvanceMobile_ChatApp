import 'package:flutter/material.dart';

Widget chatHistoryItem({
  required String title,
  required String date,
  required context,
  required String conversationId,
}) {
  return Container(
    decoration: BoxDecoration(
      border: Border(
        bottom: BorderSide(color: Colors.grey.withOpacity(0.2), width: 0.5),
      ),
    ),
    child: ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      title: Align(
        alignment: Alignment.centerRight,
        child: Text(date, style: TextStyle(color: Colors.grey[400], fontSize: 14)),
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
        ],
      ),
      onTap: () {
        // Handle navigation to the specific chat
        Navigator.pushNamed(context, '/chat', arguments: {'conversationId': conversationId});
      },
    ),
  );
}
