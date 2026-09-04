import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../core/theme/motion.dart';

/// M3 Expressive Scaffold with true Edge-to-Edge Bottom Navigation Bar
class ScaffoldWithNavBar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const ScaffoldWithNavBar({
    super.key,
    required this.navigationShell,
  });

  void _onTap(int index) {
    if (index != navigationShell.currentIndex) {
      HapticFeedback.lightImpact();
    }
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = navigationShell.currentIndex;
    final colorScheme = Theme.of(context).colorScheme;

    return PopScope(
      canPop: currentIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && currentIndex > 0) {
          _onTap(0);
        }
      },
      child: Scaffold(
        body: navigationShell,
        bottomNavigationBar: NavigationBarTheme(
          data: NavigationBarThemeData(
            elevation: 0,
            backgroundColor: colorScheme.surfaceContainerLow,
            indicatorColor: colorScheme.primaryContainer,
            labelTextStyle: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.primary,
                );
              }
              return TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurfaceVariant,
              );
            }),
            iconTheme: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return IconThemeData(
                  color: colorScheme.onPrimaryContainer,
                  size: 22,
                );
              }
              return IconThemeData(
                color: colorScheme.onSurfaceVariant,
                size: 22,
              );
            }),
          ),
          child: NavigationBar(
            selectedIndex: currentIndex,
            onDestinationSelected: _onTap,
            animationDuration: AppMotion.durationMedium2,
            destinations: const [
              NavigationDestination(
                icon: Icon(LucideIcons.house),
                selectedIcon: Icon(LucideIcons.house),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(LucideIcons.calendar),
                selectedIcon: Icon(LucideIcons.calendarDays),
                label: 'Calendar',
              ),
              NavigationDestination(
                icon: Icon(LucideIcons.bookmark),
                selectedIcon: Icon(LucideIcons.bookmarkCheck),
                label: 'Saved',
              ),
              NavigationDestination(
                icon: Icon(LucideIcons.user),
                selectedIcon: Icon(LucideIcons.circleUser),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
