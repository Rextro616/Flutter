import 'package:flutter/material.dart';
import 'screens/product_list_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FakeStore',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        appBarTheme: AppBarTheme(
          centerTitle: true,
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          elevation: 2,
        ),
        cardTheme: CardTheme(
          elevation: 2,
          margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        ),
      ),
      home: ProductListScreen(),
    );
  }
}