///TODO: adicionar ataques e magias rapidas e as personalidades do personagem

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:guia_de_garlou_para_todas_as_magias/data/repositories/background_repository.dart';
import 'package:guia_de_garlou_para_todas_as_magias/data/repositories/class_repository.dart';
import 'package:guia_de_garlou_para_todas_as_magias/data/repositories/races_repository.dart';
import 'package:guia_de_garlou_para_todas_as_magias/domain/models/character_sheet.dart';
import 'package:guia_de_garlou_para_todas_as_magias/domain/models/dnd_background.dart';
import 'package:guia_de_garlou_para_todas_as_magias/domain/models/dnd_class.dart';
import 'package:guia_de_garlou_para_todas_as_magias/domain/models/dnd_race.dart';
import 'package:guia_de_garlou_para_todas_as_magias/presentation/widgets/buttons/build_dropdown_options.dart';
import 'package:guia_de_garlou_para_todas_as_magias/presentation/widgets/inline_editable_field.dart';
import 'package:guia_de_garlou_para_todas_as_magias/presentation/widgets/medieval_card.dart';
import 'package:image_picker/image_picker.dart';

class SheetTabBase extends StatefulWidget {
  final CharacterSheet sheet;

  const SheetTabBase({super.key, required this.sheet});

  @override
  State<SheetTabBase> createState() => _SheetTabBaseState();
}

class _SheetTabBaseState extends State<SheetTabBase> {
  List<DndClass> availableClasses = [];
  List<DndRace> availableRaces = [];
  List<DndBackground> availableBackgrounds = [];

  bool isLoadingClasses = true;
  bool isLoadingRaces = true;
  bool isLoadingBackground = true;

  int _deathSuccesses = 0;
  int _deathFailures = 0;

  final classRepository = ClassRepository();
  final racesRepository = RacesRepository();
  final backgroundRepository = BackgroundRepository();

  CharacterSheet get sheet => widget.sheet;

  @override
  void initState() {
    super.initState();
    _loadClasses();
    _loadRaces();
    _loadBackground();
  }

  Future<void> _loadClasses() async {
    final classes = await classRepository.getClasses();

    setState(() {
      availableClasses = classes;
      isLoadingClasses = false;
    });
  }

  Future<void> _loadRaces() async {
    final races = await racesRepository.getRaces();

    setState(() {
      availableRaces = races;
      isLoadingRaces = false;
    });
  }

