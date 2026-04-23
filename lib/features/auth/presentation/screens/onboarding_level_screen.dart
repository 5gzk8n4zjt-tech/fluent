import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/fluent_button.dart';

class _Level {
  const _Level(this.code, this.name, this.desc);
  final String code;
  final String name;
  final String desc;
}

const _levels = [
  _Level('A1', 'Beginner', 'I know a few words and common phrases.'),
  _Level('A2', 'Elementary', 'I can handle simple, everyday conversations.'),
  _Level('B1', 'Intermediate', 'I can discuss familiar topics at work or travel.'),
  _Level('B2', 'Upper-intermediate', 'I can argue a point and follow complex speech.'),
];

class OnboardingLevelScreen extends StatefulWidget {
  const OnboardingLevelScreen({super.key});

  @override
  State<OnboardingLevelScreen> createState() => _OnboardingLevelScreenState();
}

class _OnboardingLevelScreenState extends State<OnboardingLevelScreen> {
  int _selected = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: List.generate(3, (i) => Expanded(
                  child: Container(
                    height: 3,
                    margin: i < 2 ? const EdgeInsets.only(right: 6) : EdgeInsets.zero,
                    decoration: BoxDecoration(color: AppColors.textPrimary, borderRadius: BorderRadius.circular(2)),
                  ),
                )),
              ),
              const SizedBox(height: 32),
              GestureDetector(
                onTap: () => context.pop(),
                child: const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Icon(Icons.arrow_back_ios, size: 20, color: AppColors.textPrimary),
                ),
              ),
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Choose your level', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600, letterSpacing: -0.6, height: 1.15)),
                    SizedBox(height: 6),
                    Text('You can change this anytime in settings.', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView.separated(
                  itemCount: _levels.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final level = _levels[i];
                    final isSelected = _selected == i;
                    return GestureDetector(
                      onTap: () => setState(() => _selected = i),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? AppColors.textPrimary : AppColors.border,
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.textPrimary : AppColors.surface,
                                borderRadius: BorderRadius.circular(9),
                              ),
                              child: Center(
                                child: Text(
                                  level.code,
                                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isSelected ? Colors.white : AppColors.textPrimary, letterSpacing: -0.1),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(level.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: -0.1)),
                                  const SizedBox(height: 2),
                                  Text(level.desc, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.35)),
                                ],
                              ),
                            ),
                            if (isSelected) ...[
                              const SizedBox(width: 12),
                              Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(color: AppColors.textPrimary, borderRadius: BorderRadius.circular(10)),
                                child: const Icon(Icons.check, size: 12, color: Colors.white),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              FluentButton(label: 'Start learning', onPressed: () => context.go('/home')),
            ],
          ),
        ),
      ),
    );
  }
}
