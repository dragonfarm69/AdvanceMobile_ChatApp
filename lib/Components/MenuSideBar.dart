import 'package:flutter/material.dart';
import 'PressableDrawerItem.dart';
import 'StatefullWidgetButton.dart';
import '../features/services/userInfo.dart';
import '../features/model/user.dart';

Widget menuSideBar(BuildContext context) {
  final Userinfo userInfo = Userinfo();

  return Drawer(
    child: Container(
      color: Colors.black,
      child: Column(
        children: [
          FutureBuilder<User>(
            future: userInfo.getUserInfo(),
            builder: (context, snapshot) {
              // Loading state
              if (snapshot.connectionState == ConnectionState.waiting) {
                return _buildHeaderLoading();
              }

              // Error state
              if (snapshot.hasError) {
                return _buildHeaderError(snapshot.error.toString(), context);
              }

              // Data loaded successfully
              final user = snapshot.data;
              return DrawerHeader(
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
                        user?.email.substring(0, user?.email.indexOf('@')) ??
                            'Chat App User',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        user?.email ?? 'No email available',
                        style: TextStyle(color: Colors.grey[400], fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
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
          PressableDrawerItem(
            icon: Icons.school,
            title: 'Knowledges',
            onTap: () {
              // Handle navigation
              Navigator.pop(context); // Close the drawer first
              Navigator.pushNamed(context, '/knowledge');
            },
          ),
          PressableDrawerItem(
            icon: Icons.paid,
            title: 'Subscription',
            onTap: () {
              // Handle navigation
              Navigator.pop(context); // Close the drawer first
              Navigator.pushNamed(context, '/sub');
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

// Loading state header
Widget _buildHeaderLoading() {
  return DrawerHeader(
    decoration: BoxDecoration(color: Colors.black),
    margin: EdgeInsets.zero,
    child: Align(
      alignment: Alignment.topLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          ShimmerLoading(width: 60, height: 60, shape: BoxShape.circle),
          SizedBox(height: 10),
          ShimmerLoading(width: 150, height: 20),
          SizedBox(height: 5),
          ShimmerLoading(width: 100, height: 14),
        ],
      ),
    ),
  );
}

// Error state header
Widget _buildHeaderError(String error, BuildContext context) {
  return DrawerHeader(
    decoration: BoxDecoration(color: Colors.black),
    margin: EdgeInsets.zero,
    child: Align(
      alignment: Alignment.topLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Material(
            color: Colors.red[300],
            shape: CircleBorder(),
            clipBehavior: Clip.hardEdge,
            child: SizedBox(
              width: 60,
              height: 60,
              child: Icon(Icons.error_outline, size: 30, color: Colors.white),
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Failed to load profile',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          InkWell(
            onTap: () {
              // Force refresh by rebuilding the drawer
              Navigator.pop(context);
              Scaffold.of(context).openDrawer();
            },
            child: Text(
              'Tap to retry',
              style: TextStyle(
                color: Colors.blue[300],
                fontSize: 14,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

// Shimmer loading effect for placeholder
class ShimmerLoading extends StatelessWidget {
  final double width;
  final double height;
  final BoxShape shape;

  const ShimmerLoading({
    Key? key,
    required this.width,
    required this.height,
    this.shape = BoxShape.rectangle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[800],
        shape: shape,
        borderRadius:
            shape == BoxShape.rectangle ? BorderRadius.circular(4) : null,
      ),
    );
  }
}
