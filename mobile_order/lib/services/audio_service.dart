// file: lib/services/audio_service.dart
import 'package:get/get.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioService extends GetxService {
  final AudioPlayer _player = AudioPlayer();
  bool _isInitialized = false;

  Future<AudioService> init() async {
    try {
      // 볼륨 설정
      await _player.setVolume(1.0);
      _isInitialized = true;
      return this;
    } catch (e) {
      print('Error initializing AudioService: $e');
      return this;
    }
  }

  Future<void> playOrderSound() async {
    try {
      if (_isInitialized) {
        await _player.play(AssetSource('sounds/ding_dong.mp3'));
      } else {
        print('AudioPlayer is not initialized');
      }
    } catch (e) {
      print('Error playing sound: $e');
    }
  }

  @override
  void onClose() {
    _player.dispose();
    super.onClose();
  }
}
