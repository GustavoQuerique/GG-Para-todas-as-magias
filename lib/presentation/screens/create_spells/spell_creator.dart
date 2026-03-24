///Dentro dos campos de preencher, devo adicionar profundiade, para melhor visualizar

import 'package:flutter/material.dart';
import 'package:guia_de_garlou_para_todas_as_magias/domain/models/spell_model.dart';
import 'package:hive/hive.dart';
import 'dart:math' as math;

enum RitualStep { core, school, mechanics, description }

const _nodes = <RitualStep, ({IconData icon, String label})>{
  RitualStep.description: (icon: Icons.menu_book_rounded, label: 'Arc'),
  RitualStep.school: (icon: Icons.school_rounded, label: 'School'),
  RitualStep.mechanics: (icon: Icons.timer_rounded, label: 'Mechanics'),
  RitualStep.core: (icon: Icons.auto_fix_high, label: 'Core'),
};

///TODO: fazer com que seja animado e se mova envolta do core
// Posições angulares dos nós (graus, 0 = topo, sentido horário)
const _nodeAngles = <RitualStep, double>{
  RitualStep.description: -90,
  RitualStep.school: 0,
  RitualStep.mechanics: 90,
  RitualStep.core: 180,
};

class SpellCreator extends StatefulWidget {
  const SpellCreator({super.key});
  @override
  State<SpellCreator> createState() => _SpellCreatorState();
}

