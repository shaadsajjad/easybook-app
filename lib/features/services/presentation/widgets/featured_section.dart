import 'package:easy_localization/easy_localization.dart';
import 'package:easybook_app/core/localization/locale_keys.g.dart';
import 'package:easybook_app/core/theme/app_spacing.dart';
import 'package:easybook_app/core/utils/extensions.dart';
import 'package:easybook_app/core/widgets/fade_slide_in.dart';
import 'package:easybook_app/core/widgets/section_header.dart';
import 'package:easybook_app/core/widgets/skeleton.dart';
import 'package:easybook_app/features/services/domain/entities/service.dart';
import 'package:easybook_app/features/services/presentation/bloc/featured_services_cubit.dart';
import 'package:easybook_app/features/services/presentation/widgets/featured_service_card.dart';
import 'package:easybook_app/features/services/presentation/widgets/service_skeletons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// "Featured" title and a swipeable carousel of big photo cards.
/// If featured services fail or there are none, the section is hidden:
/// the main list below has its own error and empty states.
class FeaturedSection extends StatelessWidget {
  const new({
    required this.horizontalPadding,
    required this.onServiceTap,
    super.key,
  });

  final double horizontalPadding;
  final ValueChanged<Service> onServiceTap;

  @override
  Widget build(BuildContext context) {
    // Taller cards when the user enlarges text, so nothing gets cut off.
    final textScale = MediaQuery.textScalerOf(context).scale(1).clamp(1, 1.6);
    final height = AppSizes.featuredCardHeight * textScale;

    return BlocBuilder<FeaturedServicesCubit, FeaturedServicesState>(
      builder: (context, state) {
        final isLoading =
            state.status == FeaturedStatus.loading && state.services.isEmpty;
        if (!isLoading && state.services.isEmpty) {
          return const SizedBox.shrink();
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.lg),
            SectionHeader(title: LocaleKeys.services_featured.tr()),
            const SizedBox(height: AppSpacing.md),
            if (isLoading)
              SizedBox(
                height: height,
                child: Shimmer(
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                    ),
                    itemCount: 3,
                    separatorBuilder: (_, _) =>
                        const SizedBox(width: AppSpacing.md),
                    itemBuilder: (_, _) => const FeaturedCardSkeleton(),
                  ),
                ),
              )
            else
              FadeSlideIn(
                axis: Axis.horizontal,
                offset: AppMotion.entranceOffset * 3,
                child: _Carousel(
                  services: state.services,
                  height: height,
                  onServiceTap: onServiceTap,
                ),
              ),
          ],
        );
      },
    );
  }
}

/// A PageView where the centered card is full size and its neighbours
/// shrink, tilt and fade as you swipe; photos slide inside their cards
/// (parallax). Dots underneath show the position.
class _Carousel extends StatefulWidget {
  const new({
    required this.services,
    required this.height,
    required this.onServiceTap,
  });

  final List<Service> services;
  final double height;
  final ValueChanged<Service> onServiceTap;

  @override
  State<_Carousel> createState() => _CarouselState();
}

class _CarouselState extends State<_Carousel> {
  PageController? _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // A card is about 300 dp wide, so tablets show more of the neighbours.
    final width = MediaQuery.sizeOf(context).width;
    final fraction = (AppSizes.featuredCardWidth / width).clamp(0.4, 0.86);
    if (_controller?.viewportFraction != fraction) {
      _controller?.dispose();
      _controller = PageController(viewportFraction: fraction);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  /// How far page [index] is from the center, -1..1 (0 = centered).
  double _offset(int index) {
    final controller = _controller;
    if (controller == null ||
        !controller.hasClients ||
        !controller.position.haveDimensions) {
      return index.toDouble();
    }
    return ((controller.page ?? 0) - index).clamp(-1.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller!;
    return Column(
      children: [
        SizedBox(
          height: widget.height,
          child: PageView.builder(
            controller: controller,
            itemCount: widget.services.length,
            padEnds: false,
            itemBuilder: (context, index) => AnimatedBuilder(
              animation: controller,
              builder: (context, child) {
                final offset = _offset(index).clamp(-1.0, 1.0);
                final distance = offset.abs();
                return Padding(
                  padding: EdgeInsetsDirectional.only(
                    start: index == 0 ? AppSpacing.page : AppSpacing.xs,
                    end: AppSpacing.xs,
                  ),
                  child: Opacity(
                    opacity: 1 - distance * 0.35,
                    child: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001)
                        ..rotateY(offset * 0.25)
                        ..scaleByDouble(
                          1 - distance * 0.1,
                          1 - distance * 0.1,
                          1,
                          1,
                        ),
                      child: FeaturedServiceCard(
                        service: widget.services[index],
                        parallax: offset,
                        onTap: () =>
                            widget.onServiceTap(widget.services[index]),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        AnimatedBuilder(
          animation: controller,
          builder: (context, _) => _Dots(
            count: widget.services.length,
            page: controller.hasClients && controller.position.haveDimensions
                ? controller.page ?? 0
                : 0,
          ),
        ),
      ],
    );
  }
}

/// Position dots: the current one stretches into a lime pill.
class _Dots extends StatelessWidget {
  const new({required this.count, required this.page});

  final int count;
  final double page;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 0; i < count; i++)
            Builder(
              builder: (context) {
                // 1 when this dot is the current page, 0 when a page away.
                final t = (1 - (page - i).abs()).clamp(0.0, 1.0);
                return Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xxs,
                  ),
                  width: AppSpacing.xs + AppSpacing.md * t,
                  height: AppSpacing.xs,
                  decoration: BoxDecoration(
                    // Text colour: ink in light mode, near-white in dark
                    // mode, so the current dot is visible in both.
                    color: Color.lerp(
                      context.colors.outline,
                      context.colors.onSurface,
                      t,
                    ),
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
