import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/workout_config.dart';
import '../models/workout_mode.dart';
import '../models/workout_set.dart';
import '../services/audio_service.dart';

class WorkoutState {
  final WorkoutConfig config;
  final TimerState timerState;
  final int currentSetIndex;
  final int remainingSeconds;
  final DateTime? startTime;
  final int? pausedAtSeconds;

  WorkoutState({
    required this.config,
    required this.timerState,
    required this.currentSetIndex,
    required this.remainingSeconds,
    this.startTime,
    this.pausedAtSeconds,
  });

  WorkoutState copyWith({
    WorkoutConfig? config,
    TimerState? timerState,
    int? currentSetIndex,
    int? remainingSeconds,
    DateTime? startTime,
    int? pausedAtSeconds,
    bool clearStartTime = false,
    bool clearPausedAt = false,
  }) {
    return WorkoutState(
      config: config ?? this.config,
      timerState: timerState ?? this.timerState,
      currentSetIndex: currentSetIndex ?? this.currentSetIndex,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      startTime: clearStartTime ? null : (startTime ?? this.startTime),
      pausedAtSeconds: clearPausedAt ? null : (pausedAtSeconds ?? this.pausedAtSeconds),
    );
  }

  int getElapsedSeconds() {
    if (startTime == null) return 0;
    return DateTime.now().difference(startTime!).inSeconds;
  }

  Map<String, dynamic> toJson() {
    return {
      'config': config.toJson(),
      'timerState': timerState.name,
      'currentSetIndex': currentSetIndex,
      'remainingSeconds': remainingSeconds,
      'startTime': startTime?.toIso8601String(),
      'pausedAtSeconds': pausedAtSeconds,
    };
  }

  factory WorkoutState.fromJson(Map<String, dynamic> json) {
    return WorkoutState(
      config: WorkoutConfig.fromJson(json['config']),
      timerState: TimerState.values.firstWhere((e) => e.name == json['timerState']),
      currentSetIndex: json['currentSetIndex'] as int,
      remainingSeconds: json['remainingSeconds'] as int,
      startTime: json['startTime'] != null ? DateTime.parse(json['startTime']) : null,
      pausedAtSeconds: json['pausedAtSeconds'] as int?,
    );
  }
}

class WorkoutNotifier extends Notifier<WorkoutState> {
  Timer? _timer;
  final _audioService = AudioService();

  @override
  WorkoutState build() {
    ref.onDispose(() {
      _timer?.cancel();
    });

    // Load saved state
    _loadState();

    return WorkoutState(
      config: WorkoutConfig(mode: WorkoutMode.fixed, sets: []),
      timerState: TimerState.idle,
      currentSetIndex: 0,
      remainingSeconds: 0,
    );
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    final stateJson = prefs.getString('workout_state');
    if (stateJson != null) {
      try {
        state = WorkoutState.fromJson(jsonDecode(stateJson));
        // Resume timer if it was running (continues in background)
        if (state.timerState == TimerState.work || state.timerState == TimerState.rest) {
          _startTimer();
        }
      } catch (e) {
        // Invalid state, ignore
      }
    }
  }

