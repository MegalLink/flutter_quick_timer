import 'package:flutter/material.dart';
import '../../models/workout_set.dart';
import 'custom_set_card.dart';

class VariableModeTab extends StatelessWidget {
  final List<WorkoutSet> customSets;
  final Map<String, List<WorkoutSet>> savedCustomSets;
  final String? selectedCustomSetName;
  final bool isEditingMode;
  final String? editingSetName;
  final Function(String?) onCustomSetSelected;
  final Function(int, {int? workMin, int? workSec, int? restMin, int? restSec}) onUpdateCustomSet;
  final Function(int) onDeleteCustomSet;
  final VoidCallback onAddCustomSet;
  final VoidCallback onUpdateExistingSet;
  final VoidCallback onDeleteSavedSet;
  final VoidCallback onSaveCustomSet;
  final VoidCallback onStartWorkout;

  const VariableModeTab({
    super.key,
    required this.customSets,
    required this.savedCustomSets,
    required this.selectedCustomSetName,
    required this.isEditingMode,
    required this.editingSetName,
    required this.onCustomSetSelected,
    required this.onUpdateCustomSet,
    required this.onDeleteCustomSet,
    required this.onAddCustomSet,
    required this.onUpdateExistingSet,
    required this.onDeleteSavedSet,
    required this.onSaveCustomSet,
    required this.onStartWorkout,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sets Personalizados',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            
            // Dropdown para seleccionar set guardado
            if (savedCustomSets.isNotEmpty) ...[
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.1),
                      Colors.white.withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                ),
                child: DropdownButtonFormField<String>(
                  initialValue: selectedCustomSetName,
                  dropdownColor: const Color(0xFF6C63FF),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  hint: const Text(
                    'Selecciona un set guardado',
                    style: TextStyle(color: Colors.white70),
                  ),
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  items: [
                    const DropdownMenuItem<String>(
                      value: '__nuevo__',
                      child: Row(
                        children: [
                          Icon(Icons.add_circle_outline, color: Colors.white, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Nuevo Set',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    ...savedCustomSets.keys.map((name) {
                      return DropdownMenuItem<String>(
                        value: name,
                        child: Text(name),
                      );
                    }),
                  ],
                  onChanged: onCustomSetSelected,
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Lista de sets personalizados
            if (customSets.isNotEmpty) ...[
              ...customSets.asMap().entries.map((entry) {
                return CustomSetCard(
                  index: entry.key,
                  set: entry.value,
                  onUpdate: onUpdateCustomSet,
                  onDelete: () => onDeleteCustomSet(entry.key),
                );
              }),
              const SizedBox(height: 16),
            ],

            // Botones de acción
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    if (isEditingMode && editingSetName != null && editingSetName != '__nuevo__') {
      return _buildEditingModeButtons();
    } else if (customSets.isNotEmpty) {
      return _buildCreationModeButtons();
    } else {
      return _buildEmptyStateButton();
    }
  }

  Widget _buildEditingModeButtons() {
    return Column(
      children: [
        // Row con botones de acción secundarios
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onAddCustomSet,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Añadir'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.3), width: 1),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onUpdateExistingSet,
                icon: const Icon(Icons.save_outlined, size: 18),
                label: const Text('Guardar'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.3), width: 1),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Botón de eliminar minimalista
            OutlinedButton(
              onPressed: onDeleteSavedSet,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.redAccent,
                side: BorderSide(color: Colors.redAccent.withValues(alpha: 0.3), width: 1),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                minimumSize: const Size(0, 0),
              ),
              child: const Icon(Icons.delete_outline, size: 20),
            ),
          ],
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
                  onPressed: onAddCustomSet,
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
                  onPressed: onSaveCustomSet,
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
        onPressed: onAddCustomSet,
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
