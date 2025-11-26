import 'package:flutter/material.dart';
import '../../models/workout_set.dart';
import '../time_picker_dialog.dart';

class CustomSetCard extends StatelessWidget {
  final int index;
  final WorkoutSet set;
  final Function(int, {int? workMin, int? workSec, int? restMin, int? restSec}) onUpdate;
  final VoidCallback onDelete;

  const CustomSetCard({
    super.key,
    required this.index,
    required this.set,
    required this.onUpdate,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.15),
            Colors.white.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          // Título del Set
          SizedBox(
            width: 60,
            child: Text(
              'Set ${index + 1}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          // Tiempo de Trabajo
          Expanded(
            child: GestureDetector(
              onTap: () async {
                final result = await CustomTimePickerDialog.show(
                  context: context,
                  initialMinutes: set.workMinutes,
                  initialSeconds: set.workSeconds,
                  title: 'Tiempo de Trabajo',
                );

                if (result != null) {
                  onUpdate(
                    index,
                    workMin: result['minutes'],
                    workSec: result['seconds'],
                  );
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.1),
                      Colors.white.withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                ),
                child: Column(
                  children: [
                    Text(
                      'Trabajo',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${set.workMinutes.toString().padLeft(2, '0')}:${set.workSeconds.toString().padLeft(2, '0')}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Tiempo de Descanso
          Expanded(
            child: GestureDetector(
              onTap: () async {
                final result = await CustomTimePickerDialog.show(
                  context: context,
                  initialMinutes: set.restMinutes,
                  initialSeconds: set.restSeconds,
                  title: 'Tiempo de Descanso',
                );

                if (result != null) {
                  onUpdate(
                    index,
                    restMin: result['minutes'],
                    restSec: result['seconds'],
                  );
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.1),
                      Colors.white.withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                ),
                child: Column(
                  children: [
                    Text(
                      'Descanso',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${set.restMinutes.toString().padLeft(2, '0')}:${set.restSeconds.toString().padLeft(2, '0')}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Botón Eliminar
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline),
            color: Colors.redAccent.withValues(alpha: 0.8),
            iconSize: 20,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}
