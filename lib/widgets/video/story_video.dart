import 'dart:async';

import 'package:better_player_plus/better_player_plus.dart';
import 'package:flutter/material.dart';

import '../../controller/story_controller.dart';
import '../../utils/enum.dart';
import '../../utils/video_loader.dart';
import 'video_content_view.dart';

class StoryVideo extends StatefulWidget {
  final StoryController? storyController;
  final VideoLoader videoLoader;
  final Widget? loadingWidget;
  final Widget? errorWidget;

  const StoryVideo(
    this.videoLoader, {
    super.key,
    this.storyController,
    this.loadingWidget,
    this.errorWidget,
  });

  factory StoryVideo.url(
    String url, {
    StoryController? controller,
    Map<String, String>? requestHeaders,
    Key? key,
    Widget? loadingWidget,
    Widget? errorWidget,
  }) {
    return StoryVideo(
      VideoLoader(url, requestHeaders: requestHeaders),
      storyController: controller,
      key: key,
      loadingWidget: loadingWidget,
      errorWidget: errorWidget,
    );
  }

  @override
  State<StoryVideo> createState() => _StoryVideoState();
}

class _StoryVideoState extends State<StoryVideo> {
  StreamSubscription<PlaybackState>? _streamSubscription;
  BetterPlayerController? _videoPlayerController;

  @override
  void initState() {
    super.initState();
    widget.storyController?.pause();
    _loadVideo();
  }

  @override
  void dispose() {
    widget.videoLoader.dispose();
    _streamSubscription?.cancel();
    _videoPlayerController?.pause();
    _videoPlayerController?.dispose();
    super.dispose();
  }

  void _loadVideo() {
    widget.videoLoader.loadVideo(_onLoadSuccess, onLoading: _onLoading);
  }

  void _onLoading() {
    if (mounted) {
      setState(() {
        widget.videoLoader.showLoading();
      });
    }
  }

  void _onLoadSuccess() {
    if (!mounted) return;

    if (widget.videoLoader.state == LoadState.success) {
      initializeVideo();
      // Setup Story Controller Listener
      _setupStoryListener();
    } else {
      setState(() {});
    }
  }

  Future<void> initializeVideo() async {
    if (widget.videoLoader.state != LoadState.success) return;
    final file = widget.videoLoader.videoFile;

    if (file == null) {
      setState(() {});
      return;
    }

    BetterPlayerConfiguration betterPlayerConfiguration =
        const BetterPlayerConfiguration(
          autoPlay: false,
          autoDispose: false,
          fit: BoxFit.contain,
          aspectRatio: 0.1,
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
      setState(() {});
      widget.storyController?.play();
      _videoPlayerController!.play();
    }
  }

  void _setupStoryListener() {
    if (widget.storyController == null) return;

    _streamSubscription = widget.storyController!.playbackNotifier.listen((
      playbackState,
    ) {
      if (_videoPlayerController == null) return;

      if (playbackState == PlaybackState.pause) {
        _videoPlayerController!.pause();
      } else if (playbackState == PlaybackState.play) {
        _videoPlayerController!.play();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: _videoPlayerController == null
          ? widget.loadingWidget ??
                const SizedBox(
                  width: 70,
                  height: 70,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 3,
                  ),
                )
          : ColoredBox(
              color: Colors.black,
              child: VideoContentView(
                videoLoadState: widget.videoLoader.state,
                playerController: _videoPlayerController!,
                loadingWidget: widget.loadingWidget,
                errorWidget: widget.errorWidget,
              ),
            ),
    );
  }
}
