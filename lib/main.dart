import 'package:flutter/material.dart';
import 'package:ai_chat_app/features/services/authentication.dart';
import './screens/Chat Screen/ChatScreen.dart';
import './screens/Home Screen/Home.dart';
import './screens/Setting Screen/Setting.dart';
import './screens/Bots Screen/bot.dart';
import './screens/Profile Screen/profile.dart';
import 'package:ai_chat_app/screens/LoginScreen.dart';
import 'package:ai_chat_app/screens/RegisterScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AuthService authService = AuthService();

  bool isLoggedIn = await authService.checkIfLoggedIn();
  runApp(MyApp(isLoggedIn: isLoggedIn,));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

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
        '/': (context) => const HomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/chat': (context) {
          // Cast the arguments to a Map
          final args =
              ModalRoute.of(context)!.settings.arguments
                  as Map<String, String>?;
          // Extract the text
          final text = args?['initialMessage'] ?? '';
          // Pass the text to ChatScreen
          return ChatScreen(initialMessage: text);
        },
        '/setting': (context) => const SettingsScreen(),
        '/bots': (context) => const BotsScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
      onGenerateRoute: (settings) {
        // Handle any routes that aren't defined above
        return MaterialPageRoute(builder: (context) => const LoginScreen());
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
