import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import '../flutter_story_view.dart';

class MediaLoader {
  final String mediaUrl;
  final VoidCallback onLoaded;
  final VoidCallback? onError;
  final Map<String, String>? requestHeaders;
  final Duration storyDuration;
  final StoryController storyController;

  final DefaultCacheManager _defaultCacheManager = DefaultCacheManager();
  File? mediaFile;
  LoadStatus _status = LoadStatus.loading;
  StreamSubscription<FileResponse>? _streamSubscription;

  MediaLoader({
    required this.mediaUrl,
    required this.onLoaded,
    required this.storyController,
    required this.storyDuration,
    this.requestHeaders,
    this.onError,
  }) {
    _load();
  }

  LoadStatus get status => _status;

  void setState(LoadStatus newStatus) {
    _status = newStatus;
  }

  void _load() {
    if (mediaFile != null) {
      _status = LoadStatus.success;
      onLoaded();
      return;
    }

    _status = LoadStatus.loading;
    _streamSubscription?.cancel();

    final Stream<FileResponse> stream = _defaultCacheManager.getFileStream(
      mediaUrl,
      headers: requestHeaders,
    );

    _streamSubscription = stream.listen(_onLoaded, onError: _handleError);
  }

  void _handleError(dynamic error) {
    _status = LoadStatus.failure;
    onError?.call();
  }

  void _onLoaded(FileResponse fileResponse) {
    if (fileResponse is! FileInfo) return;
    try {
      mediaFile = fileResponse.file;
      _status = LoadStatus.success;
      onLoaded();
    } catch (error) {
      _handleError(error);
    }
  }

  void dispose() {
    _streamSubscription?.cancel();
  }
}
