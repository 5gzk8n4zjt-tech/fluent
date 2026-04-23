import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

enum FluentPillVariant { standard, dark, muted, streak }

class FluentPill extends StatelessWidget {
  const FluentPill({
    super.key,
    required this.child,
    this.variant = FluentPillVariant.standard,
  });

  final Widget child;
  final FluentPillVariant variant;

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color fg) = switch (variant) {
      FluentPillVariant.dark => (AppColors.textPrimary, Colors.white),
      FluentPillVariant.muted => (AppColors.mutedPill, AppColors.textPrimary),
      FluentPillVariant.streak => (AppColors.streakBg, AppColors.streakText),
      FluentPillVariant.standard => (AppColors.surface, AppColors.textPrimary),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(24)),
      child: DefaultTextStyle.merge(
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: fg, letterSpacing: -0.1),
        child: child,
      ),
    );
  }
}
