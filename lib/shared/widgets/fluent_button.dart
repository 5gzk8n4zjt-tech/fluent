import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

enum FluentButtonVariant { primary, secondary, outline }

class FluentButton extends StatelessWidget {
  const FluentButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = FluentButtonVariant.primary,
    this.isFullWidth = true,
    this.height = 52.0,
  });

  final String label;
  final VoidCallback? onPressed;
  final FluentButtonVariant variant;
  final bool isFullWidth;
  final double height;

  @override
  Widget build(BuildContext context) {
    final minSize = Size(isFullWidth ? double.infinity : 0, height);

    if (variant == FluentButtonVariant.outline) {
      return OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          side: const BorderSide(color: AppColors.textPrimary),
          minimumSize: minSize,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: -0.1),
        ),
        child: Text(label),
      );
    }

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: variant == FluentButtonVariant.primary ? AppColors.textPrimary : AppColors.background,
        foregroundColor: variant == FluentButtonVariant.primary ? Colors.white : AppColors.textPrimary,
        elevation: 0,
        shadowColor: Colors.transparent,
        minimumSize: minSize,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: variant == FluentButtonVariant.secondary ? const BorderSide(color: AppColors.border) : BorderSide.none,
        ),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: -0.1),
      ),
      child: Text(label),
    );
  }
}
