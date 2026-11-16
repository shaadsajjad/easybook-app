import 'package:easy_localization/easy_localization.dart';
import 'package:easybook_app/core/localization/locale_keys.g.dart';
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
              fillColor: context.colors.surface,
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _controller.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: LocaleKeys.services_clear_search.tr(),
                      icon: const Icon(Icons.close_rounded),
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
    return Badge(
      isLabelVisible: active,
      backgroundColor: context.palette.accent,
      smallSize: AppSpacing.md,
      child: IconButton.filled(
        tooltip: LocaleKeys.services_filter_tooltip.tr(),
        onPressed: onPressed,
        style: IconButton.styleFrom(
          backgroundColor: context.colors.surface,
          foregroundColor: context.colors.primary,
          minimumSize: const Size.square(AppSizes.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
        icon: const Icon(Icons.tune_rounded),
      ),
    );
  }
}
