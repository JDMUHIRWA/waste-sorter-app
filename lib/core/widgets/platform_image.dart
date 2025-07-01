import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Platform-aware image widget that works on both mobile and web
class PlatformImage extends StatelessWidget {
  final String imagePath;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final BorderRadius? borderRadius;

  const PlatformImage({
    super.key,
    required this.imagePath,
    this.width,
    this.height,
    this.fit,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;

    if (kIsWeb) {
      // On web, use Network image or show placeholder
      imageWidget = Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: borderRadius,
        ),
        child: const Icon(
          Icons.image,
          size: 50,
          color: Colors.grey,
        ),
      );
    } else {
      // On mobile platforms, use File image
      imageWidget = ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.zero,
        child: Image.file(
          File(imagePath),
          width: width,
          height: height,
          fit: fit ?? BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: borderRadius,
              ),
              child: const Icon(
                Icons.broken_image,
                size: 50,
                color: Colors.grey,
              ),
            );
          },
        ),
      );
    }

    return imageWidget;
  }
}
