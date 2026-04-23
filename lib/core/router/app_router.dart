import 'package:go_router/go_router.dart';
import '../../features/admin/presentation/screens/admin_screen.dart';
import '../../features/auth/presentation/screens/onboarding_account_screen.dart';
import '../../features/auth/presentation/screens/onboarding_level_screen.dart';
import '../../features/auth/presentation/screens/onboarding_welcome_screen.dart';
import '../../features/chat/presentation/screens/chat_tab.dart';
import '../../features/flashcards/presentation/screens/decks_tab.dart';
import '../../features/flashcards/presentation/screens/flashcard_screen.dart';
import '../../features/flashcards/presentation/screens/home_tab.dart';
import '../../features/stats/presentation/screens/stats_tab.dart';
import '../../shared/widgets/shell_scaffold.dart';

final appRouter = GoRouter(
  initialLocation: '/onboarding',
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
      builder: (context, state, navigationShell) => ShellScaffold(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(routes: [
          GoRoute(path: '/home', builder: (context, state) => const HomeTab()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/decks', builder: (context, state) => const DecksTab()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/chat', builder: (context, state) => const ChatTab()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/stats', builder: (context, state) => const StatsTab()),
        ]),
      ],
    ),
    GoRoute(
      path: '/study/:deckId',
      builder: (context, state) => FlashcardScreen(deckId: state.pathParameters['deckId']!),
    ),
    GoRoute(
      path: '/admin',
      builder: (context, state) => const AdminScreen(),
    ),
  ],
);
