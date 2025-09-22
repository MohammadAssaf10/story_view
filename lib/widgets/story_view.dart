import 'dart:async';

import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart';

import '../controller/story_controller.dart';
import '../utils/enum.dart';
import '../utils/page_data.dart';
import '../utils/utils.dart';
import 'page_bar.dart';
import 'story_item.dart';

/// Widget to display stories just like Whatsapp and Instagram. Can also be used
/// inline/inside [ListView] or [Column] just like Google News app. Comes with
/// gestures to pause, forward and go to previous page.
class StoryView extends StatefulWidget {
  /// The pages to displayed.
  final List<StoryItem> storyItems;

  /// Callback for when a full cycle of story is shown. This will be called
  /// each time the full story completes when [repeat] is set to `true`.
  final VoidCallback? onComplete;

  /// Callback for when a vertical swipe gesture is detected. If you do not
  /// want to listen to such event, do not provide it. For instance,
  /// for inline stories inside ListViews, it is preferrable to not to
  /// provide this callback so as to enable scroll events on the list view.
  final Function(Direction?)? onVerticalSwipeComplete;

  /// Callback for when a story and it index is currently being shown.
  final void Function(StoryItem storyItem, int index)? onStoryShow;

  /// Where the progress indicator should be placed.
  final ProgressPosition progressPosition;

  /// Should the story be repeated forever?
  final bool repeat;

  /// If you would like to display the story as full-page, then set this to
  /// `false`. But in case you would display this as part of a page (eg. in
  /// a [ListView] or [Column]) then set this to `true`.
  final bool inline;

  /// Controls the playback of the stories
  final StoryController controller;

  /// Indicator Color
  final Color? indicatorColor;

  /// Indicator Foreground Color
  final Color? indicatorForegroundColor;

  /// Determine the height of the indicator
  final double indicatorHeight;

  /// Use this if you want to give outer padding to the indicator
  final EdgeInsetsGeometry indicatorOuterPadding;

  /// Use this if you want to display the story in a right to left language
  final bool isRtl;

  /// Use this if you want to give padding to the buttons
  final EdgeInsetsGeometry buttonPadding;

  final void Function()? onMoveToPreviousPage;

  StoryView({
    required this.storyItems,
    required this.controller,
    this.isRtl = false,
    this.onComplete,
    this.onStoryShow,
    this.progressPosition = ProgressPosition.top,
    this.repeat = false,
    this.inline = false,
    this.onVerticalSwipeComplete,
    this.indicatorColor,
    this.indicatorForegroundColor,
    this.onMoveToPreviousPage,
    this.indicatorHeight = 5,
    this.buttonPadding = EdgeInsets.zero,
    this.indicatorOuterPadding = const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 8,
    ),
  });

  @override
  State<StatefulWidget> createState() {
    return StoryViewState();
  }
}

class StoryViewState extends State<StoryView> with TickerProviderStateMixin {
  AnimationController? _animationController;
  Animation<double>? _currentAnimation;
  Timer? _nextDebouncer;

  StreamSubscription<PlaybackState>? _playbackSubscription;

  VerticalDragInfo? verticalDragInfo;

  StoryItem get _currentStory {
    StoryItem? item = widget.storyItems.firstWhereOrNull((it) => !it.shown);
    item ??= widget.storyItems.first;
    return item;
  }

  Widget get _currentView {
    StoryItem? item = widget.storyItems.firstWhereOrNull((it) => !it.shown);
    item ??= widget.storyItems.first;
    return item.view;
  }

  @override
  void initState() {
    super.initState();
    // All pages after the first unshown page should have their shown value as
    // false
    final firstPage = widget.storyItems.firstWhereOrNull((it) => !it.shown);
    if (firstPage == null) {
      widget.storyItems.forEach((it2) {
        it2.shown = false;
      });
    } else {
      final lastShownPos = widget.storyItems.indexOf(firstPage);
      widget.storyItems.sublist(lastShownPos).forEach((it) {
        it.shown = false;
      });
    }

    this._playbackSubscription = widget.controller.playbackNotifier.listen((
      playbackStatus,
    ) {
      switch (playbackStatus) {
        case PlaybackState.play:
          _removeNextHold();
          this._animationController?.forward();
          break;

        case PlaybackState.pause:
          _holdNext(); // then pause animation
          this._animationController?.stop(canceled: false);
          break;

        case PlaybackState.next:
          _removeNextHold();
          _goForward();
          break;

        case PlaybackState.previous:
          _removeNextHold();
          _goBack();
          break;
      }
    });
    _play();
  }

