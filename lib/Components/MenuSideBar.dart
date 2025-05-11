import 'package:flutter/material.dart';
import 'PressableDrawerItem.dart';
import 'StatefullWidgetButton.dart';

Widget menuSideBar(BuildContext context) {
  return Drawer(
    child: Container(
      color: Colors.black,
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.black),
            margin: EdgeInsets.zero, // Remove default margin
            child: Align(
              alignment: Alignment.topLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Material(
                    color: Colors.blue,
                    shape: CircleBorder(),
                    clipBehavior: Clip.hardEdge,
                    child: InkWell(
                      onTap: () {
                        Navigator.pushNamed(context, '/profile');
                      },
                      splashColor: Colors.blue.shade300,
                      highlightColor: Colors.blue.shade700,
                      child: SizedBox(
                        width: 60,
                        height: 60,
                        child: Icon(
                          Icons.person,
                          size: 30,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'test Chat App',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'user@example.com',
                    style: TextStyle(color: Colors.grey[400], fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
          // Top menu items
          PressableDrawerItem(
            icon: Icons.home,
            title: 'Home',
            onTap: () {
              // Handle navigation
              Navigator.pop(context); // Close the drawer first
              Navigator.pushNamed(context, '/home');
            },
          ),
          PressableDrawerItem(
            icon: Icons.smart_toy,
            title: 'Bots',
            onTap: () {
              // Handle navigation
              Navigator.pop(context); // Close the drawer first
              Navigator.pushNamed(context, '/bots');
            },
          ),
          PressableDrawerItem(
            icon: Icons.settings,
            title: 'Settings',
            onTap: () {
              // Handle navigation
              Navigator.pop(context); // Close the drawer first
              Navigator.pushNamed(context, '/setting');
            },
          ),
          // Spacer to push sign out to the bottom
          Spacer(),
          buildDrawerItem(
            context: context,
            icon: Icons.logout,
            title: 'Sign Out',
            iconColor: Colors.red,
            textColor: Colors.red,
          ),
        ],
      ),
    ),
  );
}
