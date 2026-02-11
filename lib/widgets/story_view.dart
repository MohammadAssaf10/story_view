import 'dart:async';

import 'package:flutter/material.dart';
import 'package:story_view/widgets/story_overlay.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../story_view.dart';

class StoryView extends StatefulWidget {
  final List<StoryItem> storyItems;
  final StoryController controller;
  final VoidCallback? onComplete;
  final Function(Direction?)? onVerticalSwipeComplete;
  final void Function(StoryItem storyItem, int index)? onStoryShow;
  final ProgressPosition progressPosition;
  final Color? progressColor;
  final Color? progressActiveColor;
  final double progressHeight;
  final EdgeInsetsGeometry progressMargin;
  final bool isRtl;
  final VoidCallback? onMoveToPreviousPage;

  const StoryView({
    super.key,
    required this.storyItems,
    required this.controller,
    this.onComplete,
    this.onStoryShow,
    this.onVerticalSwipeComplete,
    this.onMoveToPreviousPage,
    this.progressPosition = ProgressPosition.top,
    this.isRtl = false,
    this.progressColor,
    this.progressActiveColor,
    this.progressHeight = 5,
    this.progressMargin = const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 8,
    ),
  });

  @override
  State<StoryView> createState() => _StoryViewState();
}

class _StoryViewState extends State<StoryView> with TickerProviderStateMixin {
  AnimationController? _animationController;
  Animation<double>? _currentAnimation;
  Timer? _debounceTimer;
  StreamSubscription<PlaybackState>? _playbackSubscription;
  VerticalDragInfo? _verticalDragInfo;

  int _currentIndex = 0;

  StoryItem get _currentStoryItem => widget.storyItems[_currentIndex];

  @override
  void initState() {
    super.initState();
    if (widget.storyItems.isEmpty) return;
    WakelockPlus.enable();
    // Find the first story that hasn't been seen yet
    final firstUnseenIndex = widget.storyItems.indexWhere(
      (it) => !it.isSeenBefore,
    );

    if (firstUnseenIndex == -1) {
      // All seen, start from 0 and reset flags
      _currentIndex = 0;
      for (var item in widget.storyItems) {
        item.isSeenBefore = false;
      }
    } else {
      _currentIndex = firstUnseenIndex;
      // Mark all previous as seen, all future as unseen (safety check)
      for (int i = 0; i < widget.storyItems.length; i++) {
        widget.storyItems[i].isSeenBefore = i < _currentIndex;
      }
    }

    _subscribeToController();
    _play();
  }

  void _subscribeToController() {
    _playbackSubscription = widget.controller.playbackNotifier.listen((status) {
      switch (status) {
        case PlaybackState.play:
          _cancelDebouncer();
          _animationController?.forward();
          break;
        case PlaybackState.pause:
          _startDebouncer();
          _animationController?.stop(canceled: false);
          break;
        case PlaybackState.next:
          _cancelDebouncer();
          _goForward();
          break;
        case PlaybackState.previous:
          _cancelDebouncer();
          _goBack();
          break;
      }
    });
  }

  // --- Playback Logic ---

  void _play() {
    _animationController?.dispose();

    final storyItem = _currentStoryItem;

    widget.onStoryShow?.call(storyItem, _currentIndex);

    _animationController = AnimationController(
      duration: storyItem.storyDuration,
      vsync: this,
    );

    _animationController!.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        storyItem.isSeenBefore = true;
        _goForward();
      }
    });

    _currentAnimation = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(_animationController!);

    // Notify controller we are playing
    widget.controller.play();
  }

  void _goForward() {
    if (_currentIndex != widget.storyItems.length - 1) {
      _animationController?.stop();
      // Mark current as seen before moving
      _currentStoryItem.isSeenBefore = true;

      setState(() {
        _currentIndex++;
      });
      _play();
    } else {
      // Last item completed
      _currentStoryItem.isSeenBefore = true;
      _animationController?.animateTo(
        1.0,
        duration: const Duration(milliseconds: 10),
      );
      _onComplete();
    }
  }

  void _goBack() {
    _animationController?.stop();

    if (_currentIndex == 0) {
      // If at first page, try to delegate to parent or restart
      if (widget.onMoveToPreviousPage != null) {
        widget.onMoveToPreviousPage!();
      } else {
        // Restart current story
        _currentStoryItem.isSeenBefore = false;
        _play();
      }
    } else {
      // Move to previous
      _currentStoryItem.isSeenBefore = false;
      setState(() {
        _currentIndex--;
        _currentStoryItem.isSeenBefore = false;
      });
      _play();
    }
  }

  void _onComplete() {
    widget.controller.pause();
    widget.onComplete?.call();
  }

  // --- Debouncer Logic (for long press/pause) ---

  void _cancelDebouncer() {
    _debounceTimer?.cancel();
    _debounceTimer = null;
  }

  void _startDebouncer() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {});
  }

  @override
  Widget build(BuildContext context) {
    if (widget.storyItems.isEmpty) return const SizedBox.shrink();

    return Stack(
      children: <Widget>[
        KeyedSubtree(
          key: ValueKey(_currentIndex),
          child: _currentStoryItem.view,
        ),
        StoryOverlay(
          header: _currentStoryItem.header,
          caption: _currentStoryItem.caption,
          progress: Padding(
            padding: widget.progressMargin,
            child: PageBar(
              widget.storyItems
                  .map((it) => PageData(it.storyDuration, it.isSeenBefore))
                  .toList(),
              _currentAnimation,
              indicatorHeight: widget.progressHeight,
              indicatorColor: widget.progressColor,
              indicatorForegroundColor: widget.progressActiveColor,
              isRtl: widget.isRtl,
            ),
          ),
          progressPosition: widget.progressPosition,
          onTapDown: (_) => widget.controller.pause(),
          onTapCancel: () => widget.controller.play(),
          onTapUp: (_, isPrevious) {
            if (_debounceTimer?.isActive == false) {
              widget.controller.play();
            } else {
              if (isPrevious) {
                widget.controller.previous();
              } else {
                widget.controller.next();
              }
            }
          },
          onVerticalDragUpdate: (details) {
            _verticalDragInfo ??= VerticalDragInfo();
            _verticalDragInfo!.update(details.primaryDelta!);
          },
          onVerticalDragEnd: (_) {
            widget.controller.play();
            if (_verticalDragInfo != null && !(_verticalDragInfo!.cancel)) {
              widget.onVerticalSwipeComplete!(_verticalDragInfo!.direction);
            }
            _verticalDragInfo = null;
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    _cancelDebouncer();
    _animationController?.dispose();
    _playbackSubscription?.cancel();
    super.dispose();
  }
}
