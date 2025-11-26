import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/workout_mode.dart';
import '../providers/workout_provider.dart';
import '../widgets/time_picker_dialog.dart';

class TimerScreen extends ConsumerStatefulWidget {
  const TimerScreen({super.key});

  @override
  ConsumerState<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends ConsumerState<TimerScreen> {
  final _restMinController = TextEditingController();
  final _restSecController = TextEditingController();
  bool _showRestTimeEdit = false;

  @override
  void dispose() {
    _restMinController.dispose();
    _restSecController.dispose();
    super.dispose();
  }

  LinearGradient _getBackgroundGradient(TimerState state) {
    switch (state) {
      case TimerState.work:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFF6B6B), Color(0xFFEE5A6F), Color(0xFFD84A5C)],
        );
      case TimerState.rest:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4ECDC4), Color(0xFF45B8AC), Color(0xFF3BA89D)],
        );
      case TimerState.paused:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFA07A), Color(0xFFFF8C5A), Color(0xFFFF7847)],
        );
      case TimerState.finished:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF5B6FD8), Color(0xFF7B5FC6), Color(0xFF8E4FB5)],
        );
      case TimerState.idle:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF5B6FD8), Color(0xFF7B5FC6), Color(0xFF8E4FB5)],
        );
    }
  }

  String _getStateText(TimerState state) {
    switch (state) {
      case TimerState.work:
        return 'TRABAJO';
      case TimerState.rest:
        return 'DESCANSO';
      case TimerState.paused:
        return 'PAUSADO';
      case TimerState.finished:
        return '¡ENTRENAMIENTO TERMINADO!';
      case TimerState.idle:
        return 'LISTO';
    }
  }

  String _formatTime(int seconds) {
    final min = seconds ~/ 60;
    final sec = seconds % 60;
    return '${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }

  double _getProgressValue(WorkoutState state) {
    if (state.currentSetIndex >= state.config.sets.length) return 1.0;
    
    final currentSet = state.config.sets[state.currentSetIndex];
    if (state.timerState == TimerState.work) {
      final totalSeconds = currentSet.workDurationSeconds;
      if (totalSeconds == 0) return 0.0;
      return 1.0 - (state.remainingSeconds / totalSeconds);
    } else if (state.timerState == TimerState.rest) {
      final totalSeconds = currentSet.restDurationSeconds;
      if (totalSeconds == 0) return 0.0;
      return 1.0 - (state.remainingSeconds / totalSeconds);
    }
    return 0.0;
  }

  int _getTotalDuration() {
    final state = ref.read(workoutProvider);
    return state.config.getTotalDurationSeconds();
  }

  int _getElapsedDuration() {
    final state = ref.read(workoutProvider);
    int elapsed = 0;
    
    // Si el entrenamiento terminó, mostrar el tiempo total de trabajo
    if (state.timerState == TimerState.finished) {
      return _getTotalDuration();
    }
    
    // Add completed sets (only work time)
    for (int i = 0; i < state.currentSetIndex; i++) {
      elapsed += state.config.sets[i].workDurationSeconds;
    }
    
    // Add current set progress (only work time)
    if (state.currentSetIndex < state.config.sets.length) {
      final currentSet = state.config.sets[state.currentSetIndex];
      if (state.timerState == TimerState.work) {
        elapsed += currentSet.workDurationSeconds - state.remainingSeconds;
      } else if (state.timerState == TimerState.rest) {
        elapsed += currentSet.workDurationSeconds;
      }
    }
    
    return elapsed;
  }

  void _toggleRestTimeEdit() async {
    final state = ref.read(workoutProvider);
    if (state.timerState == TimerState.rest && state.currentSetIndex < state.config.sets.length) {
      final currentSet = state.config.sets[state.currentSetIndex];
      
      final result = await CustomTimePickerDialog.show(
        context: context,
        initialMinutes: currentSet.restMinutes,
        initialSeconds: currentSet.restSeconds,
        title: 'Ajustar Tiempo de Descanso',
      );
      
      if (result != null) {
        ref.read(workoutProvider.notifier).updateRestTime(
          result['minutes']!,
          result['seconds']!,
        );
      }
    }
  }

  void _toggleWorkTimeEdit() async {
    final state = ref.read(workoutProvider);
    if (state.timerState == TimerState.work && state.currentSetIndex < state.config.sets.length) {
      final currentSet = state.config.sets[state.currentSetIndex];
      
      final result = await CustomTimePickerDialog.show(
        context: context,
        initialMinutes: currentSet.workMinutes,
        initialSeconds: currentSet.workSeconds,
        title: 'Ajustar Tiempo de Trabajo',
      );
      
      if (result != null) {
        ref.read(workoutProvider.notifier).updateWorkTime(
          result['minutes']!,
          result['seconds']!,
        );
      }
    }
  }

  void _updateRestTime() {
    final minutes = int.tryParse(_restMinController.text) ?? 0;
    final seconds = int.tryParse(_restSecController.text) ?? 0;
    ref.read(workoutProvider.notifier).updateRestTime(minutes, seconds);
    setState(() {
      _showRestTimeEdit = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final workoutState = ref.watch(workoutProvider);
    final bgGradient = _getBackgroundGradient(workoutState.timerState);
    final textColor = Colors.white;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: bgGradient),
        child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Header
              Column(
                children: [
                  Text(
                    _getStateText(workoutState.timerState),
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (workoutState.timerState != TimerState.finished)
                    Text(
                      'Set ${workoutState.currentSetIndex + 1} de ${workoutState.config.totalSets}',
                      style: TextStyle(
                        fontSize: 20,
                        color: textColor.withValues(alpha: 0.8),
                      ),
                    ),
                ],
              ),

              // Circular Progress Timer
              GestureDetector(
                onTap: workoutState.timerState == TimerState.rest 
                    ? _toggleRestTimeEdit 
                    : workoutState.timerState == TimerState.work 
                    ? _toggleWorkTimeEdit 
                    : null,
                child: Center(
                  child: SizedBox(
                    width: 280,
                    height: 280,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Background circle
                        Container(
                          width: 280,
                          height: 280,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.1),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.2),
                              width: 2,
                            ),
                          ),
                        ),
                        // Progress circle
                        SizedBox(
                          width: 280,
                          height: 280,
                          child: CircularProgressIndicator(
                            value: _getProgressValue(workoutState),
                            strokeWidth: 12,
                            backgroundColor: Colors.transparent,
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                            strokeCap: StrokeCap.round,
                          ),
                        ),
                        // Time text
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (workoutState.timerState != TimerState.finished)
                              Text(
                                _formatTime(workoutState.remainingSeconds),
                                style: TextStyle(
                                  fontSize: 72,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                  fontFeatures: const [FontFeature.tabularFigures()],
                                  height: 1,
                                ),
                              ),
                            if (workoutState.timerState == TimerState.finished)
                              Text(
                                '00:00',
                                style: TextStyle(
                                  fontSize: 72,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                  fontFeatures: const [FontFeature.tabularFigures()],
                                  height: 1,
                                ),
                              ),
                            const SizedBox(height: 8),
                            Text(
                              _getStateText(workoutState.timerState),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: workoutState.timerState == TimerState.finished ? 14 : 16,
                                fontWeight: FontWeight.w600,
                                color: textColor.withValues(alpha: 0.8),
                                letterSpacing: 2,
                              ),
                            ),
                            if (workoutState.timerState == TimerState.rest)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.touch_app, size: 14, color: textColor.withValues(alpha: 0.6)),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Toca para ajustar',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: textColor.withValues(alpha: 0.6),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            if (workoutState.timerState == TimerState.work)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.touch_app, size: 14, color: textColor.withValues(alpha: 0.6)),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Toca para ajustar',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: textColor.withValues(alpha: 0.6),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Rest time edit fields
              if (_showRestTimeEdit)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0.2),
                        Colors.white.withValues(alpha: 0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 80,
                            child: TextField(
                              controller: _restMinController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              style: TextStyle(fontSize: 18, color: textColor),
                              decoration: InputDecoration(
                                labelText: 'Min',
                                labelStyle: TextStyle(color: textColor),
                                filled: true,
                                fillColor: Colors.white.withValues(alpha: 0.3),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          SizedBox(
                            width: 80,
                            child: TextField(
                              controller: _restSecController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              style: TextStyle(fontSize: 18, color: textColor),
                              decoration: InputDecoration(
                                labelText: 'Seg',
                                labelStyle: TextStyle(color: textColor),
                                filled: true,
                                fillColor: Colors.white.withValues(alpha: 0.3),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                            onPressed: () => setState(() => _showRestTimeEdit = false),
                            child: Text('Cancelar', style: TextStyle(color: textColor)),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton(
                            onPressed: _updateRestTime,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                            ),
                            child: const Text('Aplicar'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

              // Total time display
              Column(
                children: [
                  Text(
                    'Tiempo Total',
                    style: TextStyle(
                      fontSize: 16,
                      color: textColor.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_formatTime(_getElapsedDuration())} / ${_formatTime(_getTotalDuration())}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ],
              ),

              // Control Buttons
              if (workoutState.timerState != TimerState.finished)
                if (workoutState.timerState == TimerState.idle)
                  // Show Start and Back buttons when idle
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 150,
                        child: _buildControlButton(
                          icon: Icons.arrow_back,
                          label: 'Atrás',
                          onPressed: () {
                            ref.read(workoutProvider.notifier).clearConfig();
                          },
                          color: textColor,
                          isPrimary: true,
                        ),
                      ),
                      const SizedBox(width: 16),
                      SizedBox(
                        width: 150,
                        child: _buildControlButton(
                          icon: Icons.play_arrow,
                          label: 'Iniciar',
                          onPressed: () {
                            ref.read(workoutProvider.notifier).start();
                          },
                          color: textColor,
                          isPrimary: true,
                        ),
                      ),
                    ],
                  )
                else
                  // Show Reset and Play/Pause when running
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Reset button
                      SizedBox(
                        width: 150,
                        child: _buildControlButton(
                          icon: Icons.refresh,
                          label: 'Reiniciar',
                          onPressed: () {
                            ref.read(workoutProvider.notifier).reset();
                          },
                          color: textColor,
                        ),
                      ),
                      const SizedBox(width: 16),
                      
                      // Start/Pause button
                      if (workoutState.timerState == TimerState.paused)
                        SizedBox(
                          width: 150,
                          child: _buildControlButton(
                            icon: Icons.play_arrow,
                            label: 'Continuar',
                            onPressed: () {
                              ref.read(workoutProvider.notifier).start();
                            },
                            color: textColor,
                            isPrimary: true,
                          ),
                        )
                      else
                        SizedBox(
                          width: 150,
                          child: _buildControlButton(
                            icon: Icons.pause,
                            label: 'Pausa',
                            onPressed: () {
                              ref.read(workoutProvider.notifier).pause();
                            },
                            color: textColor,
                            isPrimary: true,
                          ),
                        ),
                    ],
                  )
              else
                _buildControlButton(
                  icon: Icons.home,
                  label: 'Finalizar',
                  onPressed: () {
                    ref.read(workoutProvider.notifier).reset();
                  },
                  color: textColor,
                  isPrimary: true,
                ),
            ],
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color color,
    bool isPrimary = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: isPrimary
            ? const LinearGradient(
                colors: [Color(0xFFFFFFFF), Color(0xFFF0F0F0)],
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: isPrimary ? Colors.white.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? Colors.transparent : Colors.white.withValues(alpha: 0.15),
          foregroundColor: isPrimary ? const Color(0xFF6C63FF) : Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: isPrimary ? BorderSide.none : BorderSide(color: Colors.white.withValues(alpha: 0.3), width: 2),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
