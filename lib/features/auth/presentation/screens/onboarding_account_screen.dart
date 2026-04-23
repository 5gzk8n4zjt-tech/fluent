import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/fluent_button.dart';

class OnboardingAccountScreen extends StatelessWidget {
  const OnboardingAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(32, 16, 32, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _StepIndicator(filled: 2, total: 3),
              const SizedBox(height: 40),
              GestureDetector(
                onTap: () => context.pop(),
                child: const Icon(Icons.arrow_back_ios, size: 20, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 32),
              const Text(
                'Create your account',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.w600, letterSpacing: -0.6, height: 1.15),
              ),
              const SizedBox(height: 6),
              const Text(
                "We'll remember your progress across devices.",
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 40),
              _LabeledField(label: 'Email', hint: 'alex@fluent.app', keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 28),
              _LabeledField(label: 'Password', hint: '••••••••', obscure: true),
              const Spacer(),
              FluentButton(
                label: 'Create account',
                onPressed: () => context.go('/onboarding/level'),
              ),
              const SizedBox(height: 12),
              Center(
                child: RichText(
                  textAlign: TextAlign.center,
                  text: const TextSpan(
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.5),
                    children: [
                      TextSpan(text: 'By continuing, you agree to the '),
                      TextSpan(text: 'Terms', style: TextStyle(color: AppColors.textPrimary)),
                      TextSpan(text: ' and '),
                      TextSpan(text: 'Privacy Policy', style: TextStyle(color: AppColors.textPrimary)),
                      TextSpan(text: '.'),
                    ],
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

class _LabeledField extends StatelessWidget {
  const _LabeledField({required this.label, required this.hint, this.keyboardType, this.obscure = false});

  final String label;
  final String hint;
  final TextInputType? keyboardType;
  final bool obscure;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500, letterSpacing: -0.1)),
        const SizedBox(height: 4),
        TextField(
          keyboardType: keyboardType,
          obscureText: obscure,
          style: const TextStyle(fontSize: 16, color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: obscure ? const Color(0xFFC0C0BA) : AppColors.textSecondary),
          ),
        ),
      ],
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
      children: List.generate(total, (i) => Expanded(
        child: Container(
          height: 3,
          margin: i < total - 1 ? const EdgeInsets.only(right: 6) : EdgeInsets.zero,
          decoration: BoxDecoration(
            color: i < filled ? AppColors.textPrimary : AppColors.border,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      )),
    );
  }
}
