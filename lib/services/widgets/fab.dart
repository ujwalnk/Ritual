import 'package:flutter/material.dart';

// Services
import 'package:ritual/services/ritual_icons.dart';

// Exapandable FAB
class ExpandableFab extends StatefulWidget {
  final bool sprint;
  final bool highlight;

  const ExpandableFab({Key? key, required this.sprint, required this.highlight})
      : super(key: key);

  // const ExpandableFab({super.key});

  @override
  _ExpandableFabState createState() => _ExpandableFabState();
}

class _ExpandableFabState extends State<ExpandableFab> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    if (widget.sprint || widget.highlight) {
      return Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (_isExpanded && widget.highlight)
                FloatingActionButton(
                  onPressed: () {
                    Navigator.pushNamed(context, "/commit/highlight", arguments: {"mode": "new"});
                  },
                  heroTag: null,
                  tooltip: 'Set Highlight',
                  child: const Icon(Ritual.lightbulb_outline),
                ),
              if (_isExpanded && widget.highlight) const SizedBox(height: 16),
              if (_isExpanded && widget.sprint)
                FloatingActionButton(
                  onPressed: () {
                    Navigator.pushNamed(context, "/commit/sprint", arguments: {"mode": "new"});
                  },
                  heroTag: null,
                  tooltip: 'Set Sprint',
                  child: const Icon(Ritual.directions_run),
                ),
              if (_isExpanded && widget.sprint) const SizedBox(height: 16),
              if (_isExpanded)
                FloatingActionButton(
                  onPressed: () {
                    Navigator.pushNamed(context, "/commit/ritual",
                        arguments: {"mode": "new"});
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
    } else {
      return FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, "/commit/ritual",
              arguments: {"mode": "new"});
        },
        heroTag: null,
        tooltip: 'New Ritual',
        child: const Icon(Ritual.fire),
      );
    }
  }
}
