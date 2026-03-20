import 'package:flutter/material.dart';

class SpellFilter extends StatefulWidget {
  final String? initialClass;
  final String? initialSchool;
  final int? initialLevel;
  final bool initialOnlyCustom;
  final Function(String?, String?, int?, bool) onApply;

  const SpellFilter({
    super.key,
    this.initialClass,
    this.initialSchool,
    this.initialLevel,
    this.initialOnlyCustom = false,
    required this.onApply,
  });

  @override
  State<SpellFilter> createState() => _SpellFilterState();
}

class _SpellFilterState extends State<SpellFilter> {
  String? selectedClass;
  String? selectedSchool;
  int? selectedLevel;
  bool onlyCustom = false;

  @override
  void initState() {
    super.initState();
    selectedClass = widget.initialClass;
    selectedSchool = widget.initialSchool;
    selectedLevel = widget.initialLevel;
    onlyCustom = widget.initialOnlyCustom;
  }

  final classes = [
    'wizard',
    'cleric',
    'druid',
    'paladin',
    'bard',
    'sorcerer',
    'warlock',
    'ranger',
  ];

  final schools = [
    'evocation',
    'necromancy',
    'illusion',
    'conjuration',
    'abjuration',
    'transmutation',
    'divination',
    'enchantment',
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Filtros',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 16),
              const Text('Classe'),
              Wrap(
                spacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('Custom'),
                    selected: onlyCustom, // Ele é controlado pela variável bool
                    selectedColor: Colors.purpleAccent.withValues(
                      alpha: 0.4,
                    ), // Cor de destaque para diferenciar
                    onSelected: (selected) {
                      setState(() {
                        onlyCustom = selected;
                        // Se eu selecionei "Custom", talvez queira desmarcar a classe da API
                        if (selected) selectedClass = null;
                      });
                    },
                  ),

                  ...classes.map((c) {
                    return ChoiceChip(
                      label: Text(c),
                      selected: selectedClass == c,
                      onSelected: (_) {
                        setState(() {
                          selectedClass = c;
                        });
                      },
                    );
                  }).toList(),
                ],
              ),

              const SizedBox(height: 16),
              const Text('Escola'),
              Wrap(
                spacing: 8,
                children: schools.map((s) {
                  return ChoiceChip(
                    label: Text(s),
                    selected: selectedSchool == s,
                    onSelected: (_) {
                      setState(() {
                        selectedSchool = s;
                      });
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 16),
              const Text('Nível'),
              DropdownButton<int>(
                isExpanded: true,
                value: selectedLevel,
                hint: const Text('Qualquer nível'),
                items: List.generate(
                  10,
                  (i) => DropdownMenuItem(
                    value: i,
                    child: Text('Nível $i'),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    selectedLevel = value;
                  });
                },
              ),

              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          selectedClass = null;
                          selectedSchool = null;
                          selectedLevel = null;
                          onlyCustom = false;
                        });
                      },
                      child: const Text('Limpar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        widget.onApply(
                          selectedClass,
                          selectedSchool,
                          selectedLevel,
                          onlyCustom,
                        );
                        Navigator.pop(context);
                      },
                      child: const Text('Aplicar'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
