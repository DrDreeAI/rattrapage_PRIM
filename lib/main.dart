import 'package:flutter/material.dart';
import 'screens/input_screen.dart';

const Color ratpLightGreen = Color(0xFF59E2C1);
const Color ratpGreen = Color(0xFF00B488);
const Color ratpLightGrey = Color(0xFFF6F6F6);

void main() {
  runApp(const RatpApp());
}

class RatpApp extends StatelessWidget {
  const RatpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nouveau trajet RATP',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.light(
          primary: ratpGreen,
          secondary: ratpLightGreen,
          background: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: ratpLightGreen,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
            letterSpacing: 0.5,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: ratpLightGrey,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(18)),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 16),
          labelStyle: TextStyle(
            color: ratpGreen,
            fontWeight: FontWeight.w500,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: ratpLightGreen,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
            textStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
        cardTheme: CardTheme(
          color: Colors.white,
          elevation: 3,
          margin: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontSize: 17, color: Colors.black87),
          bodyMedium: TextStyle(fontSize: 15, color: Colors.black54),
        ),
      ),
      home: const InputScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
