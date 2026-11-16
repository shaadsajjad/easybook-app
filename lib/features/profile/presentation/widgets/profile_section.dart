import 'package:easybook_app/core/theme/app_spacing.dart';
import 'package:easybook_app/core/utils/extensions.dart';
import 'package:easybook_app/features/profile/presentation/widgets/profile_menu_tile.dart'
    show ProfileMenuTile;
import 'package:flutter/material.dart';

/// A titled group of [ProfileMenuTile]s on one card, with dividers.
class ProfileSection extends StatelessWidget {
  const new({required this.tiles, this.title, super.key});

  final String? title;
  final List<Widget> tiles;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Padding(
            padding: const EdgeInsets.only(
              left: AppSpacing.xs,
              bottom: AppSpacing.sm,
            ),
            child: Text(
              title!,
              style: context.textTheme.labelLarge?.copyWith(
                color: context.palette.textSecondary,
              ),
            ),
          ),
        ],
        Card(
          child: Column(
            children: [
              for (var i = 0; i < tiles.length; i++) ...[
                if (i > 0)
                  const Divider(
                    indent: AppSpacing.lg,
                    endIndent: AppSpacing.lg,
                  ),
                tiles[i],
              ],
            ],
          ),
        ),
      ],
    );
  }
}