  @override
  void dispose() {
    _clearDebouncer();

    _animationController?.dispose();
    _playbackSubscription?.cancel();

    super.dispose();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  void _play() {
    _animationController?.dispose();
    // get the next playing page
    StoryItem? storyItem = widget.storyItems.firstWhereOrNull(
      (it) => !it.shown,
    );
    storyItem ??= widget.storyItems.first;

    final int storyItemIndex = widget.storyItems.indexOf(storyItem);

    if (widget.onStoryShow != null) {
      widget.onStoryShow!(storyItem, storyItemIndex);
    }

    _animationController = AnimationController(
      duration: storyItem.duration,
      vsync: this,
    );

    _animationController!.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        storyItem!.shown = true;
        if (widget.storyItems.last != storyItem) {
          _beginPlay();
        } else {
          // done playing
          _onComplete();
        }
      }
    });

    _currentAnimation = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(_animationController!);

    widget.controller.play();
  }

  void _beginPlay() {
    setState(() {});
    _play();
  }

  void _onComplete() {
    if (widget.onComplete != null) {
      widget.controller.pause();
      widget.onComplete!();
    }

    if (widget.repeat) {
      widget.storyItems.forEach((it) {
        it.shown = false;
      });

      _beginPlay();
    }
  }

  void _goBack() {
    _animationController!.stop();

    if (this._currentStory == widget.storyItems.first) {
      if (widget.onMoveToPreviousPage != null) {
        widget.onMoveToPreviousPage!.call();
      } else {
        _beginPlay();
      }
    } else {
      this._currentStory.shown = false;
      int lastPos = widget.storyItems.indexOf(this._currentStory);
      final previous = widget.storyItems[lastPos - 1];

      previous.shown = false;

      _beginPlay();
    }
  }

  void _goForward() {
    if (this._currentStory != widget.storyItems.last) {
      _animationController!.stop();

      // get last showing
      final _last = this._currentStory;

      _last.shown = true;
      if (_last != widget.storyItems.last) {
        _beginPlay();
      }
    } else {
      // this is the last page, progress animation should skip to end
      _animationController!.animateTo(
        1.0,
        duration: Duration(milliseconds: 10),
      );
    }
  }

  void _clearDebouncer() {
    _nextDebouncer?.cancel();
    _nextDebouncer = null;
  }

  void _removeNextHold() {
    _nextDebouncer?.cancel();
    _nextDebouncer = null;
  }

  void _holdNext() {
    _nextDebouncer?.cancel();
    _nextDebouncer = Timer(Duration(milliseconds: 500), () {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Stack(
        children: <Widget>[
          _currentView,
          Visibility(
            visible: widget.progressPosition != ProgressPosition.none,
            child: Align(
              alignment: widget.progressPosition == ProgressPosition.top
                  ? Alignment.topCenter
                  : Alignment.bottomCenter,
              // we use SafeArea here for notched and bezeles phones
              child: SafeArea(
                bottom: widget.inline ? false : true,
                child: Container(
                  padding: widget.indicatorOuterPadding,
                  child: PageBar(
                    widget.storyItems
                        .map((it) => PageData(it.duration, it.shown))
                        .toList(),
                    this._currentAnimation,
                    key: UniqueKey(),
                    indicatorHeight: widget.indicatorHeight,
                    indicatorColor: widget.indicatorColor,
                    indicatorForegroundColor: widget.indicatorForegroundColor,
                    isRtl: widget.isRtl,
                  ),
                ),
              ),
            ),
          ),

          Padding(
            padding: widget.buttonPadding,
            child: Align(
              alignment: Alignment.centerRight,
              heightFactor: 1,
              child: GestureDetector(
                onTapDown: (details) {
                  widget.controller.pause();
                },
                onTapCancel: () {
                  widget.controller.play();
                },
                onTapUp: (details) {
                  // if debounce timed out (not active) then continue anim
                  if (_nextDebouncer?.isActive == false) {
                    widget.controller.play();
                  } else {
                    widget.controller.next();
                  }
                },
                onVerticalDragStart: widget.onVerticalSwipeComplete == null
                    ? null
                    : (details) {
                        widget.controller.pause();
                      },
                onVerticalDragCancel: widget.onVerticalSwipeComplete == null
                    ? null
                    : () {
                        widget.controller.play();
                      },
                onVerticalDragUpdate: widget.onVerticalSwipeComplete == null
                    ? null
                    : (details) {
                        if (verticalDragInfo == null) {
                          verticalDragInfo = VerticalDragInfo();
                        }

                        verticalDragInfo!.update(details.primaryDelta!);

                        // TODO: provide callback interface for animation purposes
                      },
                onVerticalDragEnd: widget.onVerticalSwipeComplete == null
                    ? null
                    : (details) {
                        widget.controller.play();
                        // finish up drag cycle
                        if (!verticalDragInfo!.cancel &&
                            widget.onVerticalSwipeComplete != null) {
                          widget.onVerticalSwipeComplete!(
                            verticalDragInfo!.direction,
                          );
                        }

                        verticalDragInfo = null;
                      },
              ),
            ),
          ),

          Padding(
            padding: widget.buttonPadding,
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              heightFactor: 1,
              child: SizedBox(
                width: MediaQuery.sizeOf(context).width * 0.5,
                child: GestureDetector(
                  onTapDown: (details) {
                    widget.controller.pause();
                  },
                  onTapCancel: () {
                    widget.controller.play();
                  },
                  onTapUp: (details) {
                    // if debounce timed out (not active) then continue anim
                    if (_nextDebouncer?.isActive == false) {
                      widget.controller.play();
                    } else {
                      widget.controller.previous();
                    }
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
