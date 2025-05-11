import 'package:flutter/material.dart';

// This is a button that can change background color when being held down

class PressableDrawerItem extends StatefulWidget {
  final IconData icon;
  final String title;
  final Color iconColor;
  final Color textColor;
  final VoidCallback? onTap;

  const PressableDrawerItem({
    super.key,
    required this.icon,
    required this.title,
    this.iconColor = Colors.white,
    this.textColor = Colors.white,
    this.onTap,
  });

  @override
  _PressableDrawerItemState createState() => _PressableDrawerItemState();
}

class _PressableDrawerItemState extends State<PressableDrawerItem> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _isPressed ? Colors.blue.withOpacity(0.2) : Colors.transparent,
      child: InkWell(
        onHighlightChanged: (isPressed) {
          setState(() {
            _isPressed = isPressed;
          });
        },
        onTap: widget.onTap,
        // Disable default splash and highlight colors so that our background color persists
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: ListTile(
          leading: Icon(widget.icon, color: widget.iconColor),
          title: Text(widget.title, style: TextStyle(color: widget.textColor)),
        ),
      ),
    );
  }
}
