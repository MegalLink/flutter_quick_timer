import 'package:flutter/material.dart';
import '../time_picker_dialog.dart';

class FixedModeTab extends StatelessWidget {
  final TextEditingController setsController;
  final TextEditingController workMinController;
  final TextEditingController workSecController;
  final TextEditingController restMinController;
  final TextEditingController restSecController;
  final VoidCallback onStartWorkout;

  const FixedModeTab({
    super.key,
    required this.setsController,
    required this.workMinController,
    required this.workSecController,
    required this.restMinController,
    required this.restSecController,
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
            buildSetsInput(),
            const SizedBox(height: 16),
            buildTimeSection(
              context: context,
              title: 'Tiempo de Trabajo',
              minController: workMinController,
              secController: workSecController,
            ),
            const SizedBox(height: 16),
            buildTimeSection(
              context: context,
              title: 'Tiempo de Descanso',
              minController: restMinController,
              secController: restSecController,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSetsInput() {
    return Builder(
      builder: (context) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Número de Sets',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () async {
                final currentValue = setsController.text.isNotEmpty 
                  ? int.tryParse(setsController.text) ?? 1 
                  : 1;
                
                final result = await _showNumberPickerDialog(
                  context,
                  initialValue: currentValue,
                );
                
                if (result != null) {
                  setsController.text = result.toString();
                }
              },
          child: ValueListenableBuilder(
            valueListenable: setsController,
            builder: (context, value, _) {
              return Container(
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
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      (int.tryParse(value.text) ?? 0).toString().padLeft(2, '0'),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
      },
    );
  }

  Future<int?> _showNumberPickerDialog(BuildContext context, {required int initialValue}) async {
    int selectedValue = initialValue.clamp(1, 99);
    
    return showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            int tens = selectedValue ~/ 10;
            int ones = selectedValue % 10;
            
            return Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF5B6FD8),
                      Color(0xFF7B5FC6),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Número de Sets',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Decenas
                          Expanded(
                            child: _buildNumberPicker(
                              value: tens,
                              minValue: 0,
                              maxValue: 9,
                              label: 'Decenas',
                              onChanged: (value) {
                                setState(() {
                                  selectedValue = value * 10 + ones;
                                  if (selectedValue == 0) selectedValue = 1;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Unidades
                          Expanded(
                            child: _buildNumberPicker(
                              value: ones,
                              minValue: 0,
                              maxValue: 9,
                              label: 'Unidades',
                              onChanged: (value) {
                                setState(() {
                                  selectedValue = tens * 10 + value;
                                  if (selectedValue == 0) selectedValue = 1;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.3),
                                width: 1.5,
                              ),
                            ),
                            child: TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text(
                                'Cancelar',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.5),
                                width: 1.5,
                              ),
                            ),
                            child: TextButton(
                              onPressed: () => Navigator.of(context).pop(selectedValue),
                              child: const Text(
                                'Confirmar',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildNumberPicker({
    required int value,
    required int minValue,
    required int maxValue,
    required String label,
    required Function(int) onChanged,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white70,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListWheelScrollView.useDelegate(
            itemExtent: 50,
            diameterRatio: 1.5,
            physics: const FixedExtentScrollPhysics(),
            controller: FixedExtentScrollController(initialItem: value - minValue),
            onSelectedItemChanged: (index) {
              onChanged(minValue + index);
            },
            childDelegate: ListWheelChildBuilderDelegate(
              childCount: maxValue - minValue + 1,
              builder: (context, index) {
                final number = minValue + index;
                final isSelected = number == value;
                return Center(
                  child: Text(
                    number.toString(),
                    style: TextStyle(
                      fontSize: isSelected ? 32 : 24,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget buildTimeSection({
    required BuildContext context,
    required String title,
    required TextEditingController minController,
    required TextEditingController secController,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            final result = await CustomTimePickerDialog.show(
              context: context,
              initialMinutes: int.tryParse(minController.text) ?? 0,
              initialSeconds: int.tryParse(secController.text) ?? 0,
              title: title,
            );

            if (result != null) {
              minController.text = result['minutes'].toString();
              secController.text = result['seconds'].toString();
            }
          },
          child: ValueListenableBuilder(
            valueListenable: minController,
            builder: (context, minValue, _) {
              return ValueListenableBuilder(
                valueListenable: secController,
                builder: (context, secValue, _) {
                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${(int.tryParse(minValue.text) ?? 0).toString().padLeft(2, '0')}:${(int.tryParse(secValue.text) ?? 0).toString().padLeft(2, '0')}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.access_time,
                          color: Colors.white.withValues(alpha: 0.7),
                          size: 20,
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget buildStartButton(BuildContext context) {
    return Container(
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
        onPressed: onStartWorkout,
        icon: const Icon(Icons.play_arrow, size: 24),
        label: const Text(
          'COMENZAR ENTRENAMIENTO',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: const Color(0xFF6C63FF),
          side: BorderSide.none,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }
}
