import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/theme_controller.dart';
import 'router.dart';

class CampusSignalApp extends ConsumerWidget {
  const CampusSignalApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeSettings = ref.watch(themeControllerProvider);

    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        final ColorScheme? lightScheme =
            themeSettings.useMaterialYou ? lightDynamic : null;
        final ColorScheme? darkScheme =
            themeSettings.useMaterialYou ? darkDynamic : null;

        return MaterialApp.router(
          title: 'CampusSignal',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.buildTheme(
            brightness: Brightness.light,
            colorScheme: lightScheme,
          ),
          darkTheme: AppTheme.buildTheme(
            brightness: Brightness.dark,
            colorScheme: darkScheme,
          ),
          themeMode: themeSettings.themeMode,
          routerConfig: router,
        );
      },
    );
  }
}
