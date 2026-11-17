// =============================================================================
// Widget raiz do aplicativo: tema visual e rotas nomeadas.
// =============================================================================

import 'package:material_ui/material_ui.dart';

import 'modules/history/page/history_page.dart';
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
      // Remove a faixa "DEBUG" do canto da tela.
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(),
      // O app sempre começa pela tela de abertura (splash), que depois
      // redireciona sozinha para a home.
      initialRoute: AppRoutes.initial,
      // Mapa "nome da rota -> tela". Os nomes ficam centralizados em
      // AppRoutes para evitar textos soltos pelo código.
      routes: {
        AppRoutes.initial: (_) => const InitialPage(),
        AppRoutes.home: (_) => const HomePage(),
        AppRoutes.history: (_) => const HistoryPage(),
      },
    );
  }

  /// Monta o tema do app a partir das cores (AppColors) e medidas
  /// (AppMetrics) compartilhadas. Assim os componentes do Material já nascem
  /// com a identidade visual da FastDelivery, sem precisar repetir estilos.
  ThemeData _buildTheme() {
    // Esquema de cores gerado a partir da cor principal da marca.
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      secondary: AppColors.accent,
      surface: AppColors.surface,
      error: AppColors.error,
    );

    // Formato arredondado usado nos botões.
    final roundedShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppMetrics.radiusM),
    );

    return ThemeData(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      // Barra superior azul com texto branco.
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        centerTitle: false,
        elevation: 0,
      ),
      // Cartões brancos, sem sombra e com borda clara.
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: AppMetrics.cardElevation,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppMetrics.radiusM),
          side: const BorderSide(color: AppColors.divider),
        ),
      ),
      // Botões principais ocupam a largura toda e têm altura confortável
      // para o uso com uma mão só, na rua.
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
      // Botão flutuante "Nova consulta" na cor de destaque (laranja).
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.textOnPrimary,
      ),
      // Campos de texto com fundo branco e borda arredondada.
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppMetrics.radiusM),
        ),
      ),
      // Avisos (SnackBar) flutuando acima do conteúdo.
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