class _SpellCreatorState extends State<SpellCreator>
    with SingleTickerProviderStateMixin {
  RitualStep _currentStep = RitualStep.description;

  final _formKey = GlobalKey<FormState>();
  final _nameCon = TextEditingController();
  final _descCon = TextEditingController();
  final _rangeCon = TextEditingController();
  final _durationCon = TextEditingController();

  String _school = 'Evocação';
  int _level = 0;
  bool _conc = false;

  late final AnimationController _pulse;
  late final Animation<double> _pulseAnim;

  final _schools = const [
    'Abjuração',
    'Conjuração',
    'Divinação',
    'Encantamento',
    'Evocação',
    'Ilusão',
    'Necromancia',
    'Transmutação',
  ];

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _pulseAnim = Tween(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulse.dispose();
    _nameCon.dispose();
    _descCon.dispose();
    _rangeCon.dispose();
    _durationCon.dispose();
    super.dispose();
  }

  // Lógica de salvar — intacta
  Future<void> _savedSpell() async {
    if (!_formKey.currentState!.validate()) return;

    final spellBox = Hive.box<SpellModel>('spells');

    final desc = _descCon.text.trim();
    final descList = desc.isNotEmpty
        ? desc
              .split('\n\n')
              .map((p) => p.trim())
              .where((p) => p.isNotEmpty)
              .toList()
        : <String>[];

    final spell = SpellModel(
      index: 'custom_${DateTime.now().millisecondsSinceEpoch}',
      name: _nameCon.text.trim(),
      school: _school,
      level: _level,
      range: _rangeCon.text.trim(),
      concentration: _conc,
      duration: _durationCon.text.trim(),
      description: descList,
    );

    await spellBox.put(spell.index, spell);
    if (mounted) Navigator.pop(context, true);
  }

  // Atalhos de tema
  ColorScheme get _cs => Theme.of(context).colorScheme;
  TextTheme get _tt => Theme.of(context).textTheme;

  Color get _gold => _cs.secondary;
  Color get _primary => _cs.primary;
  Color get _surface => _cs.surface;
  Color get _dim => _tt.bodyMedium!.color!;
  Color get _divider => Theme.of(context).dividerColor;

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      // Desliga o resize automático — controlamos o espaço manualmente
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: AnimatedPadding(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          // Empurra o conteúdo para cima exatamente o tamanho do teclado
          padding: EdgeInsets.only(bottom: keyboardHeight),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildHeader(),
                if (keyboardHeight == 0) _buildOrbit(),
                const SizedBox(height: 8),
                Expanded(child: _buildPanel()),
                _buildSubmitButton(),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back_ios_new, color: _dim, size: 18),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          Text(
            'Criação de Magia',
            style: _tt.headlineLarge!.copyWith(
              fontSize: 26,
              letterSpacing: 0.5,
              shadows: [
                Shadow(color: _gold.withValues(alpha: 0.5), blurRadius: 20),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Sincronize seus pensamentos com o Aether.',
            style: _tt.bodyMedium!.copyWith(fontSize: 12, letterSpacing: 0.3),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  // orbitR: raio do anel | total: tamanho do Stack (deve ser ≥ orbitR*2 + nodeSize)
  Widget _buildOrbit() {
    const orbitR = 105.0;
    const total = 300.0;

    return SizedBox(
      width: total,
      height: total,
      child: Stack(
        alignment: Alignment.center,
        children: [
          _OrbitRing(
            radius: orbitR,
            pulseAnim: _pulseAnim,
            color: _gold,
            dimColor: _dim,
          ),
          _coreNode(),
          for (final entry in _nodeAngles.entries)
            _positionedNode(entry.key, entry.value, orbitR, total),
        ],
      ),
    );
  }

  Widget _positionedNode(
    RitualStep step,
    double angleDeg,
    double orbitR,
    double total,
  ) {
    final rad = angleDeg * math.pi / 180;
    final cx = total / 2 + orbitR * math.cos(rad);
    final cy = total / 2 + orbitR * math.sin(rad);
    const nodeSize = 52.0;

    return Positioned(
      left: cx - nodeSize / 2,
      top: cy - nodeSize / 2,
      child: _orbitNode(step, nodeSize),
    );
  }

  // coreSize: tamanho do círculo central
  Widget _coreNode() {
    const coreSize = 100.0;

    return AnimatedBuilder(
      animation: _pulseAnim,
      builder: (_, __) => GestureDetector(
        onTap: () => setState(() => _currentStep = RitualStep.core),
        child: Container(
          width: coreSize,
          height: coreSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _surface,
            border: Border.all(color: _gold, width: 2),
            boxShadow: [
              BoxShadow(
                color: _gold.withValues(alpha: 0.25 * _pulseAnim.value),
                blurRadius: 30,
                spreadRadius: 4,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.auto_fix_high, color: _gold, size: 30),
              const SizedBox(height: 3),
              Text(
                'CORE',
                style: _tt.labelLarge!.copyWith(
                  fontSize: 8,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _orbitNode(RitualStep step, double size) {
    final info = _nodes[step]!;
    final isActive = _currentStep == step;

    return GestureDetector(
      onTap: () => setState(() => _currentStep = step),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isActive ? _gold.withValues(alpha: 0.15) : _surface,
          border: Border.all(
            color: isActive ? _gold : _dim,
            width: isActive ? 2.0 : 1.5,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: _gold.withValues(alpha: 0.35),
                    blurRadius: 16,
                    spreadRadius: 2,
                  ),
                ]
              : [],
        ),
        child: Icon(info.icon, color: isActive ? _gold : _dim, size: 22),
      ),
    );
  }

  Widget _buildPanel() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      transitionBuilder: (child, anim) =>
          FadeTransition(opacity: anim, child: child),
      child: _panelContent(),
    );
  }

  Widget _panelContent() {
    return Container(
      key: ValueKey(_currentStep),
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
            child: _styledTag(_stepLabel(_currentStep)),
          ),
          Divider(color: _divider, height: 1),
          // Expanded garante que o conteúdo preenche sem overflow
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(14),
              child: _buildStepFields(),
            ),
          ),
        ],
      ),
    );
  }

  String _stepLabel(RitualStep s) {
    switch (s) {
      case RitualStep.core:
        return 'NOME DA MAGIA';
      case RitualStep.school:
        return 'ESCOLA & LEVEL';
      case RitualStep.mechanics:
        return 'MECÂNICAS';
      case RitualStep.description:
        return 'DESCRIÇÃO DA MAGIA';
    }
  }

  Widget _styledTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: _dim),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: _tt.bodyMedium!.copyWith(fontSize: 10, letterSpacing: 1.5),
      ),
    );
  }

  Widget _buildStepFields() {
    switch (_currentStep) {
      case RitualStep.core:
        return _grimField(
          controller: _nameCon,
          hint: 'De um nome a sua criação...',
          validator: (v) => (v == null || v.isEmpty) ? 'Informe um Nome' : null,
        );
      case RitualStep.school:
        return _schoolFields();
      case RitualStep.mechanics:
        return _mechanicsFields();
      case RitualStep.description:
        return _grimField(
          controller: _descCon,
          hint: 'Sussurre o efeito para o Aether',
          // minLines deixa o campo com altura inicial razoável;
          // maxLines null permite crescer sem limite conforme o texto
          minLines: 8,
          maxLines: null,
          validator: (v) =>
              (v == null || v.isEmpty) ? 'Informe uma descrição' : null,
        );
    }
  }

  // Campo alinhado ao topo, sem altura fixa — cresce com o conteúdo
  Widget _grimField({
    required TextEditingController controller,
    required String hint,
    String? Function(String?)? validator,
    int? minLines,
    int? maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      minLines: minLines,
      maxLines: maxLines,
      validator: validator,
      style: _tt.bodyLarge,
      cursorColor: _gold,
      textAlignVertical: TextAlignVertical.top,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: _tt.bodyMedium,
        border: InputBorder.none,
        isDense: true,
        contentPadding: EdgeInsets.zero,
      ),
    );
  }

  Widget _schoolFields() {
    final underline = UnderlineInputBorder(
      borderSide: BorderSide(color: _divider),
    );
    final focused = UnderlineInputBorder(borderSide: BorderSide(color: _gold));
    final dec = InputDecoration(
      labelStyle: _tt.bodyMedium,
      enabledBorder: underline,
      focusedBorder: focused,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          initialValue: _school,
          dropdownColor: _surface,
          style: _tt.bodyLarge,
          icon: Icon(Icons.expand_more, color: _dim),
          decoration: dec.copyWith(labelText: 'Escola'),
          items: _schools
              .map((s) => DropdownMenuItem(value: s, child: Text(s)))
              .toList(),
          onChanged: (v) => setState(() => _school = v!),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<int>(
          initialValue: _level,
          dropdownColor: _surface,
          style: _tt.bodyLarge,
          icon: Icon(Icons.expand_more, color: _dim),
          decoration: dec.copyWith(labelText: 'Nível'),
          items: List.generate(
            10,
            (i) => DropdownMenuItem(
              value: i,
              child: Text(i == 0 ? 'Truque' : 'Nível $i'),
            ),
          ),
          onChanged: (v) => setState(() => _level = v!),
        ),
      ],
    );
  }

  Widget _mechanicsFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Cada _mechField em seu próprio Expanded dentro de uma Row intrínseca
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _mechField(_rangeCon, 'Alcance', Icons.gps_fixed),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: _mechField(
                  _durationCon,
                  'Duração',
                  Icons.timer_outlined,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Icon(Icons.blur_circular_sharp, color: _dim, size: 18),
            const SizedBox(width: 8),
            Text('Concentração', style: _tt.bodyMedium),
            const Spacer(),
            Switch(
              value: _conc,
              onChanged: (v) => setState(() => _conc = v),
              activeThumbColor: _gold,
              inactiveTrackColor: _divider,
            ),
          ],
        ),
      ],
    );
  }

  // Campo de mecânica: label + ícone acima, campo de texto abaixo — sem prefixIcon
  Widget _mechField(TextEditingController con, String label, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: _dim, size: 15),
            const SizedBox(width: 4),
            Text(label, style: _tt.bodyMedium!.copyWith(fontSize: 11)),
          ],
        ),
        TextFormField(
          controller: con,
          style: _tt.bodyLarge,
          cursorColor: _gold,
          textAlignVertical: TextAlignVertical.top,
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.only(top: 8, bottom: 4),
            border: InputBorder.none,
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: _divider),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: _gold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: _savedSpell,
        child: AnimatedBuilder(
          animation: _pulseAnim,
          builder: (_, __) => Container(
            height: 54,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: [_primary.withValues(alpha: 0.8), _primary],
              ),
              border: Border.all(
                color: _gold.withValues(alpha: 0.6),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: _primary.withValues(alpha: 0.35 * _pulseAnim.value),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.menu_book_rounded, color: _gold, size: 20),
                const SizedBox(width: 10),
                Text(
                  'SALVAR MAGIA',
                  style: _tt.labelLarge!.copyWith(
                    fontSize: 14,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Anel orbital com traços animados
class _OrbitRing extends StatelessWidget {
  final double radius;
  final Animation<double> pulseAnim;
  final Color color;
  final Color dimColor;

  const _OrbitRing({
    required this.radius,
    required this.pulseAnim,
    required this.color,
    required this.dimColor,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulseAnim,
      builder: (_, __) => CustomPaint(
        size: Size(radius * 2 + 20, radius * 2 + 20),
        painter: _RingPainter(radius, pulseAnim.value, color, dimColor),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double radius;
  final double pulse;
  final Color gold;
  final Color dim;

  _RingPainter(this.radius, this.pulse, this.gold, this.dim);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    final dashPaint = Paint()
      ..color = dim.withValues(alpha: 0.4 * pulse)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    _drawDashedCircle(canvas, center, radius, dashPaint);

    final glowPaint = Paint()
      ..color = gold.withValues(alpha: 0.06 * pulse)
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawCircle(center, radius, glowPaint);
  }

  void _drawDashedCircle(Canvas c, Offset center, double r, Paint p) {
    const dashCount = 48;
    const dashAngle = math.pi / dashCount;
    for (var i = 0; i < dashCount * 2; i += 2) {
      final start = i * dashAngle;
      final end = (i + 1) * dashAngle;
      c.drawArc(
        Rect.fromCircle(center: center, radius: r),
        start,
        end - start,
        false,
        p,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.pulse != pulse;
}
