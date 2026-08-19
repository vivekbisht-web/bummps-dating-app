import 'package:flutter/material.dart';

class TestCase extends StatefulWidget {
  const TestCase({super.key});

  @override
  State<StatefulWidget> createState() => _TestCasesState();
}

class _TestCasesState extends State<TestCase> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "All Test Cases here..."
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,

          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('Test Case To See All Logs!')
          ],
        ),
      ),
    );
  }
}