import 'package:flutter/material.dart';

class SheetCreator extends StatefulWidget {
  const SheetCreator({super.key});

  @override
  State<SheetCreator> createState() => _SheetCreatorState();
}

class _SheetCreatorState extends State<SheetCreator> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Criador de fichas'),
      ),
      body: Stack(
        children: [],
      ),
    );
  }
}
