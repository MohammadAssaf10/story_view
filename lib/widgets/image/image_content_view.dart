import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../utils/enum.dart';
import '../../utils/image_loader.dart';

/**
 * @name ImageContentView
 * @description Stateless widget that displays an image based on loading state: success, failure, or loading.
 */
class ImageContentView extends StatelessWidget {
  final ImageLoader imageLoader;
  final BoxFit? fit;
  final ui.Image? currentFrame;
  final Widget? loadingWidget;
  final Widget? errorWidget;

  const ImageContentView({
    Key? key,
    required this.imageLoader,
    required this.fit,
    required this.currentFrame,
    this.loadingWidget,
    this.errorWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    switch (imageLoader.state) {
      case LoadState.success:
        return RawImage(image: currentFrame, fit: fit);
      case LoadState.failure:
        return Center(
          child:
              errorWidget ??
              const Text(
                "Image failed to load.",
                style: TextStyle(color: Colors.white),
              ),
        );
      default:
        return Center(
          child:
              loadingWidget ??
              const SizedBox(
                width: 70,
                height: 70,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 3,
                ),
              ),
        );
    }
  }
}
