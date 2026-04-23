import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class FluentCard extends StatelessWidget {
  const FluentCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.hasBorder = true,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final bool hasBorder;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: hasBorder ? Border.all(color: AppColors.border) : null,
      ),
      child: child,
    );
  }
}
