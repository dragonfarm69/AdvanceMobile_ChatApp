import 'package:flutter/material.dart';
import 'package:ai_chat_app/screens/LoginScreen.dart'; // Adjust the import based on your project structure
import '../../features/services/authentication.dart'; // Ensure this import exists

void _handleLogout(BuildContext context) async {
  final AuthService auth = AuthService();
  final result = await auth.signOut();
  if (result) {
    // Successfully logged out, navigate to login screen or show a message
    Navigator.pushReplacementNamed(context, '/login');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Logged out successfully')),
    );
  } else {
    // Handle logout failure (e.g., show an error message)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Logout failed. Please try again.')),
    );
  }
}

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
        // Handle tap action here
        if (title == 'Logout') {
          // Call the logout function
          _handleLogout(context);
        } else {
          // Handle other drawer item actions
          print('Tapped on $title');
        }
      },
      child: ListTile(
        leading: Icon(icon, color: iconColor),
        title: Text(title, style: TextStyle(color: textColor)),
      ),
    ),
  );
}
