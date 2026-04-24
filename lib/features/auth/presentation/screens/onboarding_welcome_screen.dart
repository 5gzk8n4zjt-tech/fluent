import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/fluent_button.dart';

class OnboardingWelcomeScreen extends StatelessWidget {
  const OnboardingWelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(32, 16, 32, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _StepIndicator(filled: 1, total: 3),
              const Spacer(),
              // Brand mark
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(color: AppColors.textPrimary, borderRadius: BorderRadius.circular(3)),
                    ),
                    const SizedBox(width: 8),
                    const Text('Fluent', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: -0.3)),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              RichText(
                text: const TextSpan(
                  style: TextStyle(fontSize: 44, fontWeight: FontWeight.w600, letterSpacing: -2, height: 1.05, color: AppColors.textPrimary),
                  children: [
                    TextSpan(text: 'Learn English.\n'),
                    TextSpan(text: 'Actually.', style: TextStyle(color: AppColors.textSecondary)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Tarjetas que se adaptan a ti. Conversaciones que se sienten reales.',
                style: TextStyle(fontSize: 17, color: AppColors.textSecondary, height: 1.5, letterSpacing: -0.2),
              ),
              const Spacer(),
              FluentButton(
                label: 'Empezar',
                onPressed: () => context.go('/onboarding/account'),
              ),
              const SizedBox(height: 14),
              Center(
                child: GestureDetector(
                  onTap: () => context.go('/onboarding/account?isSignIn=true'),
                  child: RichText(
                    text: const TextSpan(
                      style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                      children: [
                        TextSpan(text: '¿Ya tienes cuenta? '),
                        TextSpan(
                          text: 'Inicia sesión',
                          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.filled, required this.total});

  final int filled;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(total, (i) {
        final isFilled = i < filled;
        return Expanded(
          child: Container(
            height: 3,
            margin: i < total - 1 ? const EdgeInsets.only(right: 6) : EdgeInsets.zero,
            decoration: BoxDecoration(
              color: isFilled ? AppColors.textPrimary : AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}
