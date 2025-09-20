import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart';

import '../utils/page_data.dart';
import 'story_progress_indicator.dart';

/// Horizontal bar displaying a row of [StoryProgressIndicator] based on the
/// [pages] provided.
class PageBar extends StatefulWidget {
  final List<PageData> pages;
  final Animation<double>? animation;
  final double indicatorHeight;
  final Color? indicatorColor;
  final Color? indicatorForegroundColor;
  final bool isRtl;

  PageBar(
    this.pages,
    this.animation, {
    required this.isRtl,
    this.indicatorHeight = 5,
    this.indicatorColor,
    this.indicatorForegroundColor,
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return PageBarState();
  }
}

class PageBarState extends State<PageBar> {
  double spacing = 4;

  @override
  void initState() {
    super.initState();

    int count = widget.pages.length;
    spacing = (count > 15) ? 2 : ((count > 10) ? 3 : 4);

    widget.animation!.addListener(() {
      setState(() {});
    });
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  bool isPlaying(PageData page) {
    return widget.pages.firstWhereOrNull((it) => !it.shown) == page;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: widget.pages.map((it) {
        return Expanded(
          child: Container(
            padding: EdgeInsetsDirectional.only(start: this.spacing),
            child: StoryProgressIndicator(
              isPlaying(it) ? widget.animation!.value : (it.shown ? 1 : 0),
              indicatorHeight: widget.indicatorHeight,
              indicatorColor: widget.indicatorColor,
              indicatorForegroundColor: widget.indicatorForegroundColor,
              isRtl: widget.isRtl,
            ),
          ),
        );
      }).toList(),
    );
  }
}
