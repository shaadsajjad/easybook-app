import 'package:easybook_app/core/theme/app_spacing.dart';
import 'package:easybook_app/core/utils/extensions.dart';
import 'package:easybook_app/core/widgets/pressable_scale.dart';
import 'package:flutter/material.dart';

enum AppButtonVariant { primary, secondary, text }

/// The app's button. `primary` is the glowing lime pill with ink text and
/// a light sweep across it every few seconds; `secondary` is outlined;
/// `text` is a plain link-style button.
///
/// While [isLoading] is true the button shows a spinner and ignores taps,
/// so a request can't be sent twice. The label and spinner cross-fade.
class AppButton extends StatelessWidget {
  const new({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.variant = AppButtonVariant.primary,
    this.icon,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final AppButtonVariant variant;
  final IconData? icon;

  bool get _enabled => onPressed != null && !isLoading;

  @override
  Widget build(BuildContext context) {
    final callback = _enabled ? onPressed : null;
    final palette = context.palette;
    final button = switch (variant) {
      AppButtonVariant.primary => _Glow(
        visible: _enabled,
        child: _Shine(
          active: _enabled,
          child: FilledButton(
            onPressed: callback,
            // Keep the lime fill while loading (not the grey disabled look).
            style: isLoading
                ? FilledButton.styleFrom(
                    disabledBackgroundColor: palette.solidFill,
                  )
                : null,
            child: _content(context, palette.onSolidFill),
          ),
        ),
      ),
      AppButtonVariant.secondary => OutlinedButton(
        onPressed: callback,
        child: _content(context, context.colors.onSurface),
      ),
      AppButtonVariant.text => TextButton(
        onPressed: callback,
        child: _content(context, context.colors.primary),
      ),
    };
    return PressableScale(enabled: _enabled, child: button);
  }

  Widget _content(BuildContext context, Color color) {
    final Widget child;
    if (isLoading) {
      child = SizedBox.square(
        key: const ValueKey('loading'),
        dimension: AppSizes.iconMd,
        child: CircularProgressIndicator(
          strokeWidth: AppSizes.progressStroke,
          color: color,
        ),
      );
    } else {
      final text = Text(label, maxLines: 1, overflow: TextOverflow.ellipsis);
      child = icon == null
          ? text
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: AppSizes.iconSm),
                const SizedBox(width: AppSpacing.xs),
                Flexible(child: text),
              ],
            );
    }
    return AnimatedSwitcher(
      duration: AppDurations.medium,
      transitionBuilder: (child, animation) => ScaleTransition(
        scale: animation,
        child: FadeTransition(opacity: animation, child: child),
      ),
      child: child,
    );
  }
}

/// A soft lime glow under the primary button (fades out when disabled).
class _Glow extends StatelessWidget {
  const new({required this.visible, required this.child});

  final bool visible;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: AppDurations.medium,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.pill),
        boxShadow: [
          BoxShadow(
            color: visible
                ? context.palette.glow
                : context.palette.glow.withValues(alpha: 0),
            blurRadius: AppElevation.cardBlur * 1.5,
            offset: const Offset(0, AppElevation.cardOffsetY * 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// A diagonal band of light that sweeps across the child every few
/// seconds. Off when disabled or when the system asks for less motion.
class _Shine extends StatefulWidget {
  const new({required this.active, required this.child});

  final bool active;
  final Widget child;

  @override
  State<_Shine> createState() => _ShineState();
}

class _ShineState extends State<_Shine> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppDurations.shine,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(_Shine oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync();
  }

  void _sync() {
    final run = widget.active && !MediaQuery.disableAnimationsOf(context);
    if (run && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!run) {
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: AnimatedBuilder(
        animation: _controller,
        child: widget.child,
        builder: (context, child) {
          // The sweep takes the first 30% of each cycle, then rests.
          // The tree stays the same at rest (a fully transparent band), so
          // the button underneath keeps its state.
          final t = (_controller.value / 0.3).clamp(0.0, 1.0);
          final x = -1.5 + 3 * t;
          final white = context.palette.onHero;
          final peak = t == 0 || t == 1 ? 0.0 : 0.55;
          return ShaderMask(
            blendMode: BlendMode.srcATop,
            shaderCallback: (bounds) => LinearGradient(
              begin: Alignment(x - 0.4, -1),
              end: Alignment(x + 0.4, 1),
              colors: [
                white.withValues(alpha: 0),
                white.withValues(alpha: peak),
                white.withValues(alpha: 0),
              ],
            ).createShader(bounds),
            child: child,
          );
        },
      ),
    );
  }
}
