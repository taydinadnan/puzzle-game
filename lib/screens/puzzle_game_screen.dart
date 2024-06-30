import 'package:flutter/material.dart';
import 'package:flutter_countdown_timer/current_remaining_time.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import '../widgets/puzzle_image.dart';
import '../widgets/answer_input.dart';
import '../models/puzzle_model.dart';

class PuzzleGameScreen extends StatefulWidget {
  const PuzzleGameScreen({super.key});

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

  @override
  void initState() {
    super.initState();
    puzzles = [
      PuzzleModel(imagePath: 'assets/cat.png', correctAnswer: 'cat'),
      PuzzleModel(imagePath: 'assets/dog.png', correctAnswer: 'dog'),
      PuzzleModel(imagePath: 'assets/bird.png', correctAnswer: 'bird'),
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
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (countdownEndTime != null)
                Positioned(
                  top: 20,
                  child: CountdownTimer(
                    endTime: countdownEndTime!,
                    widgetBuilder: (_, CurrentRemainingTime? time) {
                      if (time == null) {
                        return const Text('0');
                      }
                      return Text('${time.sec}',
                          style: const TextStyle(
                              fontSize: 70,
                              color: Colors.green,
                              fontWeight: FontWeight.bold));
                    },
                    onEnd: () {
                      setState(() {
                        _moveToNextPuzzle(); // Move to next puzzle
                      });
                    },
                  ),
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
                  }
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
      }
    }
  }

  void _submitAnswerAndStartCountdown() {
    // Calculate the exact end time for the countdown
    int startTime = DateTime.now().millisecondsSinceEpoch;
    int endTime = startTime + (countdownDuration * 1250);

    setState(() {
      countdownEndTime = endTime;
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

  @override
  void dispose() {
    answerInputKey.currentState
        ?.dispose(); // Dispose of AnswerInputState's controllers
    super.dispose();
  }
}
