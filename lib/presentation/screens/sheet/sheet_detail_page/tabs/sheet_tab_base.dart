///TODO: adicionar ataques e magias rapidas e as personalidades do personagem

import 'package:flutter/material.dart';
import 'package:guia_de_garlou_para_todas_as_magias/data/datasources/remote/dnd_api_service.dart';
import 'package:guia_de_garlou_para_todas_as_magias/models/character_sheet.dart';
import 'package:guia_de_garlou_para_todas_as_magias/models/dnd_class.dart';
import 'package:guia_de_garlou_para_todas_as_magias/models/repositories/class_repository.dart';
import 'package:guia_de_garlou_para_todas_as_magias/widgets/inline_editable_field.dart';
import 'package:guia_de_garlou_para_todas_as_magias/widgets/medieval_card.dart';

class SheetTabBase extends StatefulWidget {
  final CharacterSheet sheet;

  const SheetTabBase({super.key, required this.sheet});

  @override
  State<SheetTabBase> createState() => _SheetTabBaseState();
}

class _SheetTabBaseState extends State<SheetTabBase> {
  List<DndClass> availableClasses = [];
  bool isLoadingClasses = true;
  int _deathSuccesses = 0;
  int _deathFailures = 0;

  final classRepository = ClassRepository();

  CharacterSheet get sheet => widget.sheet;

  @override
  void initState() {
    super.initState();
    _loadClasses();
  }

  Future<void> _loadClasses() async {
    final classes = await classRepository.getClasses();

    setState(() {
      availableClasses = classes;
      isLoadingClasses = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          /// NOME DO PERSONAGEM
          MedievalCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Nome do Personagem",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 8),

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

          const SizedBox(height: 16),

          ///INFORMAÇÕES PRINCIPAIS
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

                _buildInfoRow(
                  title: "Raça",
                  value: sheet.raceIndex ?? "Não definida",
                  onChanged: (val) {
                    setState(() {
                      sheet.raceIndex = val;
                      sheet.save();
                    });
                  },
                ),

                const Divider(),

                _buildClassDropdown(),

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

          /// VIDA
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
                title: 'Velocidade em M/S',
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
                onChanged: (val) {
                  setState(() {});
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

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

          MedievalCard(
            child: _buildDeathSaves(),
          ),

          const SizedBox(height: 24),

          const Text(
            "Roleplay",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          MedievalCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMultilineField(
                  title: "Traços de Personalidade",
                  value: sheet.personalityTraits ?? '',
                  onChanged: (val) {
                    setState(() {
                      sheet.personalityTraits = val;
                      sheet.save();
                    });
                  },
                ),

                const Divider(),

                _buildMultilineField(
                  title: "Ideais",
                  value: sheet.ideals ?? '',
                  onChanged: (val) {
                    setState(() {
                      sheet.ideals = val;
                      sheet.save();
                    });
                  },
                ),

                const Divider(),

                _buildMultilineField(
                  title: "Vínculos",
                  value: sheet.bonds ?? '',
                  onChanged: (val) {
                    setState(() {
                      sheet.bonds = val;
                      sheet.save();
                    });
                  },
                ),

                const Divider(),

                _buildMultilineField(
                  title: "Defeitos",
                  value: sheet.flaws ?? '',
                  onChanged: (val) {
                    setState(() {
                      sheet.flaws = val;
                      sheet.save();
                    });
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          MedievalCard(
            child: _buildMultilineField(
              title: "História do Personagem",
              value: sheet.backStory ?? '',
              onChanged: (val) {
                setState(() {
                  sheet.backStory = val;
                  sheet.save();
                });
              },
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

  ///Dropdown para escolher as classes disponiveis
  Widget _buildClassDropdown() {
    final sheet = widget.sheet;

    if (isLoadingClasses) {
      return const CircularProgressIndicator();
    }

    return DropdownButtonFormField<String>(
      initialValue: sheet.classIndex,
      decoration: const InputDecoration(
        labelText: "Classe",
        border: OutlineInputBorder(),
      ),
      items: availableClasses.map((dndClass) {
        return DropdownMenuItem<String>(
          value: dndClass.index,
          child: Text(dndClass.name),
        );
      }).toList(),
      onChanged: (value) async {
        if (value == null) return;

        sheet.classIndex = value;

        await sheet.save();

        setState(() {});
      },
    );
  }
}
