import 'package:flutter/material.dart';
import 'package:story_view/utils/media_loader.dart';

import '../../story_view.dart';

class ImageContentView extends StatelessWidget {
  final MediaLoader imageLoader;
  final BoxFit? fit;
  final Widget? loadingWidget;
  final Widget? errorWidget;
  const ImageContentView({
    super.key,
    required this.imageLoader,
    this.fit,
    this.loadingWidget,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    switch (imageLoader.status) {
      case LoadStatus.loading:
        return Center(
          child:
              loadingWidget ??
              const SizedBox(
                width: 70,
                height: 70,
                child: CircularProgressIndicator.adaptive(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 3,
                ),
              ),
        );
      case LoadStatus.success:
        return Image.file(imageLoader.mediaFile!, fit: fit);
      case LoadStatus.failure:
        return Center(
          child:
              errorWidget ??
              const Text(
                "Image failed to load",
                style: TextStyle(color: Colors.white),
              ),
        );
    }
  }
}
