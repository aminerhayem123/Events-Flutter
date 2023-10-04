import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase/features/user_auth/presentation/pages/sign_up_page.dart';
import 'package:flutter_firebase/features/user_auth/presentation/widgets/form_container_widget.dart';
import '../../firebase_auth_implementation/firebase_auth_services.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isSigning = false;
  final FirebaseAuthService _auth = FirebaseAuthService();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  String _errorText = '';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Second Background Image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(
                    'web/background.png'), // Load the second background image
                fit: BoxFit.cover,
              ),
            ),
          ),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 100),
                  // First Image and Text
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.network(
                        'web/logo.png', // Load the first image
                        width: 50, // Adjust the width as needed
                        height: 50, // Adjust the height as needed
                      ),
                      SizedBox(
                          width: 10), // Add spacing between the image and text
                      Text(
                        "Event Booking",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white, // Text color
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 30),
                  FormContainerWidget(
                    controller: _emailController,
                    hintText: "Email",
                    isPasswordField: false,
                  ),
                  SizedBox(height: 20),
                  FormContainerWidget(
                    controller: _passwordController,
                    hintText: "Password",
                    isPasswordField: true,
                  ),
                  SizedBox(height: 10),
                  Text(
                    _errorText, // Display error message if there's an error
                    style: TextStyle(
                      color: Colors.red, // Text color for error message
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _signIn,
                    style: ElevatedButton.styleFrom(
                      primary: Colors.purple, // Button color
                      padding: EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      "Login",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => SignUpPage()),
                        (route) => false,
                      );
                    },
                    child: RichText(
                      text: TextSpan(
                        text: "Don't have an account? ",
                        style: TextStyle(
                          color: Colors
                              .white, // Text color for "Don't have an account?"
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        children: [
                          TextSpan(
                            text: "Sign Up",
                            style: TextStyle(
                              color: Colors.purple, // Text color for "Sign Up"
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _signIn() async {
    String email = _emailController.text;
    String password = _passwordController.text;

    setState(() {
      _errorText = ''; // Clear any previous error message
    });

    try {
      User? user = await _auth.signInWithEmailAndPassword(email, password);

      if (user != null) {
        print("User is successfully signed in");
        Navigator.pushNamed(context, "/home");
      }
    } catch (e) {
      setState(() {
        _errorText = "Invalid email or password"; // Set error message
      });
      print("Error: $e");
    }
  }
}
