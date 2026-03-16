// lib/services/sound_service.dart
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class SoundService {
  static final SoundService instance = SoundService._internal();
  final AudioPlayer _player = AudioPlayer();

  SoundService._internal();

  Future<void> _play(String asset) async {
    try {
      await _player.stop();
      await _player.play(AssetSource(asset));
    } catch (e) {
      debugPrint('SoundService: failed to play $asset — $e');
    }
  }

  Future<void> playCorrect() async => _play('sounds/correct.mp3');
  Future<void> playWrong() async => _play('sounds/wrong.mp3');
  Future<void> playClick() async => _play('sounds/click.mp3');
}
