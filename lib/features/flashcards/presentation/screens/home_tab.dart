import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/supabase_client.dart';
import '../../../../shared/widgets/fluent_button.dart';
import '../../../../shared/widgets/fluent_card.dart';
import '../../../../shared/widgets/fluent_pill.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/flashcard_provider.dart';

// Reemplaza con el UUID real del mazo en Supabase
const _studyDeckId = 'a1-everyday';

class HomeTab extends ConsumerWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = supabase.auth.currentUser?.id;
    final dueAsync = userId != null
        ? ref.watch(dueCardsProvider((userId: userId, deckId: _studyDeckId)))
        : null;
    final dueCount = dueAsync?.valueOrNull?.length ?? 0;
    final isDueLoading = dueAsync?.isLoading ?? true;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          children: [
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Buenos días, Alex', style: TextStyle(fontSize: 14, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('¿Cerrar sesión?'),
                        content: const Text('Se cerrará tu sesión en la app.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancelar', style: TextStyle(color: AppColors.textSecondary)),
                          ),
                          TextButton(
                            onPressed: () async {
                              Navigator.pop(context);
                              await ref.read(authNotifierProvider.notifier).signOut();
                            },
                            child: const Text('Cerrar sesión', style: TextStyle(color: Color(0xFFCC3333))),
                          ),
                        ],
                      ),
                    );
                  },
                  child: const Icon(Icons.logout, size: 20, color: AppColors.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text('¿Listo para aprender?', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w600, letterSpacing: -0.6, height: 1.15)),
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
                      const Text('SESIÓN DE ESTUDIO', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary, letterSpacing: 0.5)),
                      const FluentPill(
                        variant: FluentPillVariant.streak,
                        child: Text('▲  7 días seguidos', style: TextStyle(fontSize: 11)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(text: isDueLoading ? '…' : '$dueCount ', style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w600, letterSpacing: -0.8, color: AppColors.textPrimary)),
                        TextSpan(text: dueCount == 1 ? 'tarjeta pendiente' : 'tarjetas pendientes', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dueCount == 0 && !isDueLoading
                        ? '¡Todas las tarjetas estudiadas hoy!'
                        : '~${(dueCount * 0.5).ceil()} min estimados',
                    style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 18),
                  FluentButton(
                    label: dueCount == 0 && !isDueLoading ? 'Al día ✓' : 'Empieza a estudiar',
                    onPressed: dueCount == 0 && !isDueLoading ? null : () => context.go('/study/$_studyDeckId'),
                  ),
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
                      Text('CONVERSACIÓN', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary, letterSpacing: 0.5)),
                      Text('Tema de hoy', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text('Ordering food at a restaurant', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, letterSpacing: -0.2)),
                  const SizedBox(height: 6),
                  const Text('Practica cómo pedir platos, preguntar sobre alergias y pedir la cuenta.', style: TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.5)),
                  const SizedBox(height: 16),
                  FluentButton(
                    label: 'Iniciar conversación',
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
                      Text('ESTA SEMANA', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary, letterSpacing: 0.5)),
                      Text('5 / 7 días', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      for (final day in [
                        (d: 'L', on: true, today: false),
                        (d: 'M', on: true, today: false),
                        (d: 'X', on: true, today: false),
                        (d: 'J', on: false, today: false),
                        (d: 'V', on: true, today: false),
                        (d: 'S', on: true, today: false),
                        (d: 'D', on: false, today: true),
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
