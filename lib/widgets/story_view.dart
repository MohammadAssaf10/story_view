import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../controller/story_controller.dart';
import '../utils/enum.dart';
import '../utils/page_data.dart';
import '../utils/utils.dart';
import 'page_bar.dart';
import 'story_item.dart';

class StoryView extends StatefulWidget {
  final List<StoryItem> storyItems;
  final StoryController controller;
  final VoidCallback? onComplete;
  final Function(Direction?)? onVerticalSwipeComplete;
  final void Function(StoryItem storyItem, int index)? onStoryShow;
  final ProgressPosition progressPosition;
  final bool repeat;
  final bool inline;
  final Color? indicatorColor;
  final Color? indicatorForegroundColor;
  final double indicatorHeight;
  final EdgeInsetsGeometry indicatorMargin;
  final bool isRtl;
  final EdgeInsetsGeometry buttonPadding;
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
    this.repeat = false,
    this.inline = false,
    this.isRtl = false,
    this.indicatorColor,
    this.indicatorForegroundColor,
    this.indicatorHeight = 5,
    this.buttonPadding = EdgeInsets.zero,
    this.indicatorMargin = const EdgeInsets.symmetric(
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

  @override
  void dispose() {
    WakelockPlus.disable();
    _cancelDebouncer();
    _animationController?.dispose();
    _playbackSubscription?.cancel();
    super.dispose();
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

    if (widget.repeat) {
      for (var it in widget.storyItems) {
        it.isSeenBefore = false;
      }
      setState(() {
        _currentIndex = 0;
      });
      _play();
    }
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

  // --- UI Building ---

  @override
  Widget build(BuildContext context) {
    if (widget.storyItems.isEmpty) return const SizedBox.shrink();

    return Stack(
      children: <Widget>[
        // 1. The Story Content
        _buildStoryView(),

        // 2. The Progress Bars
        if (widget.progressPosition != ProgressPosition.none)
          _buildIndicators(),

        // 3. Gesture Detectors (Overlay)
        _wrapWithVerticalSwipe(child: _buildGestures()),
      ],
    );
  }

  Widget _buildStoryView() {
    return KeyedSubtree(
      key: ValueKey(_currentIndex),
      child: _currentStoryItem.view,
    );
  }

  Widget _buildIndicators() {
    return Align(
      alignment: widget.progressPosition == ProgressPosition.top
          ? Alignment.topCenter
          : Alignment.bottomCenter,
      child: SafeArea(
        bottom: widget.inline ? false : true,
        child: Container(
          padding: widget.indicatorMargin,
          child: PageBar(
            widget.storyItems
                .map((it) => PageData(it.storyDuration, it.isSeenBefore))
                .toList(),
            _currentAnimation,
            indicatorHeight: widget.indicatorHeight,
            indicatorColor: widget.indicatorColor,
            indicatorForegroundColor: widget.indicatorForegroundColor,
            isRtl: widget.isRtl,
          ),
        ),
      ),
    );
  }

  Widget _buildGestures() {
    return Padding(
      padding: widget.buttonPadding,
      child: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                // Previous / Left Side
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTapDown: (_) => widget.controller.pause(),
                    onTapCancel: () => widget.controller.play(),
                    onTapUp: (_) {
                      if (_debounceTimer?.isActive == false) {
                        widget.controller.play();
                      } else {
                        widget.controller.previous();
                      }
                    },
                  ),
                ),
                // Next / Right Side
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTapDown: (_) => widget.controller.pause(),
                    onTapCancel: () => widget.controller.play(),
                    onTapUp: (_) {
                      if (_debounceTimer?.isActive == false) {
                        widget.controller.play();
                      } else {
                        widget.controller.next();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
    // Note: Swiping logic was removed from the simplified Row above for clarity.
    // If vertical swipe is strictly needed alongside taps, wrap the whole Row
    // in the Vertical Swipe Gesture Detector below.
  }

  Widget _wrapWithVerticalSwipe({Widget? child}) {
    if (widget.onVerticalSwipeComplete == null) return SizedBox.shrink();

    return GestureDetector(
      onVerticalDragStart: (_) => widget.controller.pause(),
      onVerticalDragCancel: () => widget.controller.play(),
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
      child: child,
    );
  }
}
