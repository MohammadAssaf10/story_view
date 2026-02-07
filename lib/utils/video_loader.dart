import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import '../utils/enum.dart';

class VideoLoader {
  final String url;
  final Map<String, String>? requestHeaders;

  File? videoFile;
  LoadStatus state = LoadStatus.loading;

  StreamSubscription<FileResponse>? _subscription;

  VideoLoader(this.url, {this.requestHeaders});

  void loadVideo(VoidCallback onComplete, {VoidCallback? onLoading}) {
    // 1. Notify loading state
    onLoading?.call();
    state = LoadStatus.loading;

    // 2. Check if already loaded
    if (videoFile != null) {
      state = LoadStatus.success;
      onComplete();
      return; // Important: Stop execution here if already loaded
    }

    // 3. Start stream
    try {
      _subscription?.cancel();

      final Stream<FileResponse> stream = DefaultCacheManager().getFileStream(
        url,
        headers: requestHeaders,
      );

      _subscription = stream.listen(
        (fileResponse) {
          if (fileResponse is FileInfo) {
            if (videoFile == null) {
              videoFile = fileResponse.file;
              state = LoadStatus.success;
              onComplete();
            }
          }
        },
        onError: (error) {
          state = LoadStatus.failure;
          // You might want to add an onError callback parameter to loadVideo
          // to notify the UI of the failure.
        },
      );
    } catch (e) {
      state = LoadStatus.failure;
    }
  }

  void showLoading() {
    state = LoadStatus.loading;
  }

  /// Cancel active downloads/listeners to prevent memory leaks
  void dispose() {
    _subscription?.cancel();
  }
}
