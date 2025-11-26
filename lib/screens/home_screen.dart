import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/workout_provider.dart';
import 'config_screen.dart';
import 'timer_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workoutState = ref.watch(workoutProvider);

    // Show timer screen if workout has sets configured (even if idle/ready to start)
    if (workoutState.config.sets.isNotEmpty) {
      return const TimerScreen();
    }

    // Show configuration screen
    return const ConfigScreen();
  }
}
