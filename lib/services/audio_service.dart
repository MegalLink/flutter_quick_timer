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

  // Reproducir sonido cuando termina el tiempo de trabajo
  Future<void> playWorkEndSound() async {
    try {
      if (!_isConfigured) await _initPlayer();
      debugPrint('Playing work end sound...');
      
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
      
      await _player.play(AssetSource('sounds/end_bell.mp3'));
      debugPrint('Work end sound played');
    } catch (e) {
      debugPrint('Error playing work end sound: $e');
    }
  }

  // Reproducir sonido cuando termina el tiempo de descanso
  Future<void> playRestEndSound() async {
    try {
      if (!_isConfigured) await _initPlayer();
      debugPrint('Playing rest end sound...');
      
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
      
      await _player.play(AssetSource('sounds/start_bell.mp3'));
      debugPrint('Rest end sound played');
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
