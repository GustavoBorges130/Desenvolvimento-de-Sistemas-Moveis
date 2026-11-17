import 'package:material_ui/material_ui.dart';

import 'modules/home/page/home_page.dart';
import 'modules/initial/page/initial_page.dart';
import 'routes/app_routes.dart';
import 'shared/colors/app_colors.dart';
import 'shared/metrics/app_metrics.dart';

/// Widget raiz do aplicativo: define tema, rotas e a tela inicial.
class AppWidget extends StatelessWidget {
  const AppWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FastLocation',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(),
      initialRoute: AppRoutes.initial,
      routes: {
        AppRoutes.initial: (_) => const InitialPage(),
        AppRoutes.home: (_) => const HomePage(),
      },
    );
  }

  ThemeData _buildTheme() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      secondary: AppColors.accent,
      surface: AppColors.surface,
      error: AppColors.error,
    );

    final roundedShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppMetrics.radiusM),
    );

    return ThemeData(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        centerTitle: false,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: AppMetrics.cardElevation,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppMetrics.radiusM),
          side: const BorderSide(color: AppColors.divider),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(AppMetrics.buttonHeight),
          shape: roundedShape,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(AppMetrics.buttonHeight),
          shape: roundedShape,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.textOnPrimary,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppMetrics.radiusM),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
