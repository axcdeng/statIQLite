import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:roboscout_iq/src/state/providers.dart';
import 'package:roboscout_iq/src/state/timer_provider.dart';

class MatchTimerTab extends ConsumerStatefulWidget {
  final bool isActive;
  const MatchTimerTab({super.key, this.isActive = true});

  @override
  ConsumerState<MatchTimerTab> createState() => _MatchTimerTabState();
}

class _MatchTimerTabState extends ConsumerState<MatchTimerTab>
    with TickerProviderStateMixin {
  static const int _totalSeconds = 60;
  late final AudioPlayer _audioPlayer;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _audioPlayer = AudioPlayer();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _playLocalSound(String fileName) async {
    try {
      await _audioPlayer.play(AssetSource('audio/$fileName'));
    } catch (e) {
      debugPrint('Error playing sound $fileName: $e');
    }
  }

  void _playSystemSound() {
    SystemSound.play(SystemSoundType.click);
    HapticFeedback.mediumImpact();
  }

  void _toggleFullscreen() {
    Navigator.of(context, rootNavigator: true).push(
      CupertinoPageRoute(
        fullscreenDialog: true,
        builder: (context) => const FullscreenTimerPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(timerProvider);
    final notifier = ref.read(timerProvider.notifier);
    final primaryColor = Theme.of(context).colorScheme.primary;

    // Listen for sounds at the UI level
    ref.listen(timerProvider, (previous, next) {
      if (next.isCountingDown &&
          (previous?.countdownSeconds ?? 0) != next.countdownSeconds) {
        _playSystemSound();
      }
      if (next.isRunning && !(previous?.isRunning ?? false)) {
        _playLocalSound('match_start.mp3');
      }
      if (next.remainingSeconds == 35 &&
          (previous?.remainingSeconds ?? 0) == 36) {
        _playLocalSound('driver_switch.mp3');
      }
      if (next.remainingSeconds == 25 &&
          (previous?.remainingSeconds ?? 0) == 26) {
        _playLocalSound('driver_switch.mp3');
      }
      if (next.remainingSeconds == 0 &&
          (previous?.remainingSeconds ?? 0) == 1) {
        _playLocalSound('match_end.mp3');
      }
      if (next.remainingSeconds <= 10 &&
          next.remainingSeconds < (previous?.remainingSeconds ?? 0)) {
        _playSystemSound();
      }
    });

    if (state.remainingSeconds == 10 && state.isRunning) {
      if (!_pulseController.isAnimating) {
        _pulseController.repeat(reverse: true);
      }
    } else if (!state.isRunning || state.remainingSeconds > 10) {
      _pulseController.stop();
      _pulseController.value = 0;
    }

    return OrientationBuilder(
      builder: (context, orientation) {
        final actualOrientation = MediaQuery.of(context).orientation;

        if (actualOrientation == Orientation.landscape && widget.isActive) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final mainIndex = ref.read(bottomNavIndexProvider);
            final resourcesTab = ref.read(resourcesTabProvider);
            final route = ModalRoute.of(context);
            // Only toggle if we are on the Resources tab (index 3) AND the Timer sub-tab (index 3)
            // AND the screen is actually currently visible.
            if (mainIndex == 3 &&
                resourcesTab == 3 &&
                route != null &&
                route.isCurrent) {
              _toggleFullscreen();
            }
          });
          return const SizedBox.shrink();
        }

        return Column(
          children: [
            Expanded(
              child: Center(
                  child: _buildTimerCircle(primaryColor, state, context)),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 64),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildControlButton(
                    icon: CupertinoIcons.arrow_counterclockwise,
                    label: 'Reset',
                    onTap: notifier.reset,
                    color: CupertinoColors.systemGrey,
                  ),
                  const SizedBox(width: 32),
                  _buildPlayButton(primaryColor, state, notifier),
                  const SizedBox(width: 32),
                  _buildControlButton(
                    icon: CupertinoIcons.rotate_right,
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

  String _timeString(TimerState state) {
    if (state.isCountingDown) return '${state.countdownSeconds}';
    final m = (state.remainingSeconds ~/ 60).toString().padLeft(1, '0');
    final s = (state.remainingSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Color _timerColor(TimerState state, BuildContext context) {
    final fraction = state.remainingSeconds / _totalSeconds;
    if (fraction > 0.5) return Theme.of(context).colorScheme.primary;
    if (fraction > 0.17) return CupertinoColors.activeOrange;
    return CupertinoColors.destructiveRed;
  }

  Widget _buildTimerCircle(
      Color primaryColor, TimerState state, BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final pulseScale = state.remainingSeconds <= 10 && state.isRunning
            ? 1.0 + (_pulseController.value * 0.03)
            : 1.0;

        return Transform.scale(
          scale: pulseScale,
          child: AspectRatio(
            aspectRatio: 1,
            child: CustomPaint(
              painter: _CircleTimerPainter(
                progress: state.isCountingDown
                    ? state.countdownSeconds / 3
                    : state.remainingSeconds / _totalSeconds,
                color: _timerColor(state, context),
                backgroundColor: CupertinoColors.tertiarySystemFill,
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (state.isCountingDown)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              'Starting in...',
                              style: TextStyle(
                                color: CupertinoColors.secondaryLabel
                                    .resolveFrom(context),
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        Text(
                          _timeString(state),
                          style: TextStyle(
                            color: _timerColor(state, context),
                            fontSize: 100,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -2,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                        if (state.isRunning &&
                            state.remainingSeconds <= 35 &&
                            state.remainingSeconds > 0)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              state.remainingSeconds <= 10
                                  ? 'FINAL SECONDS'
                                  : state.remainingSeconds > 25
                                      ? 'DRIVER SWITCH'
                                      : 'DRIVER 2',
                              style: TextStyle(
                                color: _timerColor(state, context)
                                    .withAlpha((0.8 * 255).round()),
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.0,
                              ),
                            ),
                          )
                        else if (!state.isRunning &&
                            !state.isCountingDown &&
                            state.remainingSeconds == 0)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              'MATCH OVER',
                              style: TextStyle(
                                color: _timerColor(state, context)
                                    .withAlpha((0.8 * 255).round()),
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
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlayButton(
      Color primaryColor, TimerState state, TimerNotifier notifier) {
    final isRunning = state.isRunning || state.isCountingDown;
    return GestureDetector(
      onTap: isRunning ? notifier.pause : notifier.start,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isRunning ? CupertinoColors.activeOrange : primaryColor,
          boxShadow: [
            BoxShadow(
              color: (isRunning ? CupertinoColors.activeOrange : primaryColor)
                  .withAlpha((0.2 * 255).round()),
              blurRadius: 12,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Icon(
          isRunning ? CupertinoIcons.pause_fill : CupertinoIcons.play_fill,
          color: Colors.white,
          size: 44,
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

class FullscreenTimerPage extends ConsumerStatefulWidget {
  const FullscreenTimerPage({super.key});

  @override
  ConsumerState<FullscreenTimerPage> createState() =>
      _FullscreenTimerPageState();
}

class _FullscreenTimerPageState extends ConsumerState<FullscreenTimerPage> {
  late final AudioPlayer _audioPlayer;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    _audioPlayer.dispose();
    super.dispose();
  }

  void _playLocalSound(String fileName) async {
    try {
      await _audioPlayer.play(AssetSource('audio/$fileName'));
    } catch (e) {
      debugPrint('Error playing sound $fileName: $e');
    }
  }

  void _playSystemSound() {
    SystemSound.play(SystemSoundType.click);
    HapticFeedback.mediumImpact();
  }

  String _timeString(TimerState state) {
    if (state.isCountingDown) return '${state.countdownSeconds}';
    final m = (state.remainingSeconds ~/ 60).toString().padLeft(1, '0');
    final s = (state.remainingSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Color _timerColor(TimerState state) {
    if (state.remainingSeconds > 30) {
      return Theme.of(context).colorScheme.primary;
    }
    if (state.remainingSeconds > 10) return CupertinoColors.activeOrange;
    return CupertinoColors.destructiveRed;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(timerProvider);
    final notifier = ref.read(timerProvider.notifier);
    final primaryColor = Theme.of(context).colorScheme.primary;

    // Same sound listener logic
    ref.listen(timerProvider, (previous, next) {
      // Logic to play sounds based on state transitions
      if (next.isCountingDown &&
          (previous?.countdownSeconds ?? 0) != next.countdownSeconds) {
        _playSystemSound();
      }
      if (next.isRunning && !(previous?.isRunning ?? false)) {
        _playLocalSound('match_start.mp3');
      }
      if (next.remainingSeconds == 35 &&
          (previous?.remainingSeconds ?? 0) == 36) {
        _playLocalSound('driver_switch.mp3');
      }
      if (next.remainingSeconds == 25 &&
          (previous?.remainingSeconds ?? 0) == 26) {
        _playLocalSound('driver_switch.mp3');
      }
      if (next.remainingSeconds == 0 &&
          (previous?.remainingSeconds ?? 0) == 1) {
        _playLocalSound('match_end.mp3');
      }
      if (next.remainingSeconds <= 10 &&
          next.remainingSeconds < (previous?.remainingSeconds ?? 0)) {
        _playSystemSound();
      }
    });

    // Auto-pop when rotating back to portrait
    if (MediaQuery.of(context).orientation == Orientation.portrait) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      });
    }

    return Scaffold(
      backgroundColor: CupertinoColors.black,
      body: SafeArea(
        child: Row(
          children: [
            // Big Timer
            Expanded(
              child: Center(
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (state.isCountingDown)
                          const Text(
                            'Starting in...',
                            style: TextStyle(
                              color: CupertinoColors.systemGrey,
                              fontSize: 40,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        Text(
                          _timeString(state),
                          style: TextStyle(
                            color: _timerColor(state),
                            fontSize: 400,
                            fontWeight: FontWeight.w900,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                        if (state.isRunning &&
                            state.remainingSeconds <= 35 &&
                            state.remainingSeconds > 0)
                          Text(
                            state.remainingSeconds <= 10
                                ? 'FINAL SECONDS'
                                : state.remainingSeconds > 25
                                    ? 'DRIVER SWITCH'
                                    : 'DRIVER 2',
                            style: TextStyle(
                              color: _timerColor(state).withAlpha(200),
                              fontSize: 50,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 2.0,
                            ),
                          )
                        else if (!state.isRunning &&
                            !state.isCountingDown &&
                            state.remainingSeconds == 0)
                          Text(
                            'MATCH OVER',
                            style: TextStyle(
                              color: _timerColor(state).withAlpha(200),
                              fontSize: 50,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 2.0,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Controls
            Container(
              width: 120,
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildFullscreenControlButton(
                    icon: CupertinoIcons.fullscreen_exit,
                    onTap: () => Navigator.of(context).pop(),
                    color: CupertinoColors.systemGrey,
                  ),
                  const SizedBox(height: 24),
                  _buildFullscreenPlayButton(primaryColor, state, notifier),
                  const SizedBox(height: 24),
                  _buildFullscreenControlButton(
                    icon: CupertinoIcons.arrow_counterclockwise,
                    onTap: notifier.reset,
                    color: CupertinoColors.systemGrey,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFullscreenPlayButton(
      Color primaryColor, TimerState state, TimerNotifier notifier) {
    final isRunning = state.isRunning || state.isCountingDown;
    return GestureDetector(
      onTap: isRunning ? notifier.pause : notifier.start,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isRunning ? CupertinoColors.activeOrange : primaryColor,
        ),
        child: Icon(
          isRunning ? CupertinoIcons.pause_fill : CupertinoIcons.play_fill,
          color: Colors.white,
          size: 40,
        ),
      ),
    );
  }

  Widget _buildFullscreenControlButton({
    required IconData icon,
    required VoidCallback onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: CupertinoColors.systemGrey.withAlpha(50),
        ),
        child: Icon(icon, color: Colors.white, size: 28),
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
        ..color = color.withValues(alpha: 0.3)
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
