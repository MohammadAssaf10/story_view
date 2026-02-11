import 'package:better_player_plus/better_player_plus.dart';
import 'package:flutter/material.dart';

import '../../story_view.dart';

class VideoContentView extends StatelessWidget {
  final MediaLoader videoLoader;
  final BetterPlayerController? playerController;
  final Widget? loader;
  final Widget? errorView;

  const VideoContentView({
    super.key,
    required this.videoLoader,
    required this.playerController,
    required this.loader,
    required this.errorView,
  });

  bool get _isPlayerReady {
    return playerController != null &&
        playerController!.videoPlayerController?.value.initialized == true;
  }

  @override
  Widget build(BuildContext context) {
    switch (videoLoader.status) {
      case LoadStatus.loading:
        return Center(
          child:
              loader ??
              const SizedBox(
                width: 70,
                height: 70,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 3,
                ),
              ),
        );
      case LoadStatus.success:
        return _isPlayerReady
            ? Center(child: BetterPlayer(controller: playerController!))
            : SizedBox.shrink();
      case LoadStatus.failure:
        return Center(
          child:
              errorView ??
              const Text(
                "Video failed to load",
                style: TextStyle(color: Colors.white),
              ),
        );
    }
  }
}
