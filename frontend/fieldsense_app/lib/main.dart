// main.dart
// FieldSense — Dark Sky inspired clean agricultural intelligence.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const FieldSenseApp());
}

class FieldSenseApp extends StatelessWidget {
  const FieldSenseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FieldSense',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F1923),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF4A90D9),
          secondary: Color(0xFF5BA05E),
          surface: Color(0xFF1A2535),
          error: Color(0xFFE05C5C),
        ),
        textTheme: const TextTheme(
          titleLarge: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w300,
            letterSpacing: -0.5,
          ),
          titleMedium: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          titleSmall: TextStyle(
            color: Color(0xFF78909C),
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
          bodyMedium: TextStyle(
            color: Color(0xFFCFD8DC),
            fontSize: 14,
            height: 1.6,
          ),
          bodySmall: TextStyle(
            color: Color(0xFF546E7A),
            fontSize: 12,
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
