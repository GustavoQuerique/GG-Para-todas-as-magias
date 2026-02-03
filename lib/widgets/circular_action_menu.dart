import 'dart:math';
import 'package:flutter/material.dart';

import 'action_button.dart';

class CircularActionMenu extends StatefulWidget {
  final List<ActionButton> actions;
  final double radius;
  final Duration duration;

  const CircularActionMenu({
    super.key,
    required this.actions,
    this.radius = 90,
    this.duration = const Duration(milliseconds: 300),
  });

  @override
  State<CircularActionMenu> createState() => _CircularActionMenuState();
}

class _CircularActionMenuState extends State<CircularActionMenu>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool isOpen = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
  }

  void toggle() {
    setState(() {
      isOpen = !isOpen;
      isOpen ? _controller.forward() : _controller.reverse();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final count = widget.actions.length;
    final angleStep = pi / (count + 1); // arco suave

    return SizedBox(
      width: widget.radius * 2,
      height: widget.radius * 2,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // ações
          for (int i = 0; i < count; i++)
            AnimatedBuilder(
              animation: _controller,
              builder: (_, child) {
                final angle = angleStep * (i + 1);
                final offset = Offset(
                  cos(angle) * widget.radius * _controller.value,
                  -sin(angle) * widget.radius * _controller.value,
                );

                return Transform.translate(
                  offset: offset,
                  child: Transform.scale(
                    scale: _controller.value,
                    child: child,
                  ),
                );
              },
              child: ActionButton(
                icon: widget.actions[i].icon,
                label: widget.actions[i].label,
                onTap: () {
                  toggle();
                  widget.actions[i].onTap();
                },
              ),
            ),

          // botão central
          FloatingActionButton(
            onPressed: toggle,
            child: AnimatedIcon(
              icon: AnimatedIcons.menu_close,
              progress: _controller,
            ),
          ),
        ],
      ),
    );
  }
}