  Future<void> _saveState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('workout_state', jsonEncode(state.toJson()));
  }

  void setConfig(WorkoutConfig config) {
    state = WorkoutState(
      config: config,
      timerState: TimerState.idle,
      currentSetIndex: 0,
      remainingSeconds: config.sets.isNotEmpty ? config.sets[0].workDurationSeconds : 0,
    );
    _saveState();
  }

  void start() {
    if (state.config.sets.isEmpty) return;

    if (state.timerState == TimerState.idle) {
      state = state.copyWith(
        timerState: TimerState.work,
        currentSetIndex: 0,
        remainingSeconds: state.config.sets[0].workDurationSeconds,
        startTime: DateTime.now(),
        clearPausedAt: true,
      );
    } else if (state.timerState == TimerState.paused) {
      state = state.copyWith(
        timerState: state.pausedAtSeconds != null && state.currentSetIndex < state.config.sets.length
            ? (state.pausedAtSeconds! <= state.config.sets[state.currentSetIndex].workDurationSeconds
                ? TimerState.work
                : TimerState.rest)
            : TimerState.work,
        clearPausedAt: true,
      );
    }

    _startTimer();
    _saveState();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.remainingSeconds > 0) {
        state = state.copyWith(remainingSeconds: state.remainingSeconds - 1);
        _saveState();
      } else {
        _onTimerComplete();
      }
    });
  }

  void _onTimerComplete() {
    if (state.timerState == TimerState.work) {
      // Reproducir sonido al terminar work time
      _audioService.playWorkEndSound();
      
      // Check if this is the last set
      if (state.currentSetIndex == state.config.sets.length - 1) {
        // Last set finished, workout complete
        _timer?.cancel();
        _audioService.playWorkoutCompleteSound();
        state = state.copyWith(timerState: TimerState.finished);
        _saveState();
      } else {
        // Switch to rest (not the last set)
        state = state.copyWith(
          timerState: TimerState.rest,
          remainingSeconds: state.config.sets[state.currentSetIndex].restDurationSeconds,
        );
        _saveState();
      }
    } else if (state.timerState == TimerState.rest) {
      // Reproducir sonido al terminar rest time
      _audioService.playRestEndSound();
      
      // Move to next set
      if (state.currentSetIndex < state.config.sets.length - 1) {
        state = state.copyWith(
          timerState: TimerState.work,
          currentSetIndex: state.currentSetIndex + 1,
          remainingSeconds: state.config.sets[state.currentSetIndex + 1].workDurationSeconds,
        );
        _saveState();
      } else {
        // Workout finished
        _timer?.cancel();
        _audioService.playWorkoutCompleteSound();
        state = state.copyWith(timerState: TimerState.finished);
        _saveState();
      }
    }
  }

  void pause() {
    _timer?.cancel();
    state = state.copyWith(
      timerState: TimerState.paused,
      pausedAtSeconds: state.remainingSeconds,
    );
    _saveState();
  }

  void reset() {
    _timer?.cancel();
    state = WorkoutState(
      config: state.config,
      timerState: TimerState.idle,
      currentSetIndex: 0,
      remainingSeconds: state.config.sets.isNotEmpty ? state.config.sets[0].workDurationSeconds : 0,
    );
    _saveState();
  }

  void clearConfig() {
    _timer?.cancel();
    // Clear workout state but keep SharedPreferences config intact
    state = WorkoutState(
      config: WorkoutConfig(mode: WorkoutMode.fixed, sets: []),
      timerState: TimerState.idle,
      currentSetIndex: 0,
      remainingSeconds: 0,
    );
    // Clear only the workout_state from SharedPreferences, not the config
    SharedPreferences.getInstance().then((prefs) {
      prefs.remove('workout_state');
    });
  }

  void updateRestTime(int minutes, int seconds) {
    if (state.currentSetIndex >= state.config.sets.length) return;

    final updatedSets = List<WorkoutSet>.from(state.config.sets);
    updatedSets[state.currentSetIndex] = updatedSets[state.currentSetIndex].copyWith(
      restMinutes: minutes,
      restSeconds: seconds,
    );

    state = state.copyWith(
      config: state.config.copyWith(sets: updatedSets),
      remainingSeconds: state.timerState == TimerState.rest ? (minutes * 60 + seconds) : state.remainingSeconds,
    );
    _saveState();
  }

  void updateWorkTime(int minutes, int seconds) {
    if (state.currentSetIndex >= state.config.sets.length) return;

    final updatedSets = List<WorkoutSet>.from(state.config.sets);
    updatedSets[state.currentSetIndex] = updatedSets[state.currentSetIndex].copyWith(
      workMinutes: minutes,
      workSeconds: seconds,
    );

    state = state.copyWith(
      config: state.config.copyWith(sets: updatedSets),
      remainingSeconds: state.timerState == TimerState.work ? (minutes * 60 + seconds) : state.remainingSeconds,
    );
    _saveState();
  }
}

final workoutProvider = NotifierProvider<WorkoutNotifier, WorkoutState>(() {
  return WorkoutNotifier();
});
