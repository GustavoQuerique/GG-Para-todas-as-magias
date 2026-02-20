import 'package:flutter/material.dart';

class MedievalCard extends StatelessWidget {
  final Widget child;
  final bool highlight;

  const MedievalCard({
    super.key,
    required this.child,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1A1A1A),
            const Color(0xFF141414),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: highlight
              ? colors.secondary
              : colors.secondary.withValues(alpha: 0.25),
          width: highlight ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.6),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: child,
      ),
    );
  }
}
