import 'package:rxdart/rxdart.dart';

import '../utils/enum.dart';

class StoryController {
  final BehaviorSubject<PlaybackState> playbackNotifier =
      BehaviorSubject<PlaybackState>();

  void pause() {
    playbackNotifier.add(PlaybackState.pause);
  }

  void play() {
    playbackNotifier.add(PlaybackState.play);
  }

  void next() {
    playbackNotifier.add(PlaybackState.next);
  }

  void previous() {
    playbackNotifier.add(PlaybackState.previous);
  }

  void dispose() {
    playbackNotifier.close();
  }
}
