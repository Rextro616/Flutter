import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      name: "flutter",
      options: const FirebaseOptions(
        apiKey: "AIzaSyB3NbVbXoPcIhPJ7QslNnFdiS2Js62hrPo",
        appId: "1:240123582493:android:f657771013dc57d0c5cef4",
        messagingSenderId: "",
        projectId: "flutter-1c49b",
      ),
    );
  } else {
    Firebase.app();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return MaterialApp(
      title: 'FakeStore',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          elevation: 2,
        ),
        cardTheme: const CardTheme(
          elevation: 2,
          margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        ),
      ),
      home: user == null ? LoginScreen() : HomeScreen(user: user),
    );
  }
}
