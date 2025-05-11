import 'package:flutter/material.dart';
import '../features/services/authentication.dart';
import '../features/services/token_store.dart';

Widget buildDrawerItem({
  required BuildContext context,
  required IconData icon,
  required String title,
  Color iconColor = Colors.white,
  Color textColor = Colors.white,
}) {
  void handleSignOut(BuildContext context) async {
    final auth = AuthService();
    final result = await auth.signOut();
    if (result == true) {
      // Clear tokens from storage
      await TokenStore.clearTokens();
      // Navigate to login screen
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logged out successfully')),
      );

      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to log out')),
      );
    }
  }

  return Material(
    color: const Color.fromARGB(0, 193, 63, 63), // So we can see the highlight
    child: InkWell(
      // Colors for tap/hold effects:
      highlightColor: Colors.blue.withOpacity(0.2), // Shown on press/hold
      splashColor: Colors.blue.withOpacity(0.1), // Ripple color
      onTap: () {
        if (title == 'Sign Out') {
          handleSignOut(context);
        } 
      },
      child: ListTile(
        leading: Icon(icon, color: iconColor),
        title: Text(title, style: TextStyle(color: textColor)),
      ),
    ),
  );
}
