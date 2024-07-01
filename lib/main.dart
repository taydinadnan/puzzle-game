import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/puzzle_game_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPreferences.getInstance(); // Initialize SharedPreferences
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Puzzle Game',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: PuzzleGameScreen(),
    );
  }
}
