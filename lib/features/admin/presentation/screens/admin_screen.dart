import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../flashcards/domain/entities/deck_entity.dart';
import '../../../flashcards/domain/value_objects/level.dart';
import '../../domain/entities/admin_entity.dart';
import '../providers/admin_providers.dart';

class AdminScreen extends ConsumerWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(adminStatsProvider);
    final decksAsync = ref.watch(allDecksAdminProvider);
    final usersAsync = ref.watch(allUsersProvider);
    final actions = ref.watch(adminActionsProvider);

    ref.listen<AdminActionsState>(adminActionsProvider, (_, next) {
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: Colors.red.shade700,
          ),
        );
        ref.read(adminActionsProvider.notifier).clearError();
      }
    });

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
          children: [
            // ── Header ─────────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Admin',
                        style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.6,
                            height: 1.15)),
                    SizedBox(height: 2),
                    Text('Panel de Fluent',
                        style: TextStyle(
                            fontSize: 14, color: AppColors.textSecondary)),
                  ],
                ),
                GestureDetector(
                  onTap: () => _confirmSignOut(context, ref),
                  child: const Icon(Icons.logout,
                      size: 20, color: AppColors.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ── Sección 1: Estadísticas globales ────────────────────────
            statsAsync.when(
              loading: () => const _StatsGridSkeleton(),
              error: (e, _) => const SizedBox.shrink(),
              data: (stats) => _StatsGrid(stats: stats),
            ),
            const SizedBox(height: 28),

            // ── Sección 2: Mazos predefinidos ────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('MAZOS PREDEFINIDOS',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                        letterSpacing: 0.5)),
                decksAsync.maybeWhen(
                  data: (d) => Text('${d.length} en total',
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textSecondary)),
                  orElse: () => const SizedBox.shrink(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            decksAsync.when(
              loading: () => const _ListSkeleton(height: 160),
              error: (e, _) => _ErrorRow(label: 'Error: $e'),
              data: (decks) => _DecksList(
                decks: decks,
                isMutating: actions.isLoading,
                onEdit: (deck) => _showDeckDialog(context, ref, deck: deck),
                onDelete: (deck) => _confirmDelete(context, ref, deck),
              ),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: actions.isLoading
                  ? null
                  : () => _showDeckDialog(context, ref),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textPrimary,
                side: const BorderSide(color: AppColors.textPrimary),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                minimumSize: const Size(double.infinity, 48),
              ),
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Añadir mazo',
                  style:
                      TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 28),

            // ── Sección 3: Usuarios ────────────────────────────────────
            usersAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (e, _) => const SizedBox.shrink(),
              data: (users) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('USUARIOS',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                              letterSpacing: 0.5)),
                      Text('${users.length} en total',
                          style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _UsersList(users: users),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeckDialog(BuildContext context, WidgetRef ref,
      {DeckEntity? deck}) {
    showDialog<void>(
      context: context,
      builder: (ctx) => _DeckFormDialog(
        deck: deck,
        onSubmit: (title, level, topic) async {
          if (deck == null) {
            return ref
                .read(adminActionsProvider.notifier)
                .createDeck(title, level, topic);
          } else {
            return ref
                .read(adminActionsProvider.notifier)
                .updateDeck(deck.id, title, level, topic);
          }
        },
      ),
    );
  }

  void _confirmDelete(
      BuildContext context, WidgetRef ref, DeckEntity deck) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Eliminar mazo?'),
        content: Text(
            'Se eliminará "${deck.title}" permanentemente. Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref
                  .read(adminActionsProvider.notifier)
                  .deleteDeck(deck.id);
            },
            child: const Text('Eliminar',
                style: TextStyle(color: Color(0xFFCC3333))),
          ),
        ],
      ),
    );
  }

  void _confirmSignOut(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(authNotifierProvider.notifier).signOut();
            },
            child: const Text('Cerrar sesión',
                style: TextStyle(color: Color(0xFFCC3333))),
          ),
        ],
      ),
    );
  }
}

// ── Stats grid 2×2 ────────────────────────────────────────────────────────

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.stats});
  final AdminStatsEntity stats;

  @override
  Widget build(BuildContext context) {
    final items = [
      (value: '${stats.totalUsers}', label: 'Usuarios totales'),
      (value: '${stats.activeToday}', label: 'Activos hoy'),
      (value: _compact(stats.totalCardsReviewed), label: 'Tarjetas revisadas'),
      (value: '${stats.totalDecksCreated}', label: 'Mazos predefinidos'),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 2.1,
      children: items
          .map((item) => Container(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(item.value,
                        style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.5,
                            fontFeatures: [FontFeature.tabularFigures()])),
                    const SizedBox(height: 2),
                    Text(item.label,
                        style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                            height: 1.2)),
                  ],
                ),
              ))
          .toList(),
    );
  }

  String _compact(int n) =>
      n >= 1000 ? '${(n / 1000).toStringAsFixed(1)}k' : '$n';
}

// ── Decks list ─────────────────────────────────────────────────────────────

class _DecksList extends StatelessWidget {
  const _DecksList({
    required this.decks,
    required this.isMutating,
    required this.onEdit,
    required this.onDelete,
  });

