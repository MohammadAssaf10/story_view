import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import '../utils/enum.dart';

/// Utitlity to load image (gif, png, jpg, etc) media just once. Resource is
/// cached to disk with default configurations of [DefaultCacheManager].
class ImageLoader {
  ui.Codec? frames;

  String url;

  Map<String, dynamic>? requestHeaders;

  LoadState state = LoadState.loading; // by default

  ImageLoader(this.url, {this.requestHeaders});

  /// Load image from disk cache first, if not found then load from network.
  /// `onComplete` is called when [imageBytes] become available.
  void loadImage(VoidCallback onComplete) {
    if (this.frames != null) {
      this.state = LoadState.success;
      onComplete();
    }

    final fileStream = DefaultCacheManager().getFileStream(
      this.url,
      headers: this.requestHeaders as Map<String, String>?,
    );

    fileStream.listen(
      (fileResponse) {
        if (!(fileResponse is FileInfo)) return;
        // the reason for this is that, when the cache manager fetches
        // the image again from network, the provided `onComplete` should
        // not be called again
        if (this.frames != null) {
          return;
        }

        final imageBytes = fileResponse.file.readAsBytesSync();

        this.state = LoadState.success;

        ui
            .instantiateImageCodec(imageBytes)
            .then(
              (codec) {
                this.frames = codec;
                onComplete();
              },
              onError: (error) {
                this.state = LoadState.failure;
                onComplete();
              },
            );
      },
      onError: (error) {
        this.state = LoadState.failure;
        onComplete();
      },
    );
  }
}
