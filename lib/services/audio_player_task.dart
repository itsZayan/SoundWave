import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:async';

class SoundWaveAudioHandler extends BaseAudioHandler with QueueHandler, SeekHandler {
  final AudioPlayer _player = AudioPlayer();
  late StreamSubscription<PlaybackEvent> _playbackEventSubscription;
  
  SoundWaveAudioHandler() {
    _init();
  }

  Future<void> _init() async {
    // Configure audio session
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());

    // Set up player event listeners
    _playbackEventSubscription = _player.playbackEventStream.listen((event) {
      final playing = _player.playing;
      playbackState.add(playbackState.value.copyWith(
        controls: [
          MediaControl.skipToPrevious,
          if (playing) MediaControl.pause else MediaControl.play,
          MediaControl.stop,
          MediaControl.skipToNext,
        ],
        systemActions: const {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
        },
        androidCompactActionIndices: const [0, 1, 3],
        processingState: const {
          ProcessingState.idle: AudioProcessingState.idle,
          ProcessingState.loading: AudioProcessingState.loading,
          ProcessingState.buffering: AudioProcessingState.buffering,
          ProcessingState.ready: AudioProcessingState.ready,
          ProcessingState.completed: AudioProcessingState.completed,
        }[_player.processingState] ?? AudioProcessingState.idle,
        playing: playing,
        updatePosition: _player.position,
        bufferedPosition: _player.bufferedPosition,
        speed: _player.speed,
        queueIndex: event.currentIndex,
      ));
    });

    // Handle audio interruptions
    session.interruptionEventStream.listen((event) {
      if (event.begin) {
        switch (event.type) {
          case AudioInterruptionType.duck:
            if (session.androidAudioAttributes!.usage == AndroidAudioUsage.game) {
              _player.setVolume(0.5);
            }
            break;
          case AudioInterruptionType.pause:
          case AudioInterruptionType.unknown:
            pause();
            break;
        }
      } else {
        switch (event.type) {
          case AudioInterruptionType.duck:
            _player.setVolume(1.0);
            break;
          case AudioInterruptionType.pause:
            play();
            break;
          case AudioInterruptionType.unknown:
            break;
        }
      }
    });

    // Handle becoming noisy (headphones unplugged)
    session.becomingNoisyEventStream.listen((_) {
      pause();
    });
  }

  @override
  Future<void> play() async {
    await _player.play();
  }

  @override
  Future<void> pause() async {
    await _player.pause();
  }

  @override
  Future<void> stop() async {
    await _player.stop();
    await playbackState.firstWhere(
      (state) => state.processingState == AudioProcessingState.idle,
    );
  }

  @override
  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  @override
  Future<void> skipToQueueItem(int index) async {
    if (index < 0 || index >= queue.value.length) return;
    await _player.seek(Duration.zero, index: index);
  }

  @override
  Future<void> skipToNext() async {
    await _player.seekToNext();
  }

  @override
  Future<void> skipToPrevious() async {
    await _player.seekToPrevious();
  }

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {
    switch (repeatMode) {
      case AudioServiceRepeatMode.none:
        _player.setLoopMode(LoopMode.off);
        break;
      case AudioServiceRepeatMode.one:
        _player.setLoopMode(LoopMode.one);
        break;
      case AudioServiceRepeatMode.group:
      case AudioServiceRepeatMode.all:
        _player.setLoopMode(LoopMode.all);
        break;
    }
  }

  @override
  Future<void> setShuffleMode(AudioServiceShuffleMode shuffleMode) async {
    final enabled = shuffleMode == AudioServiceShuffleMode.all;
    await _player.setShuffleModeEnabled(enabled);
  }

  Future<void> loadMediaItem(MediaItem mediaItem) async {
    final duration = mediaItem.duration;
    
    // Update the media item and queue
    mediaItem = mediaItem.copyWith(duration: duration);
    this.mediaItem.add(mediaItem);
    queue.add([mediaItem]);

    try {
      if (mediaItem.extras?['isLocal'] == true) {
        await _player.setFilePath(mediaItem.extras!['localPath']);
      } else {
        await _player.setUrl(mediaItem.id);
      }
    } catch (e) {
      print('Error loading media: $e');
      playbackState.add(playbackState.value.copyWith(
        processingState: AudioProcessingState.error,
      ));
    }
  }

  @override
  Future<void> customAction(String name, [Map<String, dynamic>? extras]) async {
    if (name == 'loadMediaItem' && extras != null) {
      final mediaItemData = extras['mediaItem'] as Map<String, dynamic>;
      final mediaItem = MediaItem(
        id: mediaItemData['id'],
        title: mediaItemData['title'],
        artist: mediaItemData['artist'],
        album: mediaItemData['album'],
        duration: mediaItemData['duration'] != null 
            ? Duration(milliseconds: mediaItemData['duration']) 
            : null,
        artUri: mediaItemData['artUri'] != null 
            ? Uri.parse(mediaItemData['artUri']) 
            : null,
        extras: mediaItemData['extras'],
      );
      await loadMediaItem(mediaItem);
    }
  }

  @override
  Future<void> onTaskRemoved() async {
    await stop();
    await super.onTaskRemoved();
  }

  Future<void> dispose() async {
    await _playbackEventSubscription.cancel();
    await _player.dispose();
  }
}
