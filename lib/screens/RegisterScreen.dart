import 'package:ai_chat_app/features/services/authentication.dart';
import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget{
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
    final TextEditingController _emailController = TextEditingController();
    final TextEditingController _passwordController = TextEditingController();
    final TextEditingController _passwordConfirmationController = TextEditingController();
    bool _isLoading = false;

    void _handleRegister() async {
      setState(() {
        _isLoading = true;
      });

      String email = _emailController.text.trim();
      String password = _passwordController.text.trim();
      String passwordConfirmation = _passwordConfirmationController.text.trim();
      if (password != passwordConfirmation) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Passwords do not match.')),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }
      
      final auth = AuthService();
      final result = await auth.signUp(
        email, 
        password
      );

      setState(() {
        _isLoading = false;
      });

      if (result != null) {
        // Handle successful registration, e.g., navigate to home screen
        Navigator.pushNamed(context, '/', arguments: (route) => false);
      } else {
        // Handle registration error, e.g., show a snackbar or alert dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration failed. Please try again.')),
        );
      }
    }

  @override
    Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Title display
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                "Register",
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                ),
              ],
              ),
            ),

            const SizedBox(height: 16),
            
            // Assistant profile card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFF212121),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  TextField(
                    style: TextStyle(color: const Color.fromARGB(255, 68, 68, 68)),
                    decoration: InputDecoration(
                      hintText: 'Email',
                      filled: true,
                      fillColor: const Color.fromARGB(255, 255, 255, 255),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    style: TextStyle(color: const Color.fromARGB(255, 68, 68, 68)),
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: 'Password',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                  TextField(
                    style: TextStyle(color: const Color.fromARGB(255, 68, 68, 68)),
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: 'Password Confirmation',
                      filled: true,
                      fillColor: const Color.fromARGB(255, 255, 255, 255),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      _isLoading ? null : _handleRegister();
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: const Color.fromARGB(255, 171, 171, 171), 
                      backgroundColor: const Color.fromARGB(255, 255, 0, 221),
                      padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white) : const Text("Register"),
                  ),
                  SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      // Navigate to the registration screen
                      Navigator.pushNamed(context, '/ogin');
                    },
                    child: Text(
                      "Already have an account? Login",
                      style: TextStyle(color: const Color.fromARGB(255, 171, 171, 171)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

