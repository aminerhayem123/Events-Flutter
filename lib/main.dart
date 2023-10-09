import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase/features/user_auth/presentation/pages/home_page.dart';
import 'package:flutter_firebase/features/user_auth/presentation/pages/login_page.dart';
import 'package:flutter_firebase/features/user_auth/presentation/pages/sign_up_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: "AIzaSyC7a5Q8swhWFwj6hudI3PC57aNGTw0GLHk",
        appId: "1:987643428825:web:6b2ac1887cf77cb47023c8",
        storageBucket: "events-6b65e.appspot.com",
        messagingSenderId: "987643428825",
        projectId: "events-6b65e",
        // Your web Firebase config options
      ),
    );
  } else {
    await Firebase.initializeApp();
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Firebase',
      initialRoute: '/', // Set the initial route to '/'
      routes: {
        '/': (context) => StreamBuilder(
              // Use a StreamBuilder to listen to changes in the user's authentication state
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.active) {
                  // If the connection is active, check if the user is authenticated
                  final user = FirebaseAuth.instance.currentUser;
                  if (user != null) {
                    // If the user is authenticated, navigate to the HomePage
                    return HomePage();
                  } else {
                    // If the user is not authenticated, navigate to the LoginPage
                    return LoginPage();
                  }
                } else {
                  // If the connection is not active, display a loading indicator
                  return CircularProgressIndicator();
                }
              },
            ),
        '/login': (context) => LoginPage(),
        '/signUp': (context) => SignUpPage(),
        '/home': (context) => HomePage(),
      },
    );
  }
}