  final List<DeckEntity> decks;
  final bool isMutating;
  final void Function(DeckEntity) onEdit;
  final void Function(DeckEntity) onDelete;

  @override
  Widget build(BuildContext context) {
    if (decks.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border)),
        child: const Center(
          child: Text('No hay mazos predefinidos.',
              style:
                  TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (int i = 0; i < decks.length; i++)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
              decoration: BoxDecoration(
                  border: i == 0
                      ? null
                      : const Border(
                          top: BorderSide(color: Color(0xFFEFEFEC)))),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                        color: AppColors.textPrimary,
                        borderRadius: BorderRadius.circular(24)),
                    child: Text(decks[i].level.code,
                        style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.white)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(decks[i].title,
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.1)),
                        Text(decks[i].topic,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: isMutating ? null : () => onEdit(decks[i]),
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(Icons.edit_outlined,
                          size: 17, color: AppColors.textSecondary),
                    ),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: isMutating ? null : () => onDelete(decks[i]),
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(Icons.delete_outline,
                          size: 17, color: Color(0xFFCC3333)),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ── Users list ─────────────────────────────────────────────────────────────

class _UsersList extends StatelessWidget {
  const _UsersList({required this.users});
  final List<UserEntity> users;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final u in users)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
            decoration: const BoxDecoration(
                border: Border(
                    bottom: BorderSide(color: Color(0xFFEFEFEC)))),
            child: Row(
              children: [
                Expanded(
                  child: Text(u.email,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 13, color: AppColors.textPrimary)),
                ),
                const SizedBox(width: 8),
                _RolePill(role: u.role),
                const SizedBox(width: 8),
                SizedBox(
                  width: 52,
                  child: Text(
                    DateFormat('d MMM', 'es').format(u.createdAt),
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontFeatures: [FontFeature.tabularFigures()]),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _RolePill extends StatelessWidget {
  const _RolePill({required this.role});
  final Role role;

  @override
  Widget build(BuildContext context) {
    final isAdmin = role == Role.admin;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isAdmin ? AppColors.textPrimary : const Color(0xFFF0F0EC),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Text(
        isAdmin ? 'Admin' : 'Usuario',
        style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: isAdmin ? Colors.white : AppColors.textPrimary,
            letterSpacing: -0.1),
      ),
    );
  }
}

// ── Deck form dialog ───────────────────────────────────────────────────────

class _DeckFormDialog extends StatefulWidget {
  const _DeckFormDialog({this.deck, required this.onSubmit});

  final DeckEntity? deck;
  final Future<bool> Function(String title, String level, String topic)
      onSubmit;

  @override
  State<_DeckFormDialog> createState() => _DeckFormDialogState();
}

class _DeckFormDialogState extends State<_DeckFormDialog> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _topicCtrl;
  late String _level;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.deck?.title ?? '');
    _topicCtrl = TextEditingController(text: widget.deck?.topic ?? '');
    _level = widget.deck?.level.name ?? Level.a1.name;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _topicCtrl.dispose();
    super.dispose();
  }

  bool get _canSubmit =>
      _titleCtrl.text.trim().isNotEmpty &&
      _topicCtrl.text.trim().isNotEmpty &&
      !_submitting;

  Future<void> _submit() async {
    if (!_canSubmit) return;
    setState(() => _submitting = true);
    final ok = await widget.onSubmit(
        _titleCtrl.text.trim(), _level, _topicCtrl.text.trim());
    if (!mounted) return;
    if (ok) Navigator.pop(context);
    setState(() => _submitting = false);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.deck != null;
    return AlertDialog(
      title: Text(isEdit ? 'Editar mazo' : 'Nuevo mazo'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleCtrl,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                  labelText: 'Título', border: OutlineInputBorder()),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              initialValue: _level,
              decoration: const InputDecoration(
                  labelText: 'Nivel', border: OutlineInputBorder()),
              items: Level.values
                  .map((l) => DropdownMenuItem(
                      value: l.name, child: Text(l.code)))
                  .toList(),
              onChanged: (v) => setState(() => _level = v!),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _topicCtrl,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                  labelText: 'Tema', border: OutlineInputBorder()),
              maxLines: 2,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar',
              style: TextStyle(color: AppColors.textSecondary)),
        ),
        TextButton(
          onPressed: _canSubmit ? _submit : null,
          child: _submitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : Text(isEdit ? 'Guardar' : 'Crear',
                  style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}

// ── Skeleton / error helpers ───────────────────────────────────────────────

class _StatsGridSkeleton extends StatelessWidget {
  const _StatsGridSkeleton();

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 2.1,
      children: List.generate(
        4,
        (_) => Container(
          decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}

class _ListSkeleton extends StatelessWidget {
  const _ListSkeleton({required this.height});
  final double height;

  @override
  Widget build(BuildContext context) => Container(
        height: height,
        decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border)),
      );
}

class _ErrorRow extends StatelessWidget {
  const _ErrorRow({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(label,
            style: const TextStyle(
                fontSize: 13, color: AppColors.textSecondary)),
      );
}
