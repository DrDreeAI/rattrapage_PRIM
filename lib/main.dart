import 'package:flutter/material.dart';
import 'screens/input_screen.dart';

void main() {
  // WidgetsFlutterBinding.ensureInitialized(); // Active si tu fais du chargement avant runApp
  runApp(const PrimApp());
}

class PrimApp extends StatelessWidget {
  const PrimApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rattrapage PRIM',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true, // Pour Material3 si tu veux un look plus moderne (optionnel)
      ),
      home: const InputScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
