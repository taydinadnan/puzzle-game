import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_countdown_timer/current_remaining_time.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/puzzle_image.dart';
import '../widgets/answer_input.dart';
import '../models/puzzle_model.dart';

class PuzzleGameScreen extends StatefulWidget {
  @override
  _PuzzleGameScreenState createState() => _PuzzleGameScreenState();
}

class _PuzzleGameScreenState extends State<PuzzleGameScreen> {
  late List<PuzzleModel> puzzles;
  int currentPuzzleIndex = 0;
  bool showFeedback = false;
  bool? isCorrect;
  late GlobalKey<AnswerInputState> answerInputKey;
  int countdownDuration = 3; // Countdown duration in seconds
  int? countdownEndTime; // Store the end time of the countdown
  int score = 0; // User's score
  static const int POINTS_CORRECT = 100;
  static const int POINTS_WRONG = -50;
  late SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    loadScore(); // Load score from SharedPreferences
    puzzles = [
      PuzzleModel(imagePath: 'assets/dog.png', correctAnswer: 'hund'),
      PuzzleModel(imagePath: 'assets/cat.png', correctAnswer: 'katt'),
      PuzzleModel(imagePath: 'assets/häst.png', correctAnswer: 'häst'),
      PuzzleModel(imagePath: 'assets/ko.png', correctAnswer: 'ko'),
      PuzzleModel(imagePath: 'assets/bird.png', correctAnswer: 'fågel'),
      PuzzleModel(imagePath: 'assets/kanin.png', correctAnswer: 'kanin'),
      PuzzleModel(imagePath: 'assets/råtta.png', correctAnswer: 'råtta'),
      PuzzleModel(imagePath: 'assets/björn.png', correctAnswer: 'björn'),
      PuzzleModel(imagePath: 'assets/tiger.png', correctAnswer: 'tiger'),
      PuzzleModel(imagePath: 'assets/lejon.png', correctAnswer: 'lejon'),
      PuzzleModel(imagePath: 'assets/varg.png', correctAnswer: 'varg'),
      PuzzleModel(imagePath: 'assets/elefant.png', correctAnswer: 'elefant'),
      PuzzleModel(imagePath: 'assets/zebra.png', correctAnswer: 'zebra'),
      PuzzleModel(imagePath: 'assets/giraff.png', correctAnswer: 'giraff'),
      PuzzleModel(imagePath: 'assets/pingvin.png', correctAnswer: 'pingvin'),
      PuzzleModel(imagePath: 'assets/val.png', correctAnswer: 'val'),
      PuzzleModel(imagePath: 'assets/delfin.png', correctAnswer: 'delfin'),
      PuzzleModel(imagePath: 'assets/ödla.png', correctAnswer: 'ödla'),
      PuzzleModel(imagePath: 'assets/groda.png', correctAnswer: 'groda'),
      PuzzleModel(imagePath: 'assets/myra.png', correctAnswer: 'myra'),
    ];
    puzzles.shuffle(); // Shuffle puzzles on initialization
    answerInputKey = GlobalKey<AnswerInputState>();
  }

  @override
  Widget build(BuildContext context) {
    PuzzleModel currentPuzzle = currentPuzzleIndex < puzzles.length
        ? puzzles[currentPuzzleIndex]
        : PuzzleModel(imagePath: '', correctAnswer: '');

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/bg.jpg'), // Background image
            fit: BoxFit.cover, // Cover the entire screen
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (countdownEndTime != null)
                    CountdownTimer(
                      endTime: countdownEndTime!,
                      widgetBuilder: (_, CurrentRemainingTime? time) {
                        if (time == null) {
                          return const Text('0');
                        }
                        return Text(
                          '${time.sec}',
                          style: const TextStyle(
                            fontSize: 70,
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                      onEnd: () {
                        setState(() {
                          _moveToNextPuzzle(); // Move to next puzzle
                        });
                      },
                    ),
                  const SizedBox(height: 20),
                  PuzzleImage(imagePath: currentPuzzle.imagePath),
                  const SizedBox(height: 20),
                  AnswerInput(
                    key: answerInputKey,
                    correctAnswer: currentPuzzle.correctAnswer,
                    onAnswerSubmitted: (bool answerIsCorrect) {
                      setState(() {
                        showFeedback = true;
                        isCorrect = answerIsCorrect;
                      });

                      if (answerIsCorrect) {
                        _submitAnswerAndStartCountdown();
                        score += POINTS_CORRECT;
                      } else {
                        score += POINTS_WRONG;
                      }
                      saveScore(); // Save score to SharedPreferences
                    },
                  ),
                  const SizedBox(height: 10),
                  if (showFeedback)
                    Text(
                      isCorrect != null
                          ? (isCorrect! ? 'Correct!' : 'Incorrect')
                          : '',
                      style: TextStyle(
                        color: isCorrect != null
                            ? (isCorrect! ? Colors.green : Colors.red)
                            : Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _submitAnswer,
                    child: const Text('Submit'),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 90,
              right: 20,
              child: Text(
                'Score: $score',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submitAnswer() {
    AnswerInputState? answerInputState = answerInputKey.currentState;
    if (answerInputState != null) {
      bool isCorrect = answerInputState.checkAnswer();
      setState(() {
        showFeedback = true;
        this.isCorrect = isCorrect;
      });

      if (isCorrect) {
        _submitAnswerAndStartCountdown();
        score += POINTS_CORRECT;
      } else {
        score += POINTS_WRONG;
      }
      saveScore(); // Save score to SharedPreferences
    }
  }

  void _submitAnswerAndStartCountdown() {
    setState(() {
      countdownEndTime =
          DateTime.now().millisecondsSinceEpoch + countdownDuration * 1000;
    });
  }

  void _moveToNextPuzzle() {
    setState(() {
      currentPuzzleIndex = (currentPuzzleIndex + 1) % puzzles.length;
      showFeedback = false;
      isCorrect = null;
      answerInputKey.currentState
          ?.resetInputState(); // Reset answer input state
      countdownEndTime = null; // Reset countdown end time
    });
  }

  Future<void> loadScore() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      score = prefs.getInt('score') ?? 0;
    });
  }

  Future<void> saveScore() async {
    prefs = await SharedPreferences.getInstance();
    await prefs.setInt('score', score);
  }

  @override
  void dispose() {
    answerInputKey.currentState
        ?.dispose(); // Dispose of AnswerInputState's controllers
    super.dispose();
  }
}
