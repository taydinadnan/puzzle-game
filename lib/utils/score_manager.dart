import 'package:shared_preferences/shared_preferences.dart';

class ScoreManager {
  static const String _scoreKey = 'score';

  static Future<int> loadScore() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_scoreKey) ?? 0;
  }

  static Future<void> saveScore(int score) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_scoreKey, score);
  }
}
