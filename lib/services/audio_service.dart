import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _player = AudioPlayer();

  // Reproducir sonido cuando termina el tiempo de trabajo
  Future<void> playWorkEndSound() async {
    try {
      await _player.play(AssetSource('sounds/end_bell.mp3'));
    } catch (e) {
      debugPrint('Error playing work end sound: $e');
    }
  }

  // Reproducir sonido cuando termina el tiempo de descanso
  Future<void> playRestEndSound() async {
    try {
      await _player.play(AssetSource('sounds/start_bell.mp3'));
    } catch (e) {
      debugPrint('Error playing rest end sound: $e');
    }
  }

  // Reproducir sonido cuando termina el entrenamiento
  Future<void> playWorkoutCompleteSound() async {
    // No reproducir sonido
  }

  // Liberar recursos
  void dispose() {
    _player.dispose();
  }
}
