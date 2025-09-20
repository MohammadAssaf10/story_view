import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import '../utils/enum.dart';

class VideoLoader {
  String url;

  File? videoFile;

  Map<String, dynamic>? requestHeaders;

  LoadState state = LoadState.loading;

  VideoLoader(this.url, {this.requestHeaders});

  void loadVideo(VoidCallback onComplete, VoidCallback onLoading) {
    try {
      onLoading();
      if (this.videoFile != null) {
        this.state = LoadState.success;
        onComplete();
      }

      final Stream<FileResponse> fileStream = DefaultCacheManager()
          .getFileStream(
            this.url,
            headers: this.requestHeaders as Map<String, String>?,
          );

      fileStream.listen((fileResponse) {
        if (fileResponse is FileInfo) {
          if (this.videoFile == null) {
            this.state = LoadState.success;
            this.videoFile = fileResponse.file;
            onComplete();
          }
        }
      });
    } catch (e) {
      this.state = LoadState.loading;
    }
  }

  void showLoading() {
    this.state = LoadState.loading;
  }
}
