import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/motion.dart';
import '../features/about/about_screen.dart';
import '../features/announcements/ai_announcement_creator_screen.dart';
import '../features/auth/auth_screen.dart';
import '../features/calendar/calendar_screen.dart';
import '../features/event_details/event_details_screen.dart';
import '../features/feed/feed_screen.dart';
import '../features/notifications/notifications_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/privacy/privacy_policy_screen.dart';
import '../features/profile/edit_academic_profile_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/saved/saved_screen.dart';
import '../features/search/search_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/splash/splash_screen.dart';
import 'scaffold_with_nav_bar.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final _feedNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'feedNav');
final _calendarNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'calendarNav');
final _savedNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'savedNav');
final _profileNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'profileNav');

CustomTransitionPage<void> _buildSpringTransitionPage({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: AppMotion.durationMedium3,
    reverseTransitionDuration: AppMotion.durationMedium2,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curvedAnim = CurvedAnimation(
        parent: animation,
        curve: AppMotion.spring,
        reverseCurve: AppMotion.emphasizedAccelerate,
      );

      final slideAnim = Tween<Offset>(
        begin: const Offset(0.04, 0),
        end: Offset.zero,
      ).animate(curvedAnim);

      return FadeTransition(
        opacity: CurvedAnimation(
          parent: animation,
          curve: AppMotion.emphasizedDecelerate,
        ),
        child: SlideTransition(
          position: slideAnim,
          child: child,
        ),
      );
    },
  );
}

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/splash',
    routes: [
      // Top Level Route: Splash Screen
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // Top Level Route: Auth / Sign In
      GoRoute(
        path: '/auth',
        name: 'auth',
        pageBuilder: (context, state) => _buildSpringTransitionPage(
          context: context,
          state: state,
          child: const AuthScreen(),
        ),
      ),

      // Top Level Route: Onboarding Wizard
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        pageBuilder: (context, state) => _buildSpringTransitionPage(
          context: context,
          state: state,
          child: const OnboardingScreen(),
        ),
      ),

      // Top Level Route: Search Screen
      GoRoute(
        path: '/search',
        name: 'search',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) => MaterialPage<void>(
          key: state.pageKey,
          child: const SearchScreen(),
        ),
      ),

      // Top Level Route: Notifications Screen
      GoRoute(
        path: '/notifications',
        name: 'notifications',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) => MaterialPage<void>(
          key: state.pageKey,
          child: const NotificationsScreen(),
        ),
      ),

      // Top Level Route: Settings
      GoRoute(
        path: '/settings',
        name: 'settings',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) => MaterialPage<void>(
          key: state.pageKey,
          child: const SettingsScreen(),
        ),
      ),

      // Top Level Route: About Screen
      GoRoute(
        path: '/about',
        name: 'about',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) => MaterialPage<void>(
          key: state.pageKey,
          child: const AboutScreen(),
        ),
      ),

      // Top Level Route: Privacy Policy & Terms
      GoRoute(
        path: '/privacy-policy',
        name: 'privacy-policy',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) => MaterialPage<void>(
          key: state.pageKey,
          child: const PrivacyPolicyScreen(),
        ),
      ),

      // Top Level Route: Event Details
      GoRoute(
        path: '/event/:id',
        name: 'event-details',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) {
          final eventId = state.pathParameters['id'] ?? '';
          return MaterialPage<void>(
            key: state.pageKey,
            child: EventDetailsScreen(eventId: eventId),
          );
        },
      ),

      // Top Level Route: AI Announcement Studio / Opportunity Creator
      GoRoute(
        path: '/create-announcement',
        name: 'create-announcement',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) {
          final initialCategory =
              state.uri.queryParameters['category'] ?? 'hackathon';
          return MaterialPage<void>(
            key: state.pageKey,
            child: AiAnnouncementCreatorScreen(initialCategory: initialCategory),
          );
        },
      ),

      // Top Level Route: Edit Academic Profile
      GoRoute(
        path: '/edit-profile',
        name: 'edit-profile',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) => MaterialPage<void>(
          key: state.pageKey,
          child: const EditAcademicProfileScreen(),
        ),
      ),

      // StatefulShellRoute with 4 Bottom Navigation Bar Branches
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithNavBar(navigationShell: navigationShell);
        },
        branches: [
          // 1. Home / Feed Branch
          StatefulShellBranch(
            navigatorKey: _feedNavigatorKey,
            routes: [
              GoRoute(
                path: '/feed',
                name: 'feed',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: FeedScreen(),
                ),
              ),
            ],
          ),

          // 2. Calendar Branch
          StatefulShellBranch(
            navigatorKey: _calendarNavigatorKey,
            routes: [
              GoRoute(
                path: '/calendar',
                name: 'calendar',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: CalendarScreen(),
                ),
              ),
            ],
          ),

          // 3. Saved Branch
          StatefulShellBranch(
            navigatorKey: _savedNavigatorKey,
            routes: [
              GoRoute(
                path: '/saved',
                name: 'saved',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: SavedScreen(),
                ),
              ),
            ],
          ),

          // 4. Profile Branch
          StatefulShellBranch(
            navigatorKey: _profileNavigatorKey,
            routes: [
              GoRoute(
                path: '/profile',
                name: 'profile',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: ProfileScreen(),
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
