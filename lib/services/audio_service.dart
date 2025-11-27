import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _player = AudioPlayer();

  // Configurar el reproductor para no interrumpir otras apps
  Future<void> _configurePlayer() async {
    try {
      // Configurar el modo de audio para que no pause otras apps
      await _player.setAudioContext(
        AudioContext(
          iOS: AudioContextIOS(
            category: AVAudioSessionCategory.ambient,
            options: {AVAudioSessionOptions.mixWithOthers},
          ),
          android: AudioContextAndroid(
            isSpeakerphoneOn: false,
            stayAwake: false,
            contentType: AndroidContentType.sonification,
            usageType: AndroidUsageType.notification,
            audioFocus: AndroidAudioFocus.gainTransientMayDuck,
          ),
        ),
      );
      await _player.setReleaseMode(ReleaseMode.stop);
    } catch (e) {
      debugPrint('Error configuring audio player: $e');
    }
  }

  // Reproducir sonido cuando termina el tiempo de trabajo
  Future<void> playWorkEndSound() async {
    try {
      await _configurePlayer();
      await _player.play(AssetSource('sounds/end_bell.mp3'));
    } catch (e) {
      debugPrint('Error playing work end sound: $e');
    }
  }

  // Reproducir sonido cuando termina el tiempo de descanso
  Future<void> playRestEndSound() async {
    try {
      await _configurePlayer();
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
