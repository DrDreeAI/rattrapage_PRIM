import 'package:flutter/material.dart';
import 'screens/input_screen.dart';

void main() {
  runApp(const PrimApp());
}

class PrimApp extends StatelessWidget {
  const PrimApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rattrapage PRIM',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const InputScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
