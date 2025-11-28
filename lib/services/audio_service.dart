import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;

  final AudioPlayer _player = AudioPlayer();
  bool _isConfigured = false;

  AudioService._internal() {
    // Configurar el player al inicializar
    _initPlayer();
  }

  // Inicializar y configurar el reproductor
  Future<void> _initPlayer() async {
    try {
      await _player.setReleaseMode(ReleaseMode.stop);
      await _player.setVolume(1.0);
      _isConfigured = true;
      debugPrint('Audio player configured successfully');
    } catch (e) {
      debugPrint('Error initializing audio player: $e');
    }
  }

  // Configurar y reproducir un sonido
  Future<void> _playSound(String soundPath, String soundName) async {
    try {
      if (!_isConfigured) await _initPlayer();
      debugPrint('Playing $soundName...');
      
      // Detener cualquier reproducción anterior
      await _player.stop();
      
      // Configurar el audio justo antes de reproducir
      await _player.setAudioContext(
        AudioContext(
          iOS: AudioContextIOS(
            category: AVAudioSessionCategory.playback,
            options: {
              AVAudioSessionOptions.mixWithOthers,
            },
          ),
          android: AudioContextAndroid(
            isSpeakerphoneOn: false,
            stayAwake: false,
            contentType: AndroidContentType.music,
            usageType: AndroidUsageType.media,
            audioFocus: AndroidAudioFocus.gainTransientMayDuck,
          ),
        ),
      );
      
      await _player.setVolume(1.0);
      await _player.play(AssetSource(soundPath));
      debugPrint('$soundName played');
    } catch (e) {
      debugPrint('Error playing $soundName: $e');
    }
  }

  // Reproducir sonido cuando termina el tiempo de trabajo
  Future<void> playWorkEndSound() async {
    await _playSound('sounds/end_bell.mp3', 'work end sound');
  }

  // Reproducir sonido cuando termina el tiempo de descanso
  Future<void> playRestEndSound() async {
    await _playSound('sounds/start_bell.mp3', 'rest end sound');
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
