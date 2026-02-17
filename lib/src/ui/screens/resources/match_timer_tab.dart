import 'dart:async';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MatchTimerTab extends StatefulWidget {
  const MatchTimerTab({super.key});

  @override
  State<MatchTimerTab> createState() => _MatchTimerTabState();
}

class _MatchTimerTabState extends State<MatchTimerTab>
    with TickerProviderStateMixin {
  static const int _defaultDuration = 60; // VEX IQ match = 60 seconds

  final int _totalSeconds = _defaultDuration;
  int _remainingSeconds = _defaultDuration;
  Timer? _timer;
  bool _isRunning = false;
  bool _isFullscreen = false;

  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _start() {
    if (_remainingSeconds <= 0) return;
    setState(() => _isRunning = true);
    _playSystemSound(); // Start sound
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _remainingSeconds--;
        // Warning at 10 seconds
        if (_remainingSeconds == 10) {
          _pulseController.repeat(reverse: true);
          _playSystemSound();
        }
        // Driver switch at 30 seconds
        if (_remainingSeconds == 30) {
          _playSystemSound();
        }
        if (_remainingSeconds <= 0) {
          _remainingSeconds = 0;
          _isRunning = false;
          _timer?.cancel();
          _pulseController.stop();
          _pulseController.value = 0;
          _playSystemSound(); // End sound
        }
      });
    });
  }

  void _pause() {
    _timer?.cancel();
    setState(() => _isRunning = false);
    _pulseController.stop();
  }

  void _reset() {
    _timer?.cancel();
    _pulseController.stop();
    _pulseController.value = 0;
    setState(() {
      _remainingSeconds = _totalSeconds;
      _isRunning = false;
    });
  }

  void _playSystemSound() {
    SystemSound.play(SystemSoundType.click);
    HapticFeedback.mediumImpact();
  }

  void _toggleFullscreen() {
    setState(() => _isFullscreen = !_isFullscreen);
    if (_isFullscreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }

  Color get _timerColor {
    final fraction = _remainingSeconds / _totalSeconds;
    if (fraction > 0.5) return Theme.of(context).colorScheme.primary;
    if (fraction > 0.17) return CupertinoColors.activeOrange;
    return CupertinoColors.destructiveRed;
  }

  String get _timeString {
    final m = (_remainingSeconds ~/ 60).toString().padLeft(1, '0');
    final s = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return OrientationBuilder(
      builder: (context, orientation) {
        final isLandscape = orientation == Orientation.landscape;

        if (isLandscape || _isFullscreen) {
          return Scaffold(
            backgroundColor: CupertinoColors.systemBackground,
            body: SafeArea(
              child: Row(
                children: [
                  // Left side: Big Timer
                  Expanded(
                    flex: 2,
                    child: Center(
                      child: _buildBigTimerText(),
                    ),
                  ),
                  // Right side: Controls Stacked
                  Container(
                    width: 140,
                    color: Colors.transparent, // Fix weird background
                    padding: EdgeInsets
                        .zero, // Remove vertical padding to save space
                    child: Center(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildControlButton(
                              icon: CupertinoIcons.arrow_counterclockwise,
                              label: 'Reset',
                              onTap: _reset,
                              color: CupertinoColors.systemGrey,
                            ),
                            const SizedBox(height: 16), // Reduced spacing
                            _buildPlayButton(primaryColor),
                            const SizedBox(height: 16), // Reduced spacing
                            _buildControlButton(
                              icon: isLandscape
                                  ? CupertinoIcons.fullscreen_exit
                                  : CupertinoIcons.fullscreen,
                              label: isLandscape ? 'Exit' : 'Full',
                              onTap: _toggleFullscreen,
                              color: CupertinoColors.systemGrey,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Portrait Layout
        return Column(
          children: [
            const Spacer(),
            // Timer Circle
            Expanded(
              flex: 3,
              child: Center(child: _buildTimerCircle(primaryColor)),
            ),
            const Spacer(),

            // Controls
            Padding(
              padding: const EdgeInsets.only(bottom: 48),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildControlButton(
                    icon: CupertinoIcons.arrow_counterclockwise,
                    label: 'Reset',
                    onTap: _reset,
                    color: CupertinoColors.systemGrey,
                  ),
                  const SizedBox(width: 32),
                  _buildPlayButton(primaryColor),
                  const SizedBox(width: 32),
                  _buildControlButton(
                    icon: CupertinoIcons.fullscreen,
                    label: 'Full',
                    onTap: _toggleFullscreen,
                    color: CupertinoColors.systemGrey,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBigTimerText() {
    return FittedBox(
      fit: BoxFit.contain,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          _timeString,
          style: TextStyle(
            color: _timerColor,
            fontSize: 400, // Massive font size to force FittedBox to fill space
            fontWeight: FontWeight.w900,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ),
    );
  }

  Widget _buildTimerCircle(Color primaryColor) {
    // In portrait, keep the circle look but simpler
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final pulseScale = _remainingSeconds <= 10 && _isRunning
            ? 1.0 + (_pulseController.value * 0.03)
            : 1.0;

        return Transform.scale(
          scale: pulseScale,
          child: AspectRatio(
            aspectRatio: 1,
            child: CustomPaint(
              painter: _CircleTimerPainter(
                progress: _remainingSeconds / _totalSeconds,
                color: _timerColor,
                backgroundColor: CupertinoColors.tertiarySystemFill,
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _timeString,
                      style: TextStyle(
                        color: _timerColor,
                        fontSize: 80,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -2,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    if (_isRunning &&
                        _remainingSeconds <= 30 &&
                        _remainingSeconds > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          _remainingSeconds <= 10
                              ? 'FINAL SECONDS'
                              : 'DRIVER 2',
                          style: TextStyle(
                            color: _timerColor.withAlpha((0.8 * 255)
                                .round()), // Changed .withOpacity(0.8) to .withAlpha
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.0,
                          ),
                        ),
                      )
                    else if (!_isRunning && _remainingSeconds == 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'MATCH OVER',
                          style: TextStyle(
                            color: _timerColor.withAlpha((0.8 * 255)
                                .round()), // Changed .withOpacity(0.8) to .withAlpha
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlayButton(Color primaryColor) {
    return GestureDetector(
      onTap: _isRunning ? _pause : _start,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _isRunning ? CupertinoColors.activeOrange : primaryColor,
          boxShadow: [
            BoxShadow(
              color: (_isRunning ? CupertinoColors.activeOrange : primaryColor)
                  .withAlpha((0.4 * 255)
                      .round()), // Changed .withOpacity(0.4) to .withAlpha
              blurRadius: 16,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Icon(
          _isRunning ? CupertinoIcons.pause_fill : CupertinoIcons.play_fill,
          color: Colors.white,
          size: 44, // Slightly larger icon
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: CupertinoColors.tertiarySystemFill,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 6),
          Text(label,
              style: TextStyle(
                  color: color, fontSize: 11, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _CircleTimerPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;

  _CircleTimerPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 12;
    const strokeWidth = 8.0;

    // Background track
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2, // Start from top
      sweepAngle,
      false,
      progressPaint,
    );

    // Glow dot at the end of the arc
    if (progress > 0 && progress < 1) {
      final dotAngle = -pi / 2 + sweepAngle;
      final dotX = center.dx + radius * cos(dotAngle);
      final dotY = center.dy + radius * sin(dotAngle);
      final dotPaint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(dotX, dotY), strokeWidth / 2 + 2, dotPaint);

      // Glow effect
      final glowPaint = Paint()
        ..color = color.withOpacity(0.3)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawCircle(Offset(dotX, dotY), strokeWidth + 4, glowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _CircleTimerPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
