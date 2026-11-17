// =============================================================================
// Passo 04 do desafio - modules/initial/page:
// "criar a classe que define a tela de inicialização do aplicativo:
//  - implementar redirecionamento automático para a home do aplicativo;
//  - implementar animação da tela."
// =============================================================================

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

// SingleTickerProviderStateMixin fornece o "relógio" (ticker) que faz o
// AnimationController avançar a cada quadro desenhado na tela.
class _InitialPageState extends State<InitialPage>
    with SingleTickerProviderStateMixin {
  /// Controla o tempo da animação (vai de 0.0 a 1.0 em [animationDuration]).
  late final AnimationController _controller;

  /// Caminhão deslizando da esquerda para o centro.
  late final Animation<Offset> _truckSlide;

  /// Caminhão "pulando" de tamanho ao chegar no centro.
  late final Animation<double> _truckScale;

  /// Nome do app aparecendo (transparência de 0 a 1).
  late final Animation<double> _textOpacity;

  /// Nome do app subindo levemente enquanto aparece.
  late final Animation<Offset> _textSlide;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: InitialPage.animationDuration,
    );

    // Cada animação usa um "Interval", que define em qual trecho do tempo
    // total ela acontece (0.0 = início, 1.0 = fim). Assim os efeitos
    // acontecem em sequência usando um único controller.

    // 0% a 55%: caminhão entra pela esquerda, passa um pouco do centro e
    // volta (curva easeOutBack).
    _truckSlide = Tween<Offset>(
      begin: const Offset(-2.5, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.55, curve: Curves.easeOutBack),
      ),
    );

    // 35% a 70%: caminhão cresce com efeito de mola (elasticOut).
    _truckScale = Tween<double>(begin: 0.6, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.35, 0.7, curve: Curves.elasticOut),
      ),
    );

    // 55% a 100%: textos aparecem...
    _textOpacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.55, 1, curve: Curves.easeIn),
    );

    // ...e sobem um pouco ao mesmo tempo.
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

  /// Executa a animação e, ao terminar, abre a home.
  Future<void> _startAndRedirect() async {
    // forward() roda a animação do início ao fim; o await espera terminar.
    await _controller.forward();
    // Deixa a marca parada por um instante para o usuário vê-la.
    await Future<void>.delayed(InitialPage.holdDuration);

    // Se a tela foi fechada nesse meio-tempo, não navega.
    if (!mounted) return;

    // pushReplacementNamed troca a splash pela home; assim o botão "voltar"
    // do Android não retorna para a tela de abertura.
    Navigator.of(context).pushReplacementNamed(AppRoutes.home);
  }

  @override
  void dispose() {
    // Libera o controller da animação para não desperdiçar memória.
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
            // Os dois Spacer() centralizam a marca na vertical.
            const Spacer(),

            // Caminhão: desliza (SlideTransition) e cresce (ScaleTransition).
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

            // Nome e descrição do app: aparecem (FadeTransition) e sobem
            // (SlideTransition).
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

            // Nome da empresa no rodapé.
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
