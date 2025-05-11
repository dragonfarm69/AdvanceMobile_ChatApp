import 'package:ai_chat_app/features/services/authentication.dart';
import 'package:ai_chat_app/screens/Home%20Screen/Home.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePassword = true;

  void _handleLogin() async {
    // Hide keyboard when submitting
    FocusScope.of(context).unfocus();

    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    setState(() {
      _isLoading = true;
    });

    try {
      final auth = AuthService();
      final result = await auth.signIn(email, password);

      setState(() {
        _isLoading = false;
      });

      if (result != null) {
        // Handle successful login, e.g., navigate to home screen
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white),
                SizedBox(width: 8),
                Text('Invalid email or password. Please try again.'),
              ],
            ),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e, stack) {
      print("Sign in error: $e\n$stack");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 8),
              Text('Login failed. Please check your connection.'),
            ],
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );

      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2C2C2C), Color(0xFF1A1A1A)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight:
                    MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom,
              ),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                      // Logo and header
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.08,
                      ),
                      Image.asset(
                        'assets/logo.png',
                        height: 160,
                        width: 160,
                      ),
                      SizedBox(height: 24),
                      Text(
                        "Welcome Back !",
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        "Sign in to continue",
                        style: TextStyle(fontSize: 16, color: Colors.grey[400]),
                      ),
                      SizedBox(height: 48),

                      // Login form
                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Email field
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              style: TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: 'Email',
                                labelStyle: TextStyle(color: Colors.grey[400]),
                                prefixIcon: Icon(
                                  Icons.email,
                                  color: Colors.grey[400],
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                  borderSide: BorderSide(
                                    color: Colors.grey[700]!,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                  borderSide: BorderSide(
                                    color: Color(0xFFFF00DD),
                                    width: 2,
                                  ),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                  borderSide: BorderSide(
                                    color: Colors.redAccent,
                                  ),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                  borderSide: BorderSide(
                                    color: Colors.redAccent,
                                    width: 2,
                                  ),
                                ),
                                filled: true,
                                fillColor: Colors.grey[900],
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your email';
                                }
                                if (!RegExp(
                                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                ).hasMatch(value)) {
                                  return 'Please enter a valid email address';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 20),

                            // Password field
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) => _handleLogin(),
                              style: TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: 'Password',
                                labelStyle: TextStyle(color: Colors.grey[400]),
                                prefixIcon: Icon(
                                  Icons.lock,
                                  color: Colors.grey[400],
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: Colors.grey[400],
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                  borderSide: BorderSide(
                                    color: Colors.grey[700]!,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                  borderSide: BorderSide(
                                    color: Color(0xFFFF00DD),
                                    width: 2,
                                  ),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                  borderSide: BorderSide(
                                    color: Colors.redAccent,
                                  ),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                  borderSide: BorderSide(
                                    color: Colors.redAccent,
                                    width: 2,
                                  ),
                                ),
                                filled: true,
                                fillColor: Colors.grey[900],
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your password';
                                }
                                return null;
                              },
                            ),

                            // Forgot password
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  // Navigate to forgot password
                                },
                                child: Text(
                                  "Forgot Password?",
                                  style: TextStyle(
                                    color: Color(0xFFFF00DD),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(height: 24),

                            // Login button
                            ElevatedButton(
                              onPressed: _isLoading ? null : _handleLogin,
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Color(0xFFFF00DD),
                                padding: EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                disabledBackgroundColor: Color(
                                  0xFFFF00DD,
                                ).withOpacity(0.6),
                                elevation: 4,
                              ),
                              child:
                                  _isLoading
                                      ? SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2.0,
                                        ),
                                      )
                                      : Text(
                                        "SIGN IN",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                            ),
                          ],
                        ),
                      ),

                      Spacer(),

                      // Register link
                      Padding(
                        padding: const EdgeInsets.only(bottom: 24.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don't have an account? ",
                              style: TextStyle(color: Colors.grey[400]),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(context, '/register');
                              },
                              child: Text(
                                "Sign Up",
                                style: TextStyle(
                                  color: Color(0xFFFF00DD),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
