import 'package:flutter/material.dart';

class SpellLevelCard extends StatelessWidget {
  final int level;

  const SpellLevelCard({
    super.key,
    required this.level,
  });

  @override
  Widget build(BuildContext context) {
    BoxDecoration _cardDecoration() {
      return BoxDecoration(
        color: const Color(0xFF1E293B), // azul escuro
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF334155),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Nível $level",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Icon(Icons.auto_awesome, size: 18),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: Column(
                  children: const [
                    Text("Total de Espaços"),
                    SizedBox(height: 4),
                    SizedBox(
                      height: 40,
                      child: TextField(
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  children: const [
                    Text("Espaços Usados"),
                    SizedBox(height: 4),
                    SizedBox(
                      height: 40,
                      child: TextField(
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Barra de progresso visual
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: 0.5, // depois você calcula dinamicamente
              minHeight: 6,
            ),
          ),

          const SizedBox(height: 8),
          const Text(
            "4 disponíveis",
            style: TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}
