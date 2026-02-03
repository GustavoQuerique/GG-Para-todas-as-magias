//Eu gostei do design desse widget, mas não vou usar dentro da pagina inicial
// talvez eu possa usar em outros lugares no futuro

import 'package:flutter/material.dart';

import '../presentation/screens/favorites/favorites_page.dart';

class BottomPanelWidget extends StatefulWidget {
  final VoidCallback? onFavoritesTap;
  final VoidCallback? onCreateSpellTap;
  final VoidCallback? onCharacterTap;

  const BottomPanelWidget({
    super.key,
    this.onFavoritesTap,
    this.onCreateSpellTap,
    this.onCharacterTap,
  });

  @override
  State<BottomPanelWidget> createState() => _BottomPanelWidgetState();
}

class _BottomPanelWidgetState extends State<BottomPanelWidget> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      left: 0,
      right: 0,
      bottom: isExpanded ? 0 : -150,
      height: 190,
      child: GestureDetector(
        onVerticalDragEnd: (details) {
          if (details.primaryVelocity == null) return;

          setState(() {
            if (details.primaryVelocity! < 0) {
              isExpanded = true;
            } else {
              isExpanded = false;
            }
          });
        },
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: const [
              BoxShadow(
                blurRadius: 12,
                color: Colors.black26,
              ),
            ],
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              if (isExpanded) ...[
                ListTile(
                  leading: const Icon(Icons.star),
                  title: const Text('Favoritos'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const FavoritesPage(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.auto_fix_high),
                  title: const Text('Criar Magia'),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text('Fichas'),
                  onTap: () {},
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
