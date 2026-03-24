// lib/presentation/pages/spell_detail_page.dart
//
// Substitui a SpellDetailPage anterior.
// Mantém TODA a lógica original intacta:
//   • Recebe spellIndex, carrega via SpellRepository ou Hive (custom_*)
//   • FavoritesService para favoritar/desfavoritar
//   • CircularActionMenu com delete para magias customizadas
//
// O que mudou: apenas o visual do build().

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:guia_de_garlou_para_todas_as_magias/data/datasources/local/favorites_service.dart';
import 'package:guia_de_garlou_para_todas_as_magias/data/repositories/spell_repository.dart';
import 'package:guia_de_garlou_para_todas_as_magias/domain/models/spell_model.dart';
import 'package:guia_de_garlou_para_todas_as_magias/presentation/widgets/buttons/action_button.dart';
import 'package:guia_de_garlou_para_todas_as_magias/presentation/widgets/buttons/circular_action_menu.dart';
import 'package:hive/hive.dart';

// ─── Paleta ───────────────────────────────────────────────────────────────────
class _C {
  static const bg = Color(0xFF131313);
  static const primary = Color(0xFFF1C97D);
  static const primaryDim = Color(0xFFD4AD65);
  static const surfaceLow = Color(0xFF1C1B1B);
  static const surface = Color(0xFF201F1F);
  static const surfaceLowest = Color(0xFF0E0E0E);
  static const surfaceHighest = Color(0xFF353534);
  static const onSurface = Color(0xFFE5E2E1);
  static const onSurfaceVar = Color(0xFFD0C5AF);
  static const outlineVar = Color(0xFF4D4635);

  static Color school(String s) {
    switch (s.toLowerCase()) {
      case 'evocation':
        return const Color(0xFF10B981);
      case 'abjuration':
        return const Color(0xFF60A5FA);
      case 'illusion':
        return const Color(0xFFA78BFA);
      case 'necromancy':
        return const Color(0xFF6EE7B7);
      case 'conjuration':
        return const Color(0xFFFBBF24);
      case 'divination':
        return const Color(0xFF93C5FD);
      case 'enchantment':
        return const Color(0xFFF472B6);
      case 'transmutation':
        return const Color(0xFFFCA5A5);
      default:
        return const Color(0xFFD0C5AF);
    }
  }

  static Color schoolBg(String s) => school(s).withOpacity(0.12);
  static Color schoolBorder(String s) => school(s).withOpacity(0.30);
}

// ─── Page ─────────────────────────────────────────────────────────────────────
class SpellDetailPage extends StatefulWidget {
  final String spellIndex;

  const SpellDetailPage({super.key, required this.spellIndex});

  @override
  State<SpellDetailPage> createState() => _SpellDetailPageState();
}

