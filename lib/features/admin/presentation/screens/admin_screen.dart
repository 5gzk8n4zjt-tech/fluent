import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () => context.pop(),
                  child: const Icon(Icons.arrow_back_ios, size: 20, color: AppColors.textPrimary),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text('Admin', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w600, letterSpacing: -0.6, height: 1.15)),
            const SizedBox(height: 4),
            const Text('Fluent dashboard', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
            const SizedBox(height: 28),
            // Decks header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('PREDEFINED DECKS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary, letterSpacing: 0.5)),
                Text('${_decks.length} total', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
            const SizedBox(height: 12),
            // Decks list
            Container(
              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  for (int i = 0; i < _decks.length; i++)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(border: i == 0 ? null : const Border(top: BorderSide(color: Color(0xFFEFEFEC)))),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(_decks[i].$1, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: -0.1)),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                      decoration: BoxDecoration(color: AppColors.textPrimary, borderRadius: BorderRadius.circular(24)),
                                      child: Text(_decks[i].$2, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text('${_decks[i].$3} cards', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                              ],
                            ),
                          ),
                          const Icon(Icons.edit_outlined, size: 16, color: AppColors.textSecondary),
                          const SizedBox(width: 12),
                          const Icon(Icons.delete_outline, size: 16, color: AppColors.textSecondary),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textPrimary,
                side: const BorderSide(color: AppColors.textPrimary),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                minimumSize: const Size(double.infinity, 48),
              ),
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Add deck', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 28),
            // Users header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('USERS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary, letterSpacing: 0.5)),
                Text('142 total', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
            const SizedBox(height: 12),
            // Users list
            for (final u in _users)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 4),
                decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFEFEFEC)))),
                child: Row(
                  children: [
                    Expanded(child: Text(u.$1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary))),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: u.$3 == 'Admin' ? AppColors.textPrimary : const Color(0xFFF0F0EC),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Text(u.$3, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: u.$3 == 'Admin' ? Colors.white : AppColors.textPrimary, letterSpacing: -0.1)),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 48,
                      child: Text(u.$2, textAlign: TextAlign.right, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontFeatures: [FontFeature.tabularFigures()])),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 20),
            // Stat pills
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: const [
                _StatPill('Total users', '142'),
                _StatPill('Active today', '38'),
                _StatPill('Cards reviewed', '1,204'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

const _decks = [
  ('Everyday objects', 'A1', 48),
  ('Daily routines', 'A2', 64),
  ('Work & travel', 'B1', 96),
  ('Opinions & debate', 'B2', 112),
];

const _users = [
  ('alex@fluent.app', 'Apr 12', 'Admin'),
  ('marco.b@gmail.com', 'Apr 18', 'User'),
  ('sara.lin@proton.me', 'Apr 19', 'User'),
  ('josh.wu@hey.com', 'Apr 21', 'User'),
];

class _StatPill extends StatelessWidget {
  const _StatPill(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
      decoration: BoxDecoration(color: const Color(0xFFEFEFEC), borderRadius: BorderRadius.circular(24)),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 12),
          children: [
            TextSpan(text: '$label ', style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
            TextSpan(text: value, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
