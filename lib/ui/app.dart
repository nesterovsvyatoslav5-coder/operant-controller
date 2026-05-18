import 'package:flutter/material.dart';
import 'screens/main_screen.dart';

class OperantApp extends StatelessWidget {
  const OperantApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Operant Controller',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueAccent,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}
