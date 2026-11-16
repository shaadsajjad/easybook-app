import 'package:cached_network_image/cached_network_image.dart';
import 'package:easybook_app/core/theme/app_spacing.dart';
import 'package:easybook_app/core/utils/extensions.dart';
import 'package:easybook_app/core/widgets/skeleton.dart';
import 'package:flutter/material.dart';

/// A cached network image with a shimmer while loading and a calm
/// fallback icon if the image can't be loaded.
class AppNetworkImage extends StatelessWidget {
  const new({
    required this.url,
    this.fit = BoxFit.cover,
    this.semanticLabel,
    super.key,
  });

  final String url;
  final BoxFit fit;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      image: semanticLabel != null,
      child: CachedNetworkImage(
        imageUrl: url,
        fit: fit,
        width: double.infinity,
        height: double.infinity,
        fadeInDuration: AppDurations.medium,
        placeholder: (context, _) =>
            const Shimmer(child: SkeletonBox(radius: 0)),
        errorWidget: (context, _, _) => ColoredBox(
          color: context.palette.surfaceMuted,
          child: Center(
            child: Icon(
              Icons.image_not_supported_outlined,
              color: context.palette.textSecondary,
              size: AppSizes.iconLg,
            ),
          ),
        ),
      ),
    );
  }
}
