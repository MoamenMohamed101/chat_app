import 'package:chat_app/main.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Welcome to Chatty'),
      ),
      body: Stack(
        children: [
          Positioned(
            child: Image.asset('assets/images/icon.png'),
          ),
        ],
      ),
    );
  }
}
