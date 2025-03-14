import 'package:ai_chat_app/screens/ChatScreen.dart';
import 'package:ai_chat_app/screens/LoginScreen.dart';
import 'package:ai_chat_app/screens/RegisterScreen.dart';
import 'package:flutter/material.dart';
// Import your other screens here
// import './screens/login_screen.dart';
// import './screens/settings_screen.dart';
// import './screens/profile_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Chat App',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        primaryColor: Colors.blue,
        fontFamily: 'SF Pro Text',
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const ChatScreen(),
        // Add your routes here
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        // '/settings': (context) => const SettingsScreen(),
        // '/profile': (context) => const ProfileScreen(),
        '/chat': (context) => const ChatScreen(),
      },
      onGenerateRoute: (settings) {
        // Handle any routes that aren't defined above
        return MaterialPageRoute(
          builder: (context) => const ChatScreen(),
        );
      },
      debugShowCheckedModeBanner: false,
    );
  }
}