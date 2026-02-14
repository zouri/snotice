import 'package:audioplayers/audioplayers.dart';
import 'logger_service.dart';

/// 声音提醒服务
class SoundService {
  final LoggerService _logger;
  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;

  /// 内置声音资源映射
  static const Map<String, String> builtInSounds = {
    'default': 'sounds/default.wav',
    'bell': 'sounds/bell.wav',
    'chime': 'sounds/chime.wav',
    'alert': 'sounds/alert.wav',
  };

  /// 获取所有可用声音的显示名称
  static const Map<String, String> soundDisplayNames = {
    'default': '默认',
    'bell': '铃声',
    'chime': '风铃',
    'alert': '警报',
  };

  SoundService(this._logger) {
    _initPlayer();
  }

  void _initPlayer() {
    _player.onPlayerComplete.listen((_) {
      _isPlaying = false;
      _logger.debug('Sound playback completed');
    });

    _player.onLog.listen((msg) {
      _logger.debug('AudioPlayer log: $msg');
    });
  }

  /// 播放内置声音
  Future<void> play(String soundKey) async {
    if (_isPlaying) {
      await stop();
    }

    var soundPath = builtInSounds[soundKey];
    if (soundPath == null) {
      _logger.warning('Unknown sound key: $soundKey, using default');
      soundPath = builtInSounds['default']!;
    }

    try {
      _isPlaying = true;
      await _player.play(AssetSource(soundPath));
      _logger.info('Playing sound: $soundKey');
    } catch (e) {
      _isPlaying = false;
      _logger.error('Failed to play sound $soundKey: $e');
    }
  }

  /// 播放自定义声音文件
  Future<void> playFile(String filePath) async {
    if (_isPlaying) {
      await stop();
    }

    try {
      _isPlaying = true;
      await _player.play(DeviceFileSource(filePath));
      _logger.info('Playing custom sound: $filePath');
    } catch (e) {
      _isPlaying = false;
      _logger.error('Failed to play custom sound $filePath: $e');
    }
  }

  /// 停止播放
  Future<void> stop() async {
    try {
      await _player.stop();
      _isPlaying = false;
      _logger.debug('Sound playback stopped');
    } catch (e) {
      _logger.error('Failed to stop sound: $e');
    }
  }

  /// 暂停播放
  Future<void> pause() async {
    try {
      await _player.pause();
      _logger.debug('Sound playback paused');
    } catch (e) {
      _logger.error('Failed to pause sound: $e');
    }
  }

  /// 恢复播放
  Future<void> resume() async {
    try {
      await _player.resume();
      _logger.debug('Sound playback resumed');
    } catch (e) {
      _logger.error('Failed to resume sound: $e');
    }
  }

  /// 设置音量 (0.0 - 1.0)
  Future<void> setVolume(double volume) async {
    try {
      await _player.setVolume(volume.clamp(0.0, 1.0));
      _logger.debug('Volume set to: $volume');
    } catch (e) {
      _logger.error('Failed to set volume: $e');
    }
  }

  /// 释放资源
  void dispose() {
    _player.dispose();
    _logger.debug('SoundService disposed');
  }
}
