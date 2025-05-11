import 'package:flutter/material.dart';

class PressableMenuItemWithArrow extends StatefulWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const PressableMenuItemWithArrow({
    super.key,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  _PressableMenuItemWithArrowState createState() =>
      _PressableMenuItemWithArrowState();
}

class _PressableMenuItemWithArrowState extends State<PressableMenuItemWithArrow> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _isPressed ? Colors.grey[700] : Colors.transparent,
      child: InkWell(
        onHighlightChanged: (isPressed) {
          setState(() {
            _isPressed = isPressed;
          });
        },
        onTap: widget.onTap,
        splashColor: Colors.grey.withOpacity(0.3),
        highlightColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: Colors.grey[800]!, width: 1),
            ),
          ),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: TextStyle(
                        color: Colors.grey[300],
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.subtitle,
                      style:
                          TextStyle(color: Colors.grey[500], fontSize: 14),
                    ),
                  ],
                ),
                Icon(Icons.chevron_right, color: Colors.grey[400]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}