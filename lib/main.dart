import 'package:chat_app/screens/auth/login_screen.dart';
import 'package:flutter/material.dart';
late Size mq;
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Chatty',
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          iconTheme: IconThemeData(color: Colors.black),
          backgroundColor: Colors.white,
          centerTitle: true,
          elevation: 2,
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 19,
            fontWeight: FontWeight.normal,
          ),
        ),
      ),
      home: const LoginScreen(),
    );
  }
}
