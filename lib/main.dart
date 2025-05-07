import 'package:flutter/material.dart';
import 'package:ai_chat_app/features/services/authentication.dart';
import './screens/Chat Screen/ChatScreen.dart';
import './screens/Home Screen/Home.dart';
import './screens/Setting Screen/Setting.dart';
import './screens/Bots Screen/bot.dart';
import './screens/Profile Screen/profile.dart';
import './screens/LoginScreen.dart';
import './screens/RegisterScreen.dart';

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
        '/': (context) => isLoggedIn ? const HomeScreen() : const LoginScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/chat': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

          // Check if conversationId is provided, otherwise generate a new one
          final conversationId = args!= null && args['conversationId'] != null ? args['conversationId'] : UniqueKey().toString(); // Generate a new conversation ID if not provided;

          final message = args != null && args['message'] != null ? args['message'] as String : ''; // Extract the message if provided
          // Extract the initial message if provided
          final content = args != null && args['content'] != null
              ? args['content'] as String
              : '';
            return ChatScreen(conversationId: conversationId, message: message, content: content);
          }
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
