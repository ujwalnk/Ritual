import 'package:flutter/material.dart';

// Services
import 'package:ritual/services/ritual_icons.dart';
import 'package:ritual/services/shared_prefs.dart';

class ExpandableFab extends StatefulWidget {
  final bool sprint;
  final bool highlight;

  const ExpandableFab({Key? key, required this.sprint, required this.highlight})
      : super(key: key);

  @override
  _ExpandableFabState createState() => _ExpandableFabState();
}

class _ExpandableFabState extends State<ExpandableFab> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (_isExpanded) _buildModalBarrier(),
        Align(
          alignment: Alignment.bottomRight,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (_isExpanded && widget.highlight)
                _buildExpandableFab(
                  onPressed: () {
                    Navigator.pushNamed(context, "/commit/highlight",
                        arguments: {"mode": "new"});
                    _collapseFAB();
                  },
                  icon: const Icon(CustomIcons.lightbulbOutline),
                  tooltip: 'Set Highlight',
                ),
              if (_isExpanded && widget.highlight) const SizedBox(height: 8),
              if (_isExpanded && widget.sprint)
                _buildExpandableFab(
                  onPressed: () {
                    Navigator.pushNamed(context, "/commit/sprint",
                        arguments: {"mode": "new"});
                    _collapseFAB();
                  },
                  icon: const Icon(CustomIcons.directionsRun),
                  tooltip: 'Set Sprint',
                ),
              if (_isExpanded && widget.sprint) const SizedBox(height: 8),
              if (_isExpanded)
                _buildExpandableFab(
                  onPressed: () {
                    Navigator.pushNamed(context, "/commit/ritual",
                        arguments: {"mode": "new"});
                    _collapseFAB();
                  },
                  icon: const Icon(CustomIcons.fire),
                  tooltip: 'New Ritual',
                ),
              const SizedBox(height: 8), // Adjust the height as needed
              FloatingActionButton(
                onPressed: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
                tooltip: _isExpanded ? 'Collapse' : 'Expand',
                backgroundColor: Color(SharedPreferencesManager().getAccentColor()),
                child: Icon(_isExpanded ? Icons.close : Icons.add),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExpandableFab({
    required VoidCallback onPressed,
    required Icon icon,
    required String tooltip,
  }) {
    return Column(
      children: [
        FloatingActionButton(
          onPressed: onPressed,
          heroTag: null,
          tooltip: tooltip,
          backgroundColor: Color(SharedPreferencesManager().getAccentColor()),
          child: icon,
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildModalBarrier() {
    return GestureDetector(
      onTapDown: (details) => _collapseFAB(),
      child: Container(
        color: Colors.transparent,
      ),
    );
  }

  void _collapseFAB() {
    if (_isExpanded) {
      setState(() {
        _isExpanded = false;
      });
    }
  }
}