class _SpellDetailPageState extends State<SpellDetailPage>
    with SingleTickerProviderStateMixin {
  // ── serviços (mesmo que antes) ────────────────────────────────────────────
  final favoritesService = FavoritesService();
  final SpellRepository spellRepository = SpellRepository();

  SpellModel? spell;
  bool isFavorite = false;
  bool isLoading = true;

  // ── animação do glifo ─────────────────────────────────────────────────────
  late final AnimationController _rotCtrl;

  @override
  void initState() {
    super.initState();
    _rotCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
    loadSpell();
  }

  @override
  void dispose() {
    _rotCtrl.dispose();
    super.dispose();
  }

  // ── lógica original de carregamento ──────────────────────────────────────
  Future<void> loadSpell() async {
    try {
      SpellModel? loaded;

      if (widget.spellIndex.startsWith('custom_')) {
        final box = Hive.box<SpellModel>('spells');
        loaded = box.get(widget.spellIndex);
      } else {
        loaded = await spellRepository.getSpellByIndex(widget.spellIndex);
      }

      if (!mounted) return;
      setState(() {
        spell = loaded;
        isFavorite =
            loaded != null && favoritesService.isFavorite(loaded.index);
        isLoading = false;
      });
    } catch (e, stack) {
      debugPrint('Erro ao carregar magia: $e');
      debugPrintStack(stackTrace: stack);
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  // ── lógica original de favorito ───────────────────────────────────────────
  void _toggleFavorite() {
    final s = spell!;
    if (isFavorite) {
      favoritesService.removeFavorite(s.index);
    } else {
      favoritesService.addFavorite(
        SpellModel(
          index: s.index,
          name: s.name,
          school: s.school,
          level: s.level,
          concentration: s.concentration,
        ),
      );
    }
    setState(() => isFavorite = !isFavorite);
  }

  // ── lógica original de delete ─────────────────────────────────────────────
  Future<void> _deleteSpell() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Deletar magia'),
        content: const Text(
          'Essa ação não pode ser desfeita. Deseja continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Deletar'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final box = Hive.box<SpellModel>('spells');
    await box.delete(spell!.index);
    favoritesService.removeFavorite(spell!.index);

    if (!mounted) return;
    Navigator.pop(context, true);
  }

  // ─────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: _C.bg,
        body: Center(
          child: CircularProgressIndicator(color: _C.primary),
        ),
      );
    }

    if (spell == null) {
      return Scaffold(
        backgroundColor: _C.bg,
        appBar: AppBar(backgroundColor: _C.bg),
        body: const Center(
          child: Text(
            'Erro ao carregar magia',
            style: TextStyle(color: _C.onSurface),
          ),
        ),
      );
    }

    final s = spell!;
    final sColor = _C.school(s.school);
    final isCustom = s.index.startsWith('custom_');

    return Scaffold(
      backgroundColor: _C.bg,
      body: Column(
        children: [
          // ── Top Bar ──────────────────────────────────────────────────────
          _TopBar(
            isFavorite: isFavorite,
            onBack: () => Navigator.maybePop(context),
            onFavorite: _toggleFavorite,
          ),

          // ── Conteúdo ──────────────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Glifo
                  _GlyphHero(
                    school: s.school,
                    schoolColor: sColor,
                    rotCtrl: _rotCtrl,
                  ),
                  const SizedBox(height: 26),

                  // Nome + badges
                  _SpellHeader(spell: s, schoolColor: sColor),
                  const SizedBox(height: 26),

                  // Grid de stats
                  _StatsGrid(spell: s),
                  const SizedBox(height: 28),

                  // Descrição
                  _DescriptionCard(spell: s),
                  const SizedBox(height: 24),

                  // Menu de delete para magias customizadas
                  if (isCustom)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularActionMenu(
                          actions: [
                            ActionButton(
                              icon: Icons.delete_outline,
                              label: 'Deletar Magia',
                              onTap: _deleteSpell,
                            ),
                          ],
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Top App Bar ──────────────────────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  final bool isFavorite;
  final VoidCallback onBack;
  final VoidCallback onFavorite;

  const _TopBar({
    required this.isFavorite,
    required this.onBack,
    required this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _C.bg,
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: onBack,
                    child: const Icon(
                      Icons.arrow_back_ios_new,
                      color: _C.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Text(
                      'DETALHES DA MAGIA',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: _C.primary,
                        letterSpacing: 2.5,
                      ),
                    ),
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: GestureDetector(
                      key: ValueKey(isFavorite),
                      onTap: onFavorite,
                      child: Icon(
                        isFavorite ? Icons.star : Icons.star_border,
                        color: _C.primary,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // linha divisória gradiente
            Container(
              height: 1,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    _C.outlineVar,
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Hero com Glifo Animado ───────────────────────────────────────────────────
class _GlyphHero extends StatelessWidget {
  final String school;
  final Color schoolColor;
  final AnimationController rotCtrl;

  const _GlyphHero({
    required this.school,
    required this.schoolColor,
    required this.rotCtrl,
  });

  static Widget _icon(String s, {required int size, required Color color}) {
    switch (s.toLowerCase()) {
      case 'evocation':
        return Icon(Icons.auto_fix_high, size: 54, color: color);
      case 'abjuration':
        return Icon(Icons.shield, size: 54, color: color);
      case 'illusion':
        return Icon(Icons.visibility_off, size: 54, color: color);
      case 'necromancy':
        return FaIcon(FontAwesomeIcons.skull, size: 54, color: color);
      case 'conjuration':
        return Icon(Icons.blur_on, size: 54, color: color);
      case 'divination':
        return Icon(Icons.remove_red_eye, size: 54, color: color);
      case 'enchantment':
        return Icon(Icons.favorite, size: 54, color: color);
      case 'transmutation':
        return Icon(Icons.transform, size: 54, color: color);
      default:
        return Icon(Icons.auto_awesome, size: 54, color: color);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 210,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _C.outlineVar.withOpacity(0.15)),
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 0.85,
          colors: [schoolColor.withOpacity(0.13), Colors.transparent],
        ),
      ),
      child: Center(
        child: SizedBox(
          width: 148,
          height: 148,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // anel tracejado girando
              AnimatedBuilder(
                animation: rotCtrl,
                builder: (_, child) => Transform.rotate(
                  angle: rotCtrl.value * 2 * math.pi,
                  child: child,
                ),
                child: CustomPaint(
                  size: const Size(148, 148),
                  painter: _DashedRing(color: schoolColor),
                ),
              ),
              // anel interno estático
              Container(
                width: 108,
                height: 108,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _C.primary.withOpacity(0.18),
                  ),
                ),
              ),
              // ícone da escola
              _icon((school), size: 54, color: schoolColor),
              // label da escola no topo
              Positioned(
                top: 6,
                child: Text(
                  school.toUpperCase(),
                  style: TextStyle(
                    fontSize: 8,
                    letterSpacing: 5,
                    color: schoolColor.withOpacity(0.4),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashedRing extends CustomPainter {
  final Color color;
  const _DashedRing({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.28)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    const n = 28;
    final r = size.width / 2 - 1;
    final c = Offset(size.width / 2, size.height / 2);
    const step = 2 * math.pi / n;

    for (int i = 0; i < n; i++) {
      canvas.drawArc(
        Rect.fromCircle(center: c, radius: r),
        i * step,
        step * 0.5,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

// ─── Cabeçalho: nome + badges ─────────────────────────────────────────────────
class _SpellHeader extends StatelessWidget {
  final SpellModel spell;
  final Color schoolColor;

  const _SpellHeader({required this.spell, required this.schoolColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          spell.name,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.w800,
            color: _C.primary,
            letterSpacing: -1,
            height: 1.05,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 6,
          children: [
            _Badge(
              label: spell.level == 0 ? 'Cantrip' : 'Nível ${spell.level}',
              bg: _C.surfaceHighest,
              fg: _C.onSurfaceVar,
            ),
            _Badge(
              label: spell.school,
              bg: _C.schoolBg(spell.school),
              fg: schoolColor,
              border: _C.schoolBorder(spell.school),
            ),
          ],
        ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;
  final Color? border;

  const _Badge({
    required this.label,
    required this.bg,
    required this.fg,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: border != null ? Border.all(color: border!) : null,
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          color: fg,
          letterSpacing: 2,
        ),
      ),
    );
  }
}

// ─── Grid de Stats ────────────────────────────────────────────────────────────
class _StatsGrid extends StatelessWidget {
  final SpellModel spell;
  const _StatsGrid({required this.spell});

  @override
  Widget build(BuildContext context) {
    // só exibe campos que existem no SpellModel atual
    final items = <(IconData, String, String)>[
      if (spell.range != null) (Icons.straighten, 'Alcance', spell.range!),
      if (spell.duration != null) (Icons.schedule, 'Duração', spell.duration!),
      (
        spell.concentration ? Icons.timer : Icons.timer_off,
        'Concentração',
        spell.concentration ? 'Sim' : 'Não',
      ),
      (
        Icons.menu_book,
        'Nível',
        spell.level == 0 ? 'Cantrip' : '${spell.level}º',
      ),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.5,
      children: items.map((t) {
        final (icon, label, value) = t;
        return Container(
          decoration: BoxDecoration(
            color: _C.surfaceLow,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: _C.outlineVar, size: 20),
              const SizedBox(height: 5),
              Text(
                label.toUpperCase(),
                style: const TextStyle(
                  fontSize: 8,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w800,
                  color: _C.onSurfaceVar,
                ),
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Text(
                  value,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    color: _C.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ─── Card de Descrição ────────────────────────────────────────────────────────
// Exibe todos os parágrafos de spell.description.
// O campo já contém tudo (desc + higher_level vêm concatenados pelo fromJson
// ou pelo que a API retornar) — sem nenhum tratamento extra aqui.
class _DescriptionCard extends StatelessWidget {
  final SpellModel spell;
  const _DescriptionCard({required this.spell});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _C.outlineVar.withOpacity(0.12)),
        boxShadow: const [
          BoxShadow(
            color: Colors.black38,
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // rótulo de seção
            const _SectionLabel(label: 'Descrição'),
            const SizedBox(height: 16),

            // parágrafos — o primeiro recebe drop cap
            if (spell.description.isEmpty)
              const Text(
                'Sem descrição disponível.',
                style: TextStyle(
                  color: _C.onSurfaceVar,
                  fontStyle: FontStyle.italic,
                ),
              )
            else
              ...spell.description.asMap().entries.map((e) {
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: e.key < spell.description.length - 1 ? 14 : 0,
                  ),
                  child: _DescParagraph(
                    text: e.value,
                    dropCap: e.key == 0,
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}

// Parágrafo com drop cap opcional
class _DescParagraph extends StatelessWidget {
  final String text;
  final bool dropCap;
  const _DescParagraph({required this.text, this.dropCap = false});

  static const _body = TextStyle(
    fontSize: 15,
    color: _C.onSurface,
    height: 1.72,
    fontWeight: FontWeight.w300,
    fontStyle: FontStyle.italic,
  );

  @override
  Widget build(BuildContext context) {
    if (!dropCap || text.isEmpty) return Text(text, style: _body);

    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: text[0],
            style: const TextStyle(
              fontSize: 46,
              color: _C.primary,
              height: 0.85,
              fontWeight: FontWeight.w300,
            ),
          ),
          TextSpan(text: text.substring(1), style: _body),
        ],
      ),
    );
  }
}

// ─── Rótulo de seção ──────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 9,
            letterSpacing: 3,
            fontWeight: FontWeight.w800,
            color: _C.primaryDim,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            height: 1,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [_C.outlineVar, Colors.transparent],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