  Future<void> _loadBackground() async {
    final background = await backgroundRepository.getBackground();

    print("BACKGROUNDS: ${background.length}");
    print(background.map((e) => e.name).toList());

    setState(() {
      availableBackgrounds = background;
      isLoadingBackground = false;
    });
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        widget.sheet.imagePath = image.path;
        widget.sheet.save();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          /// --- CARD DE CABEÇALHO (FOTO + NOME) ---
          MedievalCard(
            child: Row(
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.amber.withOpacity(0.5)),
                      image: widget.sheet.imagePath != null
                          ? DecorationImage(
                              image: FileImage(File(widget.sheet.imagePath!)),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: widget.sheet.imagePath == null
                        ? const Icon(Icons.add_a_photo, color: Colors.amber)
                        : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize:
                        MainAxisSize.min, // Importante para não quebrar o Row
                    children: [
                      const Text(
                        "Nome do Personagem",
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      InlineEditableField(
                        value: sheet.name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                        onChanged: (value) {
                          setState(() {
                            sheet.name = value;
                            sheet.save();
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ), // <-- FECHAMENTO DO MEDIEVAL CARD DO TOPO

          const SizedBox(height: 16),

          /// --- INFORMAÇÕES PRINCIPAIS ---
          MedievalCard(
            child: Column(
              children: [
                _buildInfoRow(
                  title: "Nível",
                  value: sheet.level.toString(),
                  keyboardType: TextInputType.number,
                  onChanged: (val) {
                    setState(() {
                      sheet.level = int.tryParse(val) ?? sheet.level;
                      sheet.save();
                    });
                  },
                ),
                const Divider(),
                SheetDropdown(
                  label: "Raças",
                  currentValue: sheet.raceIndex,
                  options: availableRaces
                      .map(
                        (r) =>
                            SheetDropdownOption(value: r.index, label: r.name),
                      )
                      .toList(),
                  onChanged: (value) async {
                    if (value == null) return;
                    sheet.raceIndex = value;
                    await sheet.save();
                    setState(() {});
                  },
                ),
                const Divider(),
                SheetDropdown(
                  label: "Classes",
                  currentValue: sheet.classIndex,
                  options: availableClasses
                      .map(
                        (c) =>
                            SheetDropdownOption(value: c.index, label: c.name),
                      )
                      .toList(),
                  onChanged: (value) async {
                    if (value == null) return;
                    sheet.classIndex = value;
                    await sheet.save();
                    setState(() {});
                  },
                ),
                const Divider(),
                _buildInfoRow(
                  title: "Alinhamento",
                  value: sheet.alignment ?? "Não definido",
                  onChanged: (val) {
                    setState(() {
                      sheet.alignment = val;
                      sheet.save();
                    });
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          /// --- STATUS (CA, INICIATIVA, ETC) ---
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
            children: [
              _buildStatCard(
                title: 'CA',
                value: sheet.armorClass.toString(),
                icon: Icons.shield,
                onChanged: (val) {
                  setState(() {
                    sheet.armorClass = int.tryParse(val) ?? sheet.armorClass;
                    sheet.save();
                  });
                },
              ),
              _buildStatCard(
                title: "Iniciativa",
                value: sheet.initiative.toString(),
                icon: Icons.flash_on,
                onChanged: (val) {
                  setState(() {
                    sheet.initiative = int.tryParse(val) ?? sheet.initiative;
                    sheet.save();
                  });
                },
              ),
              _buildStatCard(
                title: 'Velocidade',
                value: sheet.speed.toString(),
                icon: Icons.directions_run,
                onChanged: (val) {
                  setState(() {
                    sheet.speed = int.tryParse(val) ?? sheet.speed;
                    sheet.save();
                  });
                },
              ),
              _buildStatCard(
                title: 'Proficiência',
                value: sheet.proficiencyBonus.toString(),
                icon: Icons.auto_awesome,
                onChanged: (val) {},
              ),
            ],
          ),

          const SizedBox(height: 16),

          /// --- VIDA ---
          MedievalCard(
            child: Column(
              children: [
                _buildInfoRow(
                  title: "Vida Máxima",
                  value: sheet.maxHp.toString(),
                  keyboardType: TextInputType.number,
                  onChanged: (val) {
                    setState(() {
                      sheet.maxHp = int.tryParse(val) ?? sheet.maxHp;
                      sheet.save();
                    });
                  },
                ),
                const Divider(),
                _buildInfoRow(
                  title: "Vida Atual",
                  value: sheet.currentHp.toString(),
                  keyboardType: TextInputType.number,
                  onChanged: (val) {
                    setState(() {
                      sheet.currentHp = int.tryParse(val) ?? sheet.currentHp;
                      sheet.save();
                    });
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
          MedievalCard(child: _buildDeathSaves()),
          const SizedBox(height: 24),

          /// --- ROLEPLAY ---
          const Text(
            "Roleplay",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          MedievalCard(
            child: Column(
              children: [
                _buildMultilineField(
                  title: "Traços de Personalidade",
                  value: sheet.personalityTraits ?? '',
                  onChanged: (v) => setState(() {
                    sheet.personalityTraits = v;
                    sheet.save();
                  }),
                ),
                const Divider(),
                _buildMultilineField(
                  title: "Ideais",
                  value: sheet.ideals ?? '',
                  onChanged: (v) => setState(() {
                    sheet.ideals = v;
                    sheet.save();
                  }),
                ),
                const Divider(),
                _buildMultilineField(
                  title: "Vínculos",
                  value: sheet.bonds ?? '',
                  onChanged: (v) => setState(() {
                    sheet.bonds = v;
                    sheet.save();
                  }),
                ),
                const Divider(),
                _buildMultilineField(
                  title: "Defeitos",
                  value: sheet.flaws ?? '',
                  onChanged: (v) => setState(() {
                    sheet.flaws = v;
                    sheet.save();
                  }),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          MedievalCard(
            child: _buildMultilineField(
              title: "História",
              value: sheet.backStory ?? '',
              onChanged: (v) => setState(() {
                sheet.backStory = v;
                sheet.save();
              }),
            ),
          ),
        ],
      ),
    );
  }

  ///Widget para as info como classe, raça e nome.
  Widget _buildInfoRow({
    required String title,
    required String value,
    required Function(String) onChanged,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),

          SizedBox(
            width: 120,
            child: InlineEditableField(
              value: value,
              keyboardType: keyboardType,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  ///Widget para o card de teste de morte
  Widget _buildDeathSaves() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Teste de Morte',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 80),

              TextButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF1A1A1A),
                ),
                onPressed: () {
                  setState(() {
                    _deathSuccesses = 0;
                    _deathFailures = 0;
                  });
                },
                child: const Text(
                  "Resetar",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          //Sucesso
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Text('Sucessos: '),
              const SizedBox(height: 8),
              ...List.generate(3, (index) {
                return Checkbox(
                  value: _deathSuccesses > index,
                  activeColor: Colors.green,
                  onChanged: (value) {
                    setState(() {
                      if (value == true && _deathSuccesses < 3) {
                        _deathSuccesses++;
                      } else if (value == false && _deathSuccesses > 0) {
                        _deathSuccesses--;
                      }
                    });
                  },
                );
              }),
            ],
          ),

          //Falhas
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Text('Falhas: '),
              const SizedBox(width: 20),
              ...List.generate(3, (index) {
                return Checkbox(
                  value: _deathFailures > index,
                  activeColor: Colors.red,
                  onChanged: (value) {
                    setState(() {
                      if (value == true && _deathFailures < 3) {
                        _deathFailures++;
                      } else if (value == false && _deathFailures > 0) {
                        _deathFailures--;
                      }
                    });
                  },
                );
              }),
            ],
          ),

          const SizedBox(height: 5),

          if (_deathSuccesses >= 3)
            const Text(
              "Estabilizado",
              style: TextStyle(
                color: Colors.green,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

          if (_deathFailures >= 3)
            const Text(
              "Morto",
              style: TextStyle(
                color: Colors.red,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }

  ///Widget para organizar os stats cards
  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Function(String) onChanged,
  }) {
    return MedievalCard(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade400),

          const SizedBox(height: 6),

          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),

          const SizedBox(height: 8),

          Flexible(
            child: InlineEditableField(
              value: value,
              keyboardType: TextInputType.number,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  ///Multi line para as info de Roleplay do player
  Widget _buildMultilineField({
    required String title,
    required String value,
    required Function(String) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            initialValue: value,
            maxLines: null,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              isDense: true,
            ),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
