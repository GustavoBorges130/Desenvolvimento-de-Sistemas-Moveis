import 'package:material_ui/material_ui.dart';

import '../../../routes/app_routes.dart';
import '../../../shared/colors/app_colors.dart';
import '../../../shared/metrics/app_metrics.dart';

/// Tela de abertura do FastLocation.
///
/// Exibe uma animação curta com a marca do app (o caminhão entra na tela e o
/// nome aparece em seguida) e redireciona automaticamente para a home.
class InitialPage extends StatefulWidget {
  const InitialPage({super.key});

  /// Duração da animação de entrada.
  static const Duration animationDuration = Duration(milliseconds: 1800);

  /// Tempo em que a marca fica parada na tela antes do redirecionamento.
  static const Duration holdDuration = Duration(milliseconds: 600);

  @override
  State<InitialPage> createState() => _InitialPageState();
}

class _InitialPageState extends State<InitialPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _truckSlide;
  late final Animation<double> _truckScale;
  late final Animation<double> _textOpacity;
  late final Animation<Offset> _textSlide;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: InitialPage.animationDuration,
    );

    _truckSlide = Tween<Offset>(
      begin: const Offset(-2.5, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.55, curve: Curves.easeOutBack),
      ),
    );

    _truckScale = Tween<double>(begin: 0.6, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.35, 0.7, curve: Curves.elasticOut),
      ),
    );

    _textOpacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.55, 1, curve: Curves.easeIn),
    );

    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.55, 1, curve: Curves.easeOut),
      ),
    );

    _startAndRedirect();
  }

  Future<void> _startAndRedirect() async {
    await _controller.forward();
    await Future<void>.delayed(InitialPage.holdDuration);

    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(AppRoutes.home);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            SlideTransition(
              position: _truckSlide,
              child: ScaleTransition(
                scale: _truckScale,
                child: Container(
                  padding: const EdgeInsets.all(AppMetrics.spaceXL),
                  decoration: const BoxDecoration(
                    color: AppColors.accent,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.local_shipping_rounded,
                    size: AppMetrics.iconXL,
                    color: AppColors.textOnPrimary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppMetrics.spaceXL),
            FadeTransition(
              opacity: _textOpacity,
              child: SlideTransition(
                position: _textSlide,
                child: Column(
                  children: [
                    Text(
                      'FastLocation',
                      style: textTheme.headlineMedium?.copyWith(
                        color: AppColors.textOnPrimary,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: AppMetrics.spaceS),
                    Text(
                      'Consulta de CEP e endereços',
                      style: textTheme.bodyLarge?.copyWith(
                        color: AppColors.primaryLight,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            FadeTransition(
              opacity: _textOpacity,
              child: Padding(
                padding: const EdgeInsets.only(bottom: AppMetrics.spaceXL),
                child: Text(
                  'FastDelivery',
                  style: textTheme.labelLarge?.copyWith(
                    color: AppColors.primaryLight,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
