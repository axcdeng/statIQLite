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
      backgroundColor: CupertinoColors.systemBackground.resolveFrom(context),
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          title,
        ),
        leading: CupertinoNavigationBarBackButton(
          color: Theme.of(context).colorScheme.primary,
        ),
        backgroundColor: CupertinoColors.systemBackground
            .resolveFrom(context)
            .withValues(alpha: 0.8),
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
