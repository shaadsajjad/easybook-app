import 'package:easy_localization/easy_localization.dart';
import 'package:easybook_app/core/localization/locale_keys.g.dart';
import 'package:easybook_app/core/theme/app_spacing.dart';
import 'package:easybook_app/core/utils/extensions.dart';
import 'package:easybook_app/core/utils/price_formatter.dart';
import 'package:easybook_app/core/utils/validators.dart';
import 'package:easybook_app/core/widgets/app_button.dart';
import 'package:easybook_app/core/widgets/app_text_field.dart';
import 'package:flutter/material.dart';

/// A price range; null on either side means "no limit".
typedef PriceRange = ({double? min, double? max});

/// Bottom sheet to pick a price range: quick presets or exact amounts.
/// Returns the chosen range, or null if dismissed.
class PriceFilterSheet extends StatefulWidget {
  const new({required this.initial, super.key});

  final PriceRange initial;

  static Future<PriceRange?> show(BuildContext context, PriceRange initial) {
    return showModalBottomSheet<PriceRange>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      // Cover the bottom navigation bar too.
      useRootNavigator: true,
      builder: (_) => PriceFilterSheet(initial: initial),
    );
  }

  @override
  State<PriceFilterSheet> createState() => _PriceFilterSheetState();
}

class _PriceFilterSheetState extends State<PriceFilterSheet> {
  // Quick choices, in BDT (the seeded services cost ৳500 to ৳3,500).
  static const List<PriceRange> _presets = [
    (min: null, max: null),
    (min: null, max: 1000),
    (min: 1000, max: 3000),
    (min: 3000, max: null),
  ];

  final _formKey = GlobalKey<FormState>();
  late final _min = TextEditingController(text: _text(widget.initial.min));
  late final _max = TextEditingController(text: _text(widget.initial.max));

  static String _text(double? value) =>
      value == null ? '' : value.toStringAsFixed(0);

  @override
  void dispose() {
    _min.dispose();
    _max.dispose();
    super.dispose();
  }

  PriceRange get _current => (
    min: double.tryParse(_min.text.trim()),
    max: double.tryParse(_max.text.trim()),
  );

  String _presetLabel(PriceRange range, String locale) {
    String price(double value) => PriceFormatter.format(value, locale: locale);
    final (:min, :max) = range;
    if (min == null && max == null) return LocaleKeys.services_price_any.tr();
    if (min == null) {
      return LocaleKeys.services_price_under.tr(
        namedArgs: {'price': price(max!)},
      );
    }
    if (max == null) {
      return LocaleKeys.services_price_over.tr(
        namedArgs: {'price': price(min)},
      );
    }
    return LocaleKeys.services_price_between.tr(
      namedArgs: {'min': price(min), 'max': price(max)},
    );
  }

  void _selectPreset(PriceRange range) {
    setState(() {
      _min.text = _text(range.min);
      _max.text = _text(range.max);
    });
  }

  String? _validateMax(String? value) {
    final error = Validators.optionalAmount(value);
    if (error != null) return error;
    final (:min, :max) = _current;
    if (min != null && max != null && max < min) {
      return LocaleKeys.services_price_order.tr();
    }
    return null;
  }

  void _apply() {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;
    Navigator.of(context).pop(_current);
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.localeName;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.page,
          0,
          AppSpacing.page,
          AppSpacing.xl,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                LocaleKeys.services_price_filter_title.tr(),
                style: context.textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                LocaleKeys.services_price_filter_subtitle.tr(),
                style: context.textTheme.bodySmall,
              ),
              const SizedBox(height: AppSpacing.lg),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  for (final preset in _presets)
                    ChoiceChip(
                      label: Text(_presetLabel(preset, locale)),
                      selected: preset == _current,
                      showCheckmark: false,
                      labelStyle: preset == _current
                          ? Theme.of(context).chipTheme.secondaryLabelStyle
                          : null,
                      onSelected: (_) => _selectPreset(preset),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: AppTextField(
                      label: LocaleKeys.services_min_price.tr(),
                      hint: '0',
                      controller: _min,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      textInputAction: TextInputAction.next,
                      validator: Validators.optionalAmount,
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: AppTextField(
                      label: LocaleKeys.services_max_price.tr(),
                      hint: LocaleKeys.services_price_any.tr(),
                      controller: _max,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: _validateMax,
                      onChanged: (_) => setState(() {}),
                      onFieldSubmitted: (_) => _apply(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: LocaleKeys.services_reset_filter.tr(),
                      variant: AppButtonVariant.secondary,
                      onPressed: () =>
                          Navigator.of(context).pop((min: null, max: null)),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    flex: 2,
                    child: AppButton(
                      label: LocaleKeys.services_apply_filter.tr(),
                      onPressed: _apply,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
