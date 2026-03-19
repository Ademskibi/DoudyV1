import 'package:flutter/material.dart';

class GameCard extends StatefulWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  const GameCard({required this.title, required this.icon, required this.onTap, super.key});

  @override
  State<GameCard> createState() => _GameCardState();
}

class _GameCardState extends State<GameCard> {
  double _elevation = 2.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _elevation = 8.0),
      onTapUp: (_) => setState(() => _elevation = 2.0),
      onTapCancel: () => setState(() => _elevation = 2.0),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: _elevation, offset: Offset(0, 6))],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
              child: Icon(widget.icon, size: 32, color: Theme.of(context).colorScheme.primary),
            ),
            SizedBox(width: 12),
            Expanded(child: Text(widget.title, style: Theme.of(context).textTheme.titleMedium)),
            Icon(Icons.arrow_forward_ios_rounded, size: 18, color: Colors.grey[600]),
          ],
        ),
      ),
    );
  }
}
