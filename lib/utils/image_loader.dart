import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import '../utils/enum.dart';

/// Utility to load image (gif, png, jpg, etc) media just once. Resource is
/// cached to disk with default configurations of [DefaultCacheManager].
class ImageLoader {
  final String url;
  final Map<String, String>? requestHeaders;

  ui.Codec? frames;
  LoadState state = LoadState.loading;
  StreamSubscription<FileResponse>? _subscription;

  ImageLoader(this.url, {this.requestHeaders});

  /// Load image from disk cache first, if not found then load from network.
  /// `onComplete` is called when [imageBytes] become available.
  void loadImage(VoidCallback onComplete) {
    // 1. Check if already loaded to avoid redundant work
    if (frames != null) {
      state = LoadState.success;
      onComplete();
      return; // Important: Stop execution here
    }

    state = LoadState.loading;

    // 2. Cancel previous subscription if exists
    _subscription?.cancel();

    final stream = DefaultCacheManager().getFileStream(
      url,
      headers: requestHeaders,
    );

    _subscription = stream.listen(
      (fileResponse) async {
        if (fileResponse is! FileInfo) return;

        // Prevent reloading if frames were populated by a previous event
        if (frames != null) return;

        try {
          // 3. Use Async read to prevent UI thread freeze
          final imageBytes = await fileResponse.file.readAsBytes();

          final codec = await ui.instantiateImageCodec(imageBytes);

          frames = codec;
          state = LoadState.success;
          onComplete();
        } catch (e) {
          _handleError(onComplete);
        }
      },
      onError: (error) {
        _handleError(onComplete);
      },
    );
  }

  void _handleError(VoidCallback onComplete) {
    state = LoadState.failure;
    onComplete();
  }

  /// Clean up resources to prevent memory leaks
  void dispose() {
    _subscription?.cancel();
    frames?.dispose();
    frames = null;
  }
}