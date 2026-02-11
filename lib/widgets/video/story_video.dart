import 'dart:async';
import 'dart:io';

import 'package:better_player_plus/better_player_plus.dart';
import 'package:flutter/material.dart';

import '../../story_view.dart';
import 'video_content_view.dart';

class StoryVideo extends StatefulWidget {
  final String videoUrl;
  final StoryController storyController;
  final Widget? loader;
  final Widget? errorView;
  final Duration storyDuration;
  final Map<String, String>? requestHeaders;

  const StoryVideo({
    super.key,
    required this.videoUrl,
    required this.storyController,
    required this.storyDuration,
    required this.loader,
    required this.errorView,
    required this.requestHeaders,
  });

  @override
  State<StoryVideo> createState() => _StoryVideoState();
}

class _StoryVideoState extends State<StoryVideo> {
  StreamSubscription<PlaybackState>? _streamSubscription;
  BetterPlayerController? _videoPlayerController;
  late final MediaLoader _videoLoader;

  @override
  void initState() {
    super.initState();

    /// Pause the story initially to ensure the video is fully loaded and ready before playback starts.
    widget.storyController.pause();
    _videoLoader = MediaLoader(
      mediaUrl: widget.videoUrl,
      onLoaded: () {
        if (!mounted) return;
        _initializeVideo();
        _setupStoryListener();
      },
      onError: () {
        setState(() {
          widget.storyController.next();
        });
      },
      storyController: widget.storyController,
      storyDuration: widget.storyDuration,
      requestHeaders: widget.requestHeaders,
    );
  }

  Future<void> _initializeVideo() async {
    if (_videoLoader.status != LoadStatus.success) return;
    final File? file = _videoLoader.mediaFile;

    if (file == null) {
      setState(() {});
      return;
    }

    BetterPlayerConfiguration betterPlayerConfiguration =
        const BetterPlayerConfiguration(
          autoPlay: false,
          autoDispose: false,
          fit: BoxFit.fitWidth,
          // aspectRatio: 0.1,
          controlsConfiguration: BetterPlayerControlsConfiguration(
            showControls: false,
          ),
        );

    BetterPlayerDataSource dataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.file,
      file.path,
    );

    _videoPlayerController = BetterPlayerController(betterPlayerConfiguration);

    await _videoPlayerController!.setupDataSource(dataSource);

    if (mounted) {
      setState(() {
        widget.storyController.play();
        _videoPlayerController!.play();
      });
    }
  }

  void _setupStoryListener() {
    _streamSubscription = widget.storyController.playbackNotifier.listen(
      _storyListener,
    );
  }

  void _storyListener(PlaybackState playbackState) {
    if (_videoPlayerController == null) return;

    if (playbackState == PlaybackState.pause) {
      _videoPlayerController!.pause();
    } else if (playbackState == PlaybackState.play) {
      _videoPlayerController!.play();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: VideoContentView(
        videoLoader: _videoLoader,
        playerController: _videoPlayerController,
        loader: widget.loader,
        errorView: widget.errorView,
      ),
    );
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    _videoPlayerController?.pause();
    _videoPlayerController?.dispose();
    _videoLoader.dispose();
    super.dispose();
  }
}
