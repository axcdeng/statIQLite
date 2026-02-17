import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TimerState {
  final int remainingSeconds;
  final bool isRunning;
  final bool isCountingDown;
  final int countdownSeconds;

  TimerState({
    this.remainingSeconds = 60,
    this.isRunning = false,
    this.isCountingDown = false,
    this.countdownSeconds = 3,
  });

  TimerState copyWith({
    int? remainingSeconds,
    bool? isRunning,
    bool? isCountingDown,
    int? countdownSeconds,
  }) {
    return TimerState(
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      isRunning: isRunning ?? this.isRunning,
      isCountingDown: isCountingDown ?? this.isCountingDown,
      countdownSeconds: countdownSeconds ?? this.countdownSeconds,
    );
  }
}

class TimerNotifier extends StateNotifier<TimerState> {
  Timer? _timer;
  final void Function(String)? onSound;
  final void Function()? onTick;

  TimerNotifier({this.onSound, this.onTick}) : super(TimerState());

  void start() {
    if (state.remainingSeconds <= 0) return;
    if (state.isRunning || state.isCountingDown) return;

    state = state.copyWith(isCountingDown: true, countdownSeconds: 3);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.isCountingDown) {
        final next = state.countdownSeconds - 1;
        if (next <= 0) {
          state = state.copyWith(isCountingDown: false, isRunning: true);
          onSound?.call('match_start.mp3');
        } else {
          state = state.copyWith(countdownSeconds: next);
          onTick?.call();
        }
        return;
      }

      final next = state.remainingSeconds - 1;
      if (next == 35 || next == 25) {
        onSound?.call('driver_switch.mp3');
      } else if (next == 10) {
        onTick?.call();
      }

      if (next <= 0) {
        state = state.copyWith(remainingSeconds: 0, isRunning: false);
        _timer?.cancel();
        onSound?.call('match_end.mp3');
      } else {
        state = state.copyWith(remainingSeconds: next);
      }
    });
  }

  void pause() {
    _timer?.cancel();
    state = state.copyWith(isRunning: false, isCountingDown: false);
  }

  void reset() {
    _timer?.cancel();
    state = TimerState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final timerProvider = StateNotifierProvider<TimerNotifier, TimerState>((ref) {
  return TimerNotifier();
});
