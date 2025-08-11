import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:audio_session/audio_session.dart';

class AudioHandlerImpl extends BaseAudioHandler with QueueHandler, SeekHandler {
  final _player = AudioPlayer();
  final List<MediaItem> _queue = [];
  int _currentIndex = -1;

  AudioHandlerImpl() {
    _init();
  }

  Future<void> _init() async {
    // Listen to audio player state changes
    _player.playbackEventStream.map(_transform).pipe(playbackState);
    
    // Listen to sequence state changes for queue updates
    _player.sequenceStateStream.listen((sequenceState) {
      if (sequenceState != null) {
        final currentItem = sequenceState.currentSource?.tag as MediaItem?;
        if (currentItem != null) {
          mediaItem.add(currentItem);
        }
      }
    });

    // Initialize player
    await _player.setAudioSource(ConcatenatingAudioSource(children: []));
  }

  PlaybackState _transform(PlaybackEvent event) {
    return PlaybackState(
      controls: [
        MediaControl.skipToPrevious,
        if (_player.playing) MediaControl.pause else MediaControl.play,
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
      }[_player.processingState]!,
      playing: _player.playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
      queueIndex: _currentIndex,
    );
  }

  @override
  Future<void> addQueueItems(List<MediaItem> mediaItems) async {
    _queue.addAll(mediaItems);
    final audioSources = mediaItems
        .map((item) => _createAudioSource(item))
        .toList();
    await _player.setAudioSource(
      ConcatenatingAudioSource(children: audioSources),
    );
    queue.add(_queue);
  }

  @override
  Future<void> addQueueItem(MediaItem mediaItem) async {
    _queue.add(mediaItem);
    final audioSource = _createAudioSource(mediaItem);
    await (_player.audioSource as ConcatenatingAudioSource)
        .add(audioSource);
    queue.add(_queue);
  }

  AudioSource _createAudioSource(MediaItem mediaItem) {
    final uri = Uri.parse(mediaItem.id);
    if (uri.scheme == 'file' || uri.scheme == '' && !kIsWeb) {
      // Local file
      return AudioSource.file(mediaItem.id, tag: mediaItem);
    } else {
      // Network URL
      return AudioSource.uri(uri, tag: mediaItem);
    }
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> skipToNext() => _player.seekToNext();

  @override
  Future<void> skipToPrevious() => _player.seekToPrevious();

  @override
  Future<void> skipToQueueItem(int index) async {
    if (index < 0 || index >= _queue.length) return;
    _currentIndex = index;
    await _player.seek(Duration.zero, index: index);
  }

  @override
  Future<void> stop() async {
    await _player.stop();
    await super.stop();
  }

  @override
  Future<void> removeQueueItemAt(int index) async {
    if (index < 0 || index >= _queue.length) return;
    _queue.removeAt(index);
    await (_player.audioSource as ConcatenatingAudioSource)
        .removeAt(index);
    queue.add(_queue);
  }

  @override
  Future<void> seekForward(bool begin) async {
    if (begin) {
      await _player.seek(_player.position + const Duration(seconds: 10));
    }
  }

  @override
  Future<void> seekBackward(bool begin) async {
    if (begin) {
      await _player.seek(_player.position - const Duration(seconds: 10));
    }
  }

  Future<void> playMediaItem(MediaItem mediaItem) async {
    // Clear current queue and add the new item
    _queue.clear();
    _queue.add(mediaItem);
    _currentIndex = 0;
    
    final audioSource = _createAudioSource(mediaItem);
    await _player.setAudioSource(
      ConcatenatingAudioSource(children: [audioSource]),
    );
    
    queue.add(_queue);
    this.mediaItem.add(mediaItem);
    await _player.play();
  }

  // Custom method to update media item for notification
  void updateNotificationMediaItem(MediaItem newMediaItem) {
    this.mediaItem.add(newMediaItem);
  }

  @override
  Future<void> customAction(String name, [Map<String, dynamic>? extras]) async {
    switch (name) {
      case 'seekForward':
        await seekForward(true);
        break;
      case 'seekBackward':
        await seekBackward(true);
        break;
      default:
        await super.customAction(name, extras);
    }
  }
}
