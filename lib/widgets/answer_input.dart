import 'package:flutter/material.dart';

class AnswerInput extends StatefulWidget {
  final String correctAnswer;
  final Function(bool) onAnswerSubmitted;

  AnswerInput({
    required this.correctAnswer,
    required this.onAnswerSubmitted,
    Key? key,
  }) : super(key: key);

  @override
  AnswerInputState createState() => AnswerInputState();
}

class AnswerInputState extends State<AnswerInput> {
  late List<TextEditingController> controllers;

  @override
  void initState() {
    super.initState();
    resetInputState(); // Initialize the controllers
  }

  void resetInputState() {
    controllers = List.generate(
      widget.correctAnswer.length,
      (index) => TextEditingController(),
    );
    for (var controller in controllers) {
      controller.clear(); // Ensure controllers are cleared
    }
  }

  void updateInputState(String newCorrectAnswer) {
    setState(() {
      resetInputState();
    });
  }

  @override
  void dispose() {
    for (var controller in controllers) {
      controller.dispose(); // Dispose of controllers properly
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant AnswerInput oldWidget) {
    if (oldWidget.correctAnswer != widget.correctAnswer) {
      updateInputState(widget.correctAnswer);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('Enter the word:', style: TextStyle(fontSize: 18)),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.correctAnswer.length, (index) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: SizedBox(
                width: 50,
                child: TextField(
                  textAlign: TextAlign.center,
                  maxLength: 1,
                  controller: controllers[index],
                  onChanged: (value) {
                    // Update the corresponding text controller's text
                    controllers[index].text = value.toLowerCase();
                  },
                  decoration: InputDecoration(
                    counterText: '',
                    border: const OutlineInputBorder(),
                    filled: true,
                    fillColor: _getBoxColor(index),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Color _getBoxColor(int index) {
    String userAnswer = controllers[index].text;
    String correctAnswerLetter = widget.correctAnswer[index].toLowerCase();

    if (userAnswer.isEmpty) {
      return Colors.white; // Default color for empty box
    } else if (userAnswer == correctAnswerLetter) {
      return Colors.green; // Green for correct answer
    } else {
      return Colors.red; // Red for incorrect answer
    }
  }

  bool checkAnswer() {
    String joinedAnswers =
        controllers.map((controller) => controller.text.toLowerCase()).join('');
    return joinedAnswers == widget.correctAnswer.toLowerCase();
  }
}
