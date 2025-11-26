import 'dart:convert';
import 'workout_set.dart';
import 'workout_mode.dart';

class WorkoutConfig {
  final WorkoutMode mode;
  final List<WorkoutSet> sets;

  WorkoutConfig({
    required this.mode,
    required this.sets,
  });

  WorkoutConfig copyWith({
    WorkoutMode? mode,
    List<WorkoutSet>? sets,
  }) {
    return WorkoutConfig(
      mode: mode ?? this.mode,
      sets: sets ?? this.sets,
    );
  }

  int get totalSets => sets.length;

  int getTotalDurationSeconds() {
    return sets.fold(0, (sum, set) {
      return sum + set.workDurationSeconds;
    });
  }

  Map<String, dynamic> toJson() {
    return {
      'mode': mode.name,
      'sets': sets.map((s) => s.toJson()).toList(),
    };
  }

  factory WorkoutConfig.fromJson(Map<String, dynamic> json) {
    return WorkoutConfig(
      mode: WorkoutMode.values.firstWhere((e) => e.name == json['mode']),
      sets: (json['sets'] as List)
          .map((s) => WorkoutSet.fromJson(s as Map<String, dynamic>))
          .toList(),
    );
  }

  String toJsonString() => jsonEncode(toJson());

  factory WorkoutConfig.fromJsonString(String jsonString) {
    return WorkoutConfig.fromJson(jsonDecode(jsonString));
  }
}
