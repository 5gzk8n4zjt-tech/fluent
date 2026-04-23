import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/fluent_button.dart';
import '../../../../shared/widgets/fluent_card.dart';
import '../../../../shared/widgets/fluent_pill.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          children: [
            const SizedBox(height: 8),
            const Text('Good morning, Alex', style: TextStyle(fontSize: 14, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
            const SizedBox(height: 4),
            const Text('Ready to learn?', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w600, letterSpacing: -0.6, height: 1.15)),
            const SizedBox(height: 24),
            // Study session card
            FluentCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('STUDY SESSION', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary, letterSpacing: 0.5)),
                      const FluentPill(
                        variant: FluentPillVariant.streak,
                        child: Text('▲  7 day streak', style: TextStyle(fontSize: 11)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  RichText(
                    text: const TextSpan(
                      children: [
                        TextSpan(text: '12 ', style: TextStyle(fontSize: 34, fontWeight: FontWeight.w600, letterSpacing: -0.8, color: AppColors.textPrimary)),
                        TextSpan(text: 'cards due', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text('Across 2 decks · ~6 min', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                  const SizedBox(height: 18),
                  FluentButton(label: 'Start studying', onPressed: () => context.go('/study/a1-everyday')),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Conversation card
            FluentCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('CONVERSATION', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary, letterSpacing: 0.5)),
                      Text("Today's topic", style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text('Ordering food at a restaurant', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, letterSpacing: -0.2)),
                  const SizedBox(height: 6),
                  const Text('Practice asking about dishes, allergies, and the bill.', style: TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.5)),
                  const SizedBox(height: 16),
                  FluentButton(
                    label: 'Start chat',
                    onPressed: () => context.go('/chat'),
                    variant: FluentButtonVariant.secondary,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Weekly progress card
            FluentCard(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('THIS WEEK', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary, letterSpacing: 0.5)),
                      Text('5 / 7 days', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      for (final day in [
                        (d: 'M', on: true, today: false),
                        (d: 'T', on: true, today: false),
                        (d: 'W', on: true, today: false),
                        (d: 'T', on: false, today: false),
                        (d: 'F', on: true, today: false),
                        (d: 'S', on: true, today: false),
                        (d: 'S', on: false, today: true),
                      ])
                        Column(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: day.on ? AppColors.textPrimary : (day.today ? Colors.transparent : AppColors.border),
                                border: day.today ? Border.all(color: AppColors.textPrimary, width: 1.5) : null,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              day.d,
                              style: TextStyle(
                                fontSize: 11,
                                color: day.today ? AppColors.textPrimary : AppColors.textSecondary,
                                fontWeight: day.today ? FontWeight.w600 : FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
