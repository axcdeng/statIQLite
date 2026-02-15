import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FullScreenImageViewer extends StatelessWidget {
  final String imagePath;
  final String title;

  const FullScreenImageViewer({
    super.key,
    required this.imagePath,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    // Use a black background for distraction-free viewing
    return CupertinoPageScaffold(
      backgroundColor: Colors.black,
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          title,
          style: const TextStyle(color: CupertinoColors.white),
        ),
        backgroundColor: Colors.black.withOpacity(0.8),
      ),
      child: SafeArea(
        // Ensure it doesn't clip with notches/dynamic island
        child: Center(
          child: InteractiveViewer(
            panEnabled: true,
            minScale: 1.0,
            maxScale: 5.0, // Allow zooming up to 5x
            child: Image.asset(
              imagePath,
              fit:
                  BoxFit.contain, // Ensure the whole image is visible initially
              width: double.infinity,
              height: double.infinity,
            ),
          ),
        ),
      ),
    );
  }
}
