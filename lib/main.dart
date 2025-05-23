import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ai_chat_app/features/services/authentication.dart';
import './screens/Chat Screen/ChatScreen.dart';
import './screens/Home Screen/Home.dart';
import './screens/Setting Screen/Setting.dart';
import './screens/Bots Screen/bot.dart';
import './screens/Profile Screen/profile.dart';
import './screens/LoginScreen.dart';
import './screens/RegisterScreen.dart';
import 'screens/knowledge Screen/knowledge_screen.dart';
import 'screens/Subscription Screen/subscription.dart';
import 'globals.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AuthService authService = AuthService();

  bool isLoggedIn = await authService.checkIfLoggedIn();
  unawaited(MobileAds.instance.initialize());
  runApp(MyApp(isLoggedIn: isLoggedIn,));
}

class ChatRouteWrapper extends StatelessWidget {
  const ChatRouteWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    final conversationId = args != null && args['conversationId'] != null
        ? args['conversationId']
        : UniqueKey().toString();

    return ChatScreen(conversationId: conversationId);
  }
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: scaffoldMessengerKey,
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
        '/home': (context) => const HomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/chat': (context) => const ChatRouteWrapper(),
        '/setting': (context) => const SettingsScreen(),
        '/bots': (context) => const BotsScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/sub': (context) => const SubscriptionScreen(),
        '/knowledge': (context) => const KnowledgeScreen(),
      },
      onGenerateRoute: (settings) {
        // Handle any routes that aren't defined above
        return MaterialPageRoute(builder: (context) => const LoginScreen());
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
