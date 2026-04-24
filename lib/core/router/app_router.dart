import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/admin/presentation/screens/admin_screen.dart';
import '../../features/auth/domain/entities/user_entity.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/onboarding_account_screen.dart';
import '../../features/auth/presentation/screens/onboarding_level_screen.dart';
import '../../features/auth/presentation/screens/onboarding_welcome_screen.dart';
import '../../features/chat/presentation/screens/chat_tab.dart';
import '../../features/flashcards/presentation/screens/decks_tab.dart';
import '../../features/flashcards/presentation/screens/flashcard_screen.dart';
import '../../features/flashcards/presentation/screens/home_tab.dart';
import '../../features/stats/presentation/screens/stats_tab.dart';
import '../../shared/widgets/shell_scaffold.dart';
import '../constants/supabase_client.dart';

class _RouterNotifier extends ChangeNotifier {
  _RouterNotifier(this._ref) {
    _ref.listen<AsyncValue<UserEntity?>>(
      currentUserProvider,
      (_, next) {
        if (!next.isLoading) notifyListeners();
      },
    );
  }

  final Ref _ref;

  String? redirect(BuildContext context, GoRouterState state) {
    final session = supabase.auth.currentSession;
    final loc = state.matchedLocation;

    if (session == null) {
      if (!loc.startsWith('/onboarding')) return '/onboarding';
      return null;
    }

    final userAsync = _ref.read(currentUserProvider);
    if (userAsync.isLoading) return null;

    final user = userAsync.valueOrNull;
    if (user == null) {
      if (!loc.startsWith('/onboarding')) return '/onboarding';
      return null;
    }

    final destination = user.role == Role.admin ? '/admin' : '/home';

    if (loc.startsWith('/onboarding')) {
      if (loc == '/onboarding/level' && user.level == null) return null;
      return destination;
    }

    if (user.role == Role.admin && !loc.startsWith('/admin')) {
      return '/admin';
    }

    return null;
  }
}

final _routerNotifierProvider = ChangeNotifierProvider<_RouterNotifier>(
  (ref) => _RouterNotifier(ref),
);

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(_routerNotifierProvider);
  final hasSession = supabase.auth.currentSession != null;
  return GoRouter(
    refreshListenable: notifier,
    redirect: notifier.redirect,
    initialLocation: hasSession ? '/home' : '/onboarding',
    routes: [
      GoRoute(
        path: '/',
        redirect: (_, _) => '/onboarding',
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingWelcomeScreen(),
      ),
      GoRoute(
        path: '/onboarding/account',
        builder: (context, state) => const OnboardingAccountScreen(),
      ),
      GoRoute(
        path: '/onboarding/level',
        builder: (context, state) => const OnboardingLevelScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            ShellScaffold(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
                path: '/home',
                builder: (context, state) => const HomeTab()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
                path: '/decks',
                builder: (context, state) => const DecksTab()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
                path: '/chat',
                builder: (context, state) => const ChatTab()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
                path: '/stats',
                builder: (context, state) => const StatsTab()),
          ]),
        ],
      ),
      GoRoute(
        path: '/study/:deckId',
        builder: (context, state) =>
            FlashcardScreen(deckId: state.pathParameters['deckId']!),
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminScreen(),
      ),
    ],
  );
});
