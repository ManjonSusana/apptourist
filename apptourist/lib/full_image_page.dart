import 'package:flutter/material.dart';

class FullImagePage extends StatelessWidget {
  final String image;

  const FullImagePage({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Center(
          child: InteractiveViewer(
            maxScale: 5,
            minScale: 0.5,
            child: Image.asset(image, fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }
}
