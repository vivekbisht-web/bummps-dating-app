import 'package:flutter/material.dart';

class AuthTests extends StatefulWidget{
  const AuthTests({super.key});

  @override
  State<AuthTests> createState() => _AuthTestState();

}

class _AuthTestState extends State<AuthTests> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('All test cases'),
      ),
    );
  }
}