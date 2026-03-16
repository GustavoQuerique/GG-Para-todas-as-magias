import 'package:flutter/material.dart';

class SpellcastingInfoCard extends StatelessWidget {
  const SpellcastingInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    BoxDecoration cardDecoration() {
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
      decoration: cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Informações de Conjuração",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          const TextField(
            decoration: InputDecoration(
              labelText: "Classe Conjuradora",
              hintText: "Ex: Mago",
            ),
          ),
          const SizedBox(height: 12),

          const TextField(
            decoration: InputDecoration(
              labelText: "Atributo de Conjuração",
              hintText: "Ex: Inteligência",
            ),
          ),
          const SizedBox(height: 12),

          Row(
            children: const [
              Expanded(
                child: TextField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: "CD de Magia"),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: TextField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: "Bônus de Ataque"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
