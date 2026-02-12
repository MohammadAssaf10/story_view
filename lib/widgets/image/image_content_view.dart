import 'package:flutter/material.dart';

import '../../flutter_story_view.dart';

class ImageContentView extends StatelessWidget {
  final MediaLoader imageLoader;
  final BoxFit? fit;
  final Widget? loader;
  final Widget? errorView;
  const ImageContentView({
    super.key,
    required this.imageLoader,
    required this.fit,
    required this.loader,
    required this.errorView,
  });

  @override
  Widget build(BuildContext context) {
    switch (imageLoader.status) {
      case LoadStatus.loading:
        return Center(
          child:
              loader ??
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
              errorView ??
              const Text(
                "Image failed to load",
                style: TextStyle(color: Colors.white),
              ),
        );
    }
  }
}
