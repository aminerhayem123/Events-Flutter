import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore package
import 'package:flutter_firebase/features/user_auth/firebase_auth_implementation/firebase_auth_services.dart';
import 'package:flutter_firebase/features/user_auth/presentation/pages/login_page.dart';
import 'package:flutter_firebase/features/user_auth/presentation/widgets/form_container_widget.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final FirebaseAuthService _auth = FirebaseAuthService();

  TextEditingController _usernameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  String? _selectedRole; // Track selected role

  @override
  void dispose() {
    _usernameController.dispose();
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
                image: NetworkImage('web/background.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 100),
                  // First Image and Text
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.network(
                        'web/logo.png',
                        width: 50,
                        height: 50,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        "Sign Up",
                        style: TextStyle(
                          fontSize: 27,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 30),
                  FormContainerWidget(
                    controller: _usernameController,
                    hintText: "Username",
                    isPasswordField: false,
                  ),
                  SizedBox(height: 10),
                  FormContainerWidget(
                    controller: _emailController,
                    hintText: "Email",
                    isPasswordField: false,
                  ),
                  SizedBox(height: 10),
                  FormContainerWidget(
                    controller: _passwordController,
                    hintText: "Password",
                    isPasswordField: true,
                  ),
                  SizedBox(height: 30),
                  // Role selection checkboxes
                  Column(
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            value: _selectedRole == 'Event Owner',
                            onChanged: (value) {
                              setState(() {
                                _selectedRole =
                                    value ?? false ? 'Event Owner' : null;
                              });
                            },
                          ),
                          Text('Event Owner'),
                        ],
                      ),
                      Row(
                        children: [
                          Checkbox(
                            value: _selectedRole == 'Simple User',
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _selectedRole = value ? 'Simple User' : null;
                                });
                              }
                            },
                          ),
                          Text('Simple User'),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: _signUp,
                    style: ElevatedButton.styleFrom(
                      primary: Colors.purple,
                      padding: EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      "Sign Up",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have an account? ",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LoginPage(),
                            ),
                            (route) => false,
                          );
                        },
                        child: Text(
                          "Login",
                          style: TextStyle(
                            color: Colors.purple,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _signUp() async {
    String username = _usernameController.text;
    String email = _emailController.text;
    String password = _passwordController.text;

    // Regular expression to validate email format
    final emailRegExp = RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$');

    // Check if any of the input fields is empty
    if (username.isEmpty || email.isEmpty || password.isEmpty) {
      // Show a message to the user
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Error"),
            content: Text("Please fill in all fields."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("OK"),
              ),
            ],
          );
        },
      );
    } else if (!emailRegExp.hasMatch(email)) {
      // Check if email format is invalid and show an error message
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Email Error"),
            content: Text("Please enter a valid email address."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("OK"),
              ),
            ],
          );
        },
      );
    } else if (password.length < 6 ||
        !password.contains(RegExp(r'[A-Z]')) ||
        !password.contains(RegExp(r'[a-zA-Z0-9]'))) {
      // Check password requirements and show an error message
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Password Error"),
            content: Text(
                "Password must be at least 6 characters long, contain at least one uppercase letter, and contain only letters and numbers."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("OK"),
              ),
            ],
          );
        },
      );
    } else if (_selectedRole == null) {
      // Check if the user has selected a role
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Role Error"),
            content: Text("Please select a role."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("OK"),
              ),
            ],
          );
        },
      );
    } else {
      try {
        final UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        // User registration was successful

        // Get the Firebase user ID
        String userId = userCredential.user!.uid;

        // Save the user's role and ID in Firestore
        await FirebaseFirestore.instance.collection('users').doc(userId).set({
          'username': username,
          'email': email,
          'role': _selectedRole,
        });

        print("User is successfully created");

        // Show a success message

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Success"),
              content: Text("Registration successful."),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LoginPage(),
                      ),
                      (route) => false,
                    );
                  },
                  child: Text("OK"),
                ),
              ],
            );
          },
        );
      } catch (e) {
        if (e is FirebaseAuthException) {
          if (e.code == 'email-already-in-use') {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text("Email Already in Use"),
                  content: Text(
                      "The email address is already in use. Please use a different email."),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text("OK"),
                    ),
                  ],
                );
              },
            );
          } else {
            print("Error code: ${e.code}");
            print("Error message: ${e.message}");
          }
        } else {
          print("Error occurred during registration: ${e.toString()}");
        }
      }
    }
  }
}
