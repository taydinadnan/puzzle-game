import 'package:flutter/material.dart';

class PuzzleImage extends StatelessWidget {
  final String imagePath;

  PuzzleImage({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      imagePath,
      width: 200,
      height: 200,
    );
  }
}
