import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ButtonState {
  session,
  paused,
  breakTime,
}

final breakDurationProvider = StateProvider<int>((ref) => 5);
final sessionDurationProvider = StateProvider<int>((ref) => 25);

final timerProvider = StateNotifierProvider<TimerNotifier, TimerModel>(
  (ref) {
    final sessionDuration = ref.watch(sessionDurationProvider);
    final breakDuration = ref.watch(breakDurationProvider);
    //
    return TimerNotifier(sessionDuration, breakDuration)..reset();
  },
);

class TimerModel {
  late String timeLeft;
  final ButtonState? buttonState;
  final int seconds;
  TimerModel(this.seconds, this.buttonState) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final remainingSeconds = (seconds % 60).toString().padLeft(2, '0');
    timeLeft = '$minutes:$remainingSeconds';
  }
}

class TimerNotifier extends StateNotifier<TimerModel> {
  Timer? timer;
  final int _initialSessionDuration;
  final int _initialBreakDuration;
  bool _isPaused = true;
  int _sessionDuration;
  int _breakDuration;
  ButtonState _currentButtonState = ButtonState.session;

  TimerNotifier(this._initialSessionDuration, this._initialBreakDuration)
      : _sessionDuration = _initialSessionDuration * 60,
        _breakDuration = _initialBreakDuration * 60,
        super(TimerModel(_initialSessionDuration * 60, null));

  void start() {
    if (_isPaused) {
      _isPaused = false;
      timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_isPaused) {
          timer.cancel();
          return;
        }

        if (_sessionDuration > 0) {
          _sessionDuration--;
          final displayTime = (_sessionDuration);
          _currentButtonState = ButtonState.session;
          state = TimerModel(displayTime, _currentButtonState);
        } else if (_breakDuration > 0) {
          _breakDuration--;
          final displayTime = (_breakDuration);
          _currentButtonState = ButtonState.breakTime;
          state = TimerModel(displayTime, _currentButtonState);
        } else {
          _sessionDuration = _initialSessionDuration * 60;
          _breakDuration = _initialBreakDuration * 60;
          _currentButtonState = ButtonState.session;
        }
      });
    } else {
      _isPaused = true;
      _currentButtonState = ButtonState.paused;
      timer?.cancel();
      state = TimerModel((_sessionDuration), _currentButtonState);
    }
  }

  void togglePause() {
    if (state.buttonState == ButtonState.paused) {
      start();
    } else {
      timer?.cancel();
      state = TimerModel(state.seconds, ButtonState.paused);
    }
  }

  void reset() {
    timer?.cancel();
    _sessionDuration = _initialSessionDuration * 60;
    _breakDuration = _initialBreakDuration * 60;
    _isPaused = true;
    _currentButtonState = ButtonState.paused;
    state = TimerModel(_sessionDuration, _currentButtonState);
  }
}
