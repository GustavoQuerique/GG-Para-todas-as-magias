import 'package:flutter/material.dart';
import 'package:guia_de_garlou_para_todas_as_magias/data/datasources/local/api_cache_service.dart';
import 'package:guia_de_garlou_para_todas_as_magias/data/repositories/class_repository.dart';
import 'package:guia_de_garlou_para_todas_as_magias/data/repositories/races_repository.dart';
import 'package:guia_de_garlou_para_todas_as_magias/data/repositories/spell_repository.dart';
import 'package:guia_de_garlou_para_todas_as_magias/presentation/screens/spells/spell_list_page.dart';
import 'package:lottie/lottie.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _zoomAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Configuração das animações de transição
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _zoomAnimation = Tween<double>(begin: 1.0, end: 5.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutQuart),
    );

    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _startLoading();
  }

  Future<void> _startLoading() async {
    // Inicializa o serviço de cache que você já tem
    final apiCacheService = ApiCacheService(
      classRepository: ClassRepository(),
      spellRepository: SpellRepository(),
      raceRepository: RacesRepository(),
    );

    // Aguarda o download das magias/classes/raças
    await apiCacheService.initializeCache();

    // Quando terminar, inicia a animação de Zoom/Fade
    if (mounted) {
      await _controller.forward();
      _navigateToHome();
    }
  }

  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const SpellListPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // Transição suave de Fade para a nova tela
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212), // Cor escura do seu tema
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeAnimation.value,
            child: Transform.scale(
              scale: _zoomAnimation.value,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 300,
                      height: 300,
                      child: Lottie.asset(
                        'assets/lottie/poetry.json',
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Invocando Grimório...",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white70,
                        fontStyle: FontStyle.italic,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
