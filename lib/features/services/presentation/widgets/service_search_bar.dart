import 'package:easy_localization/easy_localization.dart';
import 'package:easybook_app/core/localization/locale_keys.g.dart';
import 'package:easybook_app/core/theme/app_icons.dart';
import 'package:easybook_app/core/theme/app_spacing.dart';
import 'package:easybook_app/core/utils/extensions.dart';
import 'package:flutter/material.dart';

/// The white search field on the Home header, with a clear button and a
/// filter button that shows a dot while a price range is active.
class ServiceSearchBar extends StatefulWidget {
  const new({
    required this.onChanged,
    required this.onFilterPressed,
    required this.hasPriceFilter,
    super.key,
  });

  final ValueChanged<String> onChanged;
  final VoidCallback onFilterPressed;
  final bool hasPriceFilter;

  @override
  State<ServiceSearchBar> createState() => _ServiceSearchBarState();
}

class _ServiceSearchBarState extends State<ServiceSearchBar> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _clear() {
    _controller.clear();
    widget.onChanged('');
    setState(() {});
  }

  static final OutlineInputBorder _pill = OutlineInputBorder(
    borderRadius: BorderRadius.circular(AppRadius.pill),
    borderSide: BorderSide.none,
  );

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            textInputAction: TextInputAction.search,
            onChanged: (value) {
              widget.onChanged(value);
              setState(() {});
            },
            onTapOutside: (_) => FocusScope.of(context).unfocus(),
            decoration: InputDecoration(
              hintText: LocaleKeys.services_search_hint.tr(),
              // A white pill floating on the ink hero.
              fillColor: context.colors.surface,
              border: _pill,
              enabledBorder: _pill,
              focusedBorder: _pill.copyWith(
                borderSide: BorderSide(
                  color: context.palette.accent,
                  width: AppSizes.borderThick * 2,
                ),
              ),
              prefixIcon: const Icon(AppIcons.search),
              suffixIcon: _controller.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: LocaleKeys.services_clear_search.tr(),
                      icon: const Icon(AppIcons.close),
                      onPressed: _clear,
                    ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        _FilterButton(
          active: widget.hasPriceFilter,
          onPressed: widget.onFilterPressed,
        ),
      ],
    );
  }
}

class _FilterButton extends StatelessWidget {
  const new({required this.active, required this.onPressed});

  final bool active;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    // Turns lime, with a spin of the icon, while a price range is active.
    return AnimatedContainer(
      duration: AppDurations.slow,
      curve: AppMotion.standard,
      decoration: BoxDecoration(
        color: active ? palette.solidFill : palette.heroRaised,
        shape: BoxShape.circle,
        boxShadow: active
            ? [
                BoxShadow(
                  color: palette.glow,
                  blurRadius: AppElevation.cardBlur,
                ),
              ]
            : null,
      ),
      child: IconButton(
        tooltip: LocaleKeys.services_filter_tooltip.tr(),
        onPressed: onPressed,
        style: IconButton.styleFrom(
          minimumSize: const Size.square(AppSizes.buttonHeight),
        ),
        icon: AnimatedRotation(
          turns: active ? 0.5 : 0,
          duration: AppDurations.slow,
          curve: AppMotion.enter,
          child: Icon(
            AppIcons.filter,
            color: active ? palette.onSolidFill : palette.onHero,
          ),
        ),
      ),
    );
  }
}
