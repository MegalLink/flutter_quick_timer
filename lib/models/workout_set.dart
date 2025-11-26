class WorkoutSet {
  final int workMinutes;
  final int workSeconds;
  final int restMinutes;
  final int restSeconds;

  WorkoutSet({
    required this.workMinutes,
    required this.workSeconds,
    required this.restMinutes,
    required this.restSeconds,
  });

  int get workDurationSeconds => workMinutes * 60 + workSeconds;
  int get restDurationSeconds => restMinutes * 60 + restSeconds;

  WorkoutSet copyWith({
    int? workMinutes,
    int? workSeconds,
    int? restMinutes,
    int? restSeconds,
  }) {
    return WorkoutSet(
      workMinutes: workMinutes ?? this.workMinutes,
      workSeconds: workSeconds ?? this.workSeconds,
      restMinutes: restMinutes ?? this.restMinutes,
      restSeconds: restSeconds ?? this.restSeconds,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'workMinutes': workMinutes,
      'workSeconds': workSeconds,
      'restMinutes': restMinutes,
      'restSeconds': restSeconds,
    };
  }

  factory WorkoutSet.fromJson(Map<String, dynamic> json) {
    return WorkoutSet(
      workMinutes: json['workMinutes'] as int,
      workSeconds: json['workSeconds'] as int,
      restMinutes: json['restMinutes'] as int,
      restSeconds: json['restSeconds'] as int,
    );
  }
}
