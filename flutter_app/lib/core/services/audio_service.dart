import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  AudioPlayer? _player;
  bool _isPlaying = false;

  bool get isPlaying => _isPlaying;

  AudioPlayer get player {
    _player ??= AudioPlayer();
    return _player!;
  }

  Future<void> _configureAudioContext() async {
    try {
      final context = AudioContext(
        android: const AudioContextAndroid(
          isSpeakerphoneOn: true,
          stayAwake: true,
          contentType: AndroidContentType.sonification,
          usageType: AndroidUsageType.alarm,
          audioMode: AndroidAudioMode.normal,
        ),
        iOS: AudioContextIOS(
          category: AVAudioSessionCategory.playback,
          options: {
            AVAudioSessionOptions.duckOthers,
          },
        ),
      );
      await AudioPlayer.global.setAudioContext(context);
    } catch (e) {
      debugPrint('Error configuring audio context: $e');
    }
  }

  /// Start playing the alarm in a continuous loop using the user's selected file path.
  Future<void> startAlarm({String? filePath}) async {
    await stopAlarm();
    await _configureAudioContext();

    try {
      await player.setReleaseMode(ReleaseMode.loop);
      await player.setVolume(1.0);

      if (filePath != null && filePath.isNotEmpty && File(filePath).existsSync()) {
        await player.play(DeviceFileSource(filePath));
        _isPlaying = true;
      } else {
        // If no file path or file was deleted, player won't play or we can handle gracefully
        debugPrint('No valid local ringtone file found at $filePath');
      }
    } catch (e) {
      debugPrint('Error playing alarm audio: $e');
      _isPlaying = false;
    }
  }

  /// Preview the selected ringtone (single play, not looped)
  Future<void> playPreview(String filePath) async {
    await stopAlarm();
    try {
      if (File(filePath).existsSync()) {
        await player.setReleaseMode(ReleaseMode.release);
        await player.setVolume(1.0);
        await player.play(DeviceFileSource(filePath));
        _isPlaying = true;
      }
    } catch (e) {
      debugPrint('Error previewing audio: $e');
    }
  }

  /// Stop any active alarm or preview playback
  Future<void> stopAlarm() async {
    try {
      if (_player != null) {
        await _player!.stop();
        _isPlaying = false;
      }
    } catch (e) {
      debugPrint('Error stopping audio: $e');
    }
  }

  void dispose() {
    _player?.dispose();
    _player = null;
    _isPlaying = false;
  }
}
