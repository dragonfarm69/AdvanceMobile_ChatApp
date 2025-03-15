import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Text(
                    "09:29",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Icon(Icons.signal_cellular_alt, size: 16),
                      const SizedBox(width: 4),
                      Icon(Icons.wifi, size: 16),
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          "27",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 2),
                      Icon(Icons.battery_3_bar, size: 16),
                    ],
                  ),
                ],
              ),
            ),
            
            // Header
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
                      hintText: 'Username or Email',
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
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      // Handle login logic
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: const Color.fromARGB(255, 171, 171, 171), 
                      backgroundColor: const Color.fromARGB(255, 255, 0, 221),
                      padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: Text('Login'),
                  ),
                  SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      // Navigate to the registration screen
                      Navigator.pushNamed(context, '/register');
                    },
                    child: Text(
                      "Don't have an account? Register",
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