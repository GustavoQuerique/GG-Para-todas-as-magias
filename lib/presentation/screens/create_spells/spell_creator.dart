import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:guia_de_garlou_para_todas_as_magias/domain/models/spell_model.dart';
import 'package:hive/hive.dart';

class SpellCreator extends StatefulWidget {
  const SpellCreator({super.key});

  @override
  State<SpellCreator> createState() => _SpellCreatorState();
}

class _SpellCreatorState extends State<SpellCreator> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _rangeController = TextEditingController();
  final _durationController = TextEditingController();

  String _selectedSchool = 'Evocação';
  int _selectedLevel = 0;
  bool _concentration = false;

  final List<String> schools = [
    'Abjuração',
    'Conjuração',
    'Divinação',
    'Encantamento',
    'Evocação',
    'Ilusão',
    'Necromancia',
    'Transmutação',
  ];

  Future<void> _savedSpell() async {
    if (!_formKey.currentState!.validate()) return;

    final spellBox = Hive.box<SpellModel>('spells');

    final descriptionText = _descriptionController.text.trim();
    final descriptionList = descriptionText.isNotEmpty
        ? descriptionText
              .split('\n\n')
              .map((p) => p.trim())
              .where((p) => p.isNotEmpty)
              .toList()
        : <String>[];

    final spell = SpellModel(
      index: 'custom_${DateTime.now().millisecondsSinceEpoch}',
      name: _nameController.text.trim(),
      school: _selectedSchool,
      level: _selectedLevel,
      range: _rangeController.text.trim(),
      concentration: _concentration,
      duration: _durationController.text.trim(),
      description: descriptionList,
    );

    await spellBox.put(spell.index, spell);

    Navigator.pop(context, true);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Criador de magias'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome da Magia',
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Informe um Nome' : null,
              ),
              const SizedBox(height: 16),

              //BOTÃO DA ESCOLA TODO:MELHORAR A POSIÇÃO DO LABELTEXT
              DropdownButtonFormField<String>(
                initialValue: _selectedSchool,
                decoration: const InputDecoration(labelText: 'Escola da Magia'),
                items: schools
                    .map(
                      (school) => DropdownMenuItem(
                        value: school,
                        child: Text(school),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedSchool = value!;
                  });
                },
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<int>(
                initialValue: _selectedLevel,
                decoration: const InputDecoration(labelText: 'Nível'),
                items: List.generate(
                  10,
                  (i) => DropdownMenuItem(
                    value: i,
                    child: Text(i == 0 ? 'Truque' : 'Nível $i'),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _selectedLevel = value!;
                  });
                },
              ),
              const SizedBox(height: 16),

              Row(
                spacing: 12,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  //box do alcance
                  SizedBox(
                    width: 100,
                    child: TextFormField(
                      controller: _rangeController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: const InputDecoration(
                        labelText: 'Alcance',
                        suffixText: 'ft',
                        isDense: true,
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),

                  Column(
                    children: [
                      Text(
                        'Concentração',
                      ),
                      Switch(
                        value: _concentration,
                        onChanged: (value) {
                          setState(() {
                            _concentration = value;
                          });
                        },
                      ),
                    ],
                  ),

                  //Atualmente a duração não define tempo em segundos horas ou instantania
                  SizedBox(
                    width: 120,
                    child: TextFormField(
                      controller: _durationController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: const InputDecoration(
                        labelText: 'Duração',
                        isDense: true,
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descrição da magia',
                  hintText:
                      'Digite a descrição. Use linha em branco dupla para separar parágrafos.',
                  alignLabelWithHint: true,
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Informe uma descrição'
                    : null,
                maxLines: null,
              ),

              const SizedBox(height: 32),

              ElevatedButton.icon(
                icon: Icon(Icons.save_alt),
                label: const Text('Salvar Magia'),
                onPressed: _savedSpell,

                //ADICIONAR ALCANÇE DURAÇÃO E CONCETRAÇÃO
              ),
            ],
          ),
        ),
      ),
    );
  }
}
