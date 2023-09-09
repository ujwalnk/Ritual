import 'package:flutter/material.dart';

// Services
import 'package:Ritual/services/ritual_icons.dart';

// Exapandable FAB
class ExpandableFab extends StatefulWidget {
  const ExpandableFab({super.key});

  @override
  _ExpandableFabState createState() => _ExpandableFabState();
}

class _ExpandableFabState extends State<ExpandableFab> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (_isExpanded)
              FloatingActionButton(
                onPressed: () {
                  Navigator.pushNamed(context, "/commit/highlight");
                },
                heroTag: null,
                tooltip: 'Set Highlight',
                child: const Icon(Ritual.lightbulb_outline),
              ),
            if (_isExpanded)
              const SizedBox(height: 16),
            if (_isExpanded)
              FloatingActionButton(
                onPressed: () {
                  Navigator.pushNamed(context, "/commit/sprint");
                },
                heroTag: null,
                tooltip: 'Set Sprint',
                child: const Icon(Ritual.directions_run),
              ),
            if (_isExpanded)
              const SizedBox(height: 16),
            if (_isExpanded)
              FloatingActionButton(
                onPressed: () {
                  Navigator.pushNamed(context, "/commit/ritual");
                },
                heroTag: null,
                tooltip: 'New Ritual',
                child: const Icon(Ritual.fire),
              ),
            const SizedBox(height: 16),
            FloatingActionButton(
              onPressed: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              tooltip: 'Expand',
              child: Icon(_isExpanded ? Icons.close : Icons.add),
            ),
          ],
        ),
      ],
    );
  }
}
