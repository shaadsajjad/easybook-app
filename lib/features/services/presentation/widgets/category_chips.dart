import 'package:easy_localization/easy_localization.dart';
import 'package:easybook_app/core/localization/locale_keys.g.dart';
import 'package:easybook_app/core/theme/app_spacing.dart';
import 'package:easybook_app/features/services/presentation/bloc/categories_cubit.dart';
import 'package:easybook_app/features/services/presentation/bloc/services_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// "All" plus one chip per category. Hidden until categories load; if
/// they fail, the list still works without them.
class CategoryChips extends StatelessWidget {
  const new({required this.horizontalPadding, super.key});

  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    final categories = context.select<CategoriesCubit, List<String>>(
      (cubit) => cubit.state.categories,
    );
    final selected = context.select<ServicesBloc, String?>(
      (bloc) => bloc.state.filter.category,
    );
    if (categories.isEmpty) return const SizedBox.shrink();

    final options = <String?>[null, ...categories];
    return SizedBox(
      height: AppSizes.chipRowHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        itemCount: options.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final category = options[index];
          final isSelected = category == selected;
          return ChoiceChip(
            label: Text(category ?? LocaleKeys.services_all_categories.tr()),
            selected: isSelected,
            showCheckmark: false,
            labelStyle: isSelected
                ? Theme.of(context).chipTheme.secondaryLabelStyle
                : null,
            onSelected: (_) => context.read<ServicesBloc>().add(
              ServicesCategorySelected(category),
            ),
          );
        },
      ),
    );
  }
}
