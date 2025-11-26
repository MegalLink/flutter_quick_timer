import 'package:flutter/material.dart';

class CustomSetActionButtons extends StatelessWidget {
  final bool isEditingMode;
  final String? editingSetName;
  final bool hasSavedSets;
  final bool hasCustomSets;
  final VoidCallback onAddSet;
  final VoidCallback onUpdateSet;
  final VoidCallback onDeleteSet;
  final VoidCallback onSaveSet;
  final VoidCallback onStartWorkout;

  const CustomSetActionButtons({
    super.key,
    required this.isEditingMode,
    required this.editingSetName,
    required this.hasSavedSets,
    required this.hasCustomSets,
    required this.onAddSet,
    required this.onUpdateSet,
    required this.onDeleteSet,
    required this.onSaveSet,
    required this.onStartWorkout,
  });

  @override
  Widget build(BuildContext context) {
    if (isEditingMode && editingSetName != null && editingSetName != '__nuevo__' && hasSavedSets) {
      return _buildEditingModeButtons();
    } else if (hasCustomSets) {
      return _buildCreationModeButtons();
    } else {
      return _buildEmptyStateButton();
    }
  }

  Widget _buildEditingModeButtons() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white.withValues(alpha: 0.15),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: OutlinedButton.icon(
            onPressed: onAddSet,
            icon: const Icon(Icons.add),
            label: const Text('Añadir Set'),
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.white,
              side: BorderSide.none,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              colors: [Color(0xFFFFFFFF), Color(0xFFF0F0F0)],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: OutlinedButton.icon(
            onPressed: onUpdateSet,
            icon: const Icon(Icons.check),
            label: const Text('Actualizar Custom Set'),
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: const Color(0xFF6C63FF),
              side: BorderSide.none,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.red.withValues(alpha: 0.2),
            border: Border.all(
              color: Colors.red.withValues(alpha: 0.5),
              width: 1.5,
            ),
          ),
          child: OutlinedButton.icon(
            onPressed: onDeleteSet,
            icon: const Icon(Icons.delete),
            label: const Text('Eliminar Custom Set'),
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.white,
              side: BorderSide.none,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCreationModeButtons() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.white.withValues(alpha: 0.15),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: OutlinedButton.icon(
                  onPressed: onAddSet,
                  icon: const Icon(Icons.add),
                  label: const Text('Añadir Set'),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    side: BorderSide.none,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFFFFF), Color(0xFFF0F0F0)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: OutlinedButton.icon(
                  onPressed: onSaveSet,
                  icon: const Icon(Icons.save),
                  label: const Text('Guardar'),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: const Color(0xFF6C63FF),
                    side: BorderSide.none,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              colors: [Color(0xFFFFFFFF), Color(0xFFF0F0F0)],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: OutlinedButton.icon(
            onPressed: onStartWorkout,
            icon: const Icon(Icons.play_arrow),
            label: const Text('COMENZAR ENTRENAMIENTO'),
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: const Color(0xFF6C63FF),
              side: BorderSide.none,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyStateButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withValues(alpha: 0.15),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: OutlinedButton.icon(
        onPressed: onAddSet,
        icon: const Icon(Icons.add),
        label: const Text('Añadir Set'),
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          side: BorderSide.none,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }
}
