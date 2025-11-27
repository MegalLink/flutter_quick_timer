import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/workout_config.dart';
import '../models/workout_mode.dart';
import '../models/workout_set.dart';
import '../providers/workout_provider.dart';
import '../widgets/config/fixed_mode_tab.dart';
import '../widgets/config/variable_mode_tab.dart';

class ConfigScreen extends ConsumerStatefulWidget {
  const ConfigScreen({super.key});

  @override
  ConsumerState<ConfigScreen> createState() => _ConfigScreenState();
}

class _ConfigScreenState extends ConsumerState<ConfigScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Fixed mode controllers
  final _setsController = TextEditingController(text: '3');
  final _workMinController = TextEditingController(text: '1');
  final _workSecController = TextEditingController(text: '00');
  final _restMinController = TextEditingController(text: '1');
  final _restSecController = TextEditingController(text: '00');

  // Variable mode
  final List<WorkoutSet> _customSets = [];
  final Map<String, List<WorkoutSet>> _savedCustomSets = {};
  String? _selectedCustomSetName;
  bool _isEditingMode = false;
  String? _editingSetName;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.index == 1 && !_tabController.indexIsChanging) {
        // When on Variables tab, ensure clean state
        setState(() {
          _customSets.clear();
          _isEditingMode = false;
          _editingSetName = null;
          _selectedCustomSetName = null;
        });
      }
    });
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load fixed mode config
    setState(() {
      _setsController.text = prefs.getString('fixed_sets') ?? '3';
      _workMinController.text = prefs.getString('fixed_work_min') ?? '1';
      _workSecController.text = prefs.getString('fixed_work_sec') ?? '00';
      _restMinController.text = prefs.getString('fixed_rest_min') ?? '1';
      _restSecController.text = prefs.getString('fixed_rest_sec') ?? '00';
    });

    // Load saved custom sets
    final savedSetsJson = prefs.getString('saved_custom_sets');
    if (savedSetsJson != null) {
      final Map<String, dynamic> decoded = jsonDecode(savedSetsJson);
      setState(() {
        _savedCustomSets.clear();
        decoded.forEach((key, value) {
          _savedCustomSets[key] = (value as List)
              .map((s) => WorkoutSet.fromJson(s))
              .toList();
        });
      });
    }
  }

  Future<void> _saveFixedConfig() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('fixed_sets', _setsController.text);
    await prefs.setString('fixed_work_min', _workMinController.text);
    await prefs.setString('fixed_work_sec', _workSecController.text);
    await prefs.setString('fixed_rest_min', _restMinController.text);
    await prefs.setString('fixed_rest_sec', _restSecController.text);
  }

  Future<void> _saveCustomSets() async {
    final prefs = await SharedPreferences.getInstance();
    final Map<String, dynamic> toSave = {};
    _savedCustomSets.forEach((key, value) {
      toSave[key] = value.map((s) => s.toJson()).toList();
    });
    await prefs.setString('saved_custom_sets', jsonEncode(toSave));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _setsController.dispose();
    _workMinController.dispose();
    _workSecController.dispose();
    _restMinController.dispose();
    _restSecController.dispose();
    super.dispose();
  }

  void _startWorkout() {
    List<WorkoutSet> sets = [];

    if (_tabController.index == 0) {
      // Fixed mode
      _saveFixedConfig();
      final numSets = int.tryParse(_setsController.text) ?? 1;
      final workMin = int.tryParse(_workMinController.text) ?? 1;
      final workSec = int.tryParse(_workSecController.text) ?? 0;
      final restMin = int.tryParse(_restMinController.text) ?? 1;
      final restSec = int.tryParse(_restSecController.text) ?? 0;
  
      for (int i = 0; i < numSets; i++) {
        sets.add(WorkoutSet(
          workMinutes: workMin,
          workSeconds: workSec,
          restMinutes: restMin,
          restSeconds: restSec,
        ));
      }
    } else {
      sets = List.from(_customSets);
    }

    if (sets.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Agrega al menos un set')),
      );
      return;
    }

    final mode = _tabController.index == 0 ? WorkoutMode.fixed : WorkoutMode.variable;
    final config = WorkoutConfig(mode: mode, sets: sets);
    ref.read(workoutProvider.notifier).setConfig(config);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Configurar Entrenamiento', 
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4A90E2), Color(0xFF5B6FD8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF4A90E2), // Bright blue
              Color(0xFF5B6FD8), // Medium blue-purple
              Color(0xFF7B5FC6), // Purple
              Color(0xFF9D4EBF), // Deep purple
            ],
            stops: [0.0, 0.4, 0.7, 1.0],
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 120), // Space for app bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0.3),
                        Colors.white.withValues(alpha: 0.2),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.4),
                      width: 1.5,
                    ),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white70,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  tabs: const [
                    Tab(text: 'Sets Fijos'),
                    Tab(text: 'Sets Variables'),
                  ],
                  onTap: (index) {
                    if (index == 1) {
                      // When switching to Variables tab, reset to new set creation mode
                      setState(() {
                        _customSets.clear();
                        _isEditingMode = false;
                        _editingSetName = null;
                        _selectedCustomSetName = null;
                      });
                    }
                    setState(() {});
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                    FixedModeTab(
                      setsController: _setsController,
                      workMinController: _workMinController,
                      workSecController: _workSecController,
                      restMinController: _restMinController,
                      restSecController: _restSecController,
                      onStartWorkout: _startWorkout,
                    ),
                    VariableModeTab(
                      customSets: _customSets,
                      savedCustomSets: _savedCustomSets,
                      selectedCustomSetName: _selectedCustomSetName,
                      isEditingMode: _isEditingMode,
                      editingSetName: _editingSetName,
                      onCustomSetSelected: (value) {
                        if (value == '__nuevo__') {
                          setState(() {
                            _customSets.clear();
                            _isEditingMode = false;
                            _selectedCustomSetName = '__nuevo__';
                          });
                        } else if (value != null) {
                          setState(() {
                            _customSets.clear();
                            _customSets.addAll(_savedCustomSets[value]!);
                            _isEditingMode = true;
                            _editingSetName = value;
                            _selectedCustomSetName = value;
                          });
                        }
                      },
                      onUpdateCustomSet: _updateCustomSet,
                      onDeleteCustomSet: (index) {
                        setState(() {
                          _customSets.removeAt(index);
                        });
                      },
                      onAddCustomSet: _addCustomSet,
                      onUpdateExistingSet: _updateExistingSet,
                      onDeleteSavedSet: () => _deleteSavedSet(_editingSetName!),
                      onSaveCustomSet: _showSaveCustomSetDialog,
                      onStartWorkout: _startWorkout,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 80),
                child: Container(
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
                    onPressed: _startWorkout,
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
                ),
              ),
            ],
          ),
      ),
    );
  }

  void _addCustomSet() {
    setState(() {
      _customSets.add(WorkoutSet(
        workMinutes: 0,
        workSeconds: 30,
        restMinutes: 0,
        restSeconds: 15,
      ));
    });
  }

  void _updateCustomSet(int index, {int? workMin, int? workSec, int? restMin, int? restSec}) {
    setState(() {
      _customSets[index] = _customSets[index].copyWith(
        workMinutes: workMin,
        workSeconds: workSec,
        restMinutes: restMin,
        restSeconds: restSec,
      );
    });
  }

  Future<void> _updateExistingSet() async {
    if (_editingSetName == null) return;
    
    setState(() {
      _savedCustomSets[_editingSetName!] = List.from(_customSets);
      _selectedCustomSetName = _editingSetName;
      _isEditingMode = true;
      // _editingSetName se mantiene
    });
    
    await _saveCustomSets();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Set actualizado correctamente'),
          duration: Duration(seconds: 2),
          backgroundColor: Color(0xFF7B5FC6),
        ),
      );
    }
  }

  Future<void> _deleteSavedSet(String setName) async {
    // Mostrar modal de confirmación
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF7B5FC6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Eliminar Set',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          '¿Estás seguro de que deseas eliminar "$setName"?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // Eliminar el set guardado
    _savedCustomSets.remove(setName);
    await _saveCustomSets();
    
    setState(() {
      // Limpiar estado como si fuera a crear uno nuevo
      _selectedCustomSetName = null;
      _customSets.clear();
      _isEditingMode = false;
      _editingSetName = null;
    });
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Set eliminado correctamente'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> _showSaveCustomSetDialog() async {
    final nameController = TextEditingController();
    
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF7B5FC6),
        title: const Text(
          'Guardar Sets Personalizados',
          style: TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: nameController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Nombre',
            labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.5)),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                Navigator.pop(context, true);
              }
            },
            child: const Text('Guardar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (result == true && nameController.text.trim().isNotEmpty) {
      setState(() {
        _savedCustomSets[nameController.text.trim()] = List.from(_customSets);
        _selectedCustomSetName = nameController.text.trim();
      });
      await _saveCustomSets();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sets guardados como "${nameController.text.trim()}"'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }
}
