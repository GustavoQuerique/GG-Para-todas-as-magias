import 'package:flutter/material.dart';
import 'package:guia_de_garlou_para_todas_as_magias/models/character_sheet.dart';
import 'package:guia_de_garlou_para_todas_as_magias/presentation/screens/sheet/sheet_detail_page/tabs/sheet_tab_attributes.dart';
import 'package:guia_de_garlou_para_todas_as_magias/presentation/screens/sheet/sheet_detail_page/tabs/sheet_tab_base.dart';
import 'package:guia_de_garlou_para_todas_as_magias/presentation/screens/sheet/sheet_detail_page/tabs/sheet_tab_inventory.dart';
import 'package:guia_de_garlou_para_todas_as_magias/presentation/screens/sheet/sheet_detail_page/tabs/sheet_tab_skills.dart';
import 'package:guia_de_garlou_para_todas_as_magias/presentation/screens/sheet/sheet_detail_page/tabs/sheet_tab_spells.dart';

class SheetDetailPage extends StatefulWidget {
  final CharacterSheet sheet;

  const SheetDetailPage({super.key, required this.sheet});

  @override
  State<SheetDetailPage> createState() => _SheetDetailPageState();
}

class _SheetDetailPageState extends State<SheetDetailPage> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      SheetTabBase(sheet: widget.sheet),
      SheetTabAttributes(sheet: widget.sheet),
      SheetTabSkills(sheet: widget.sheet),
      SheetTabSpells(sheet: widget.sheet),
      SheetTabInventory(sheet: widget.sheet),
    ];

    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) => setState(() => currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Ficha'),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Atributos',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: 'Perícias'),
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_fix_high),
            label: 'Magias',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory),
            label: 'Inventário',
          ),
        ],
      ),
    );
  }
}
