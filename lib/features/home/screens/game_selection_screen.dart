import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/game_card.dart';
import 'package:douddyv1/games/logico_game.dart';
import 'package:douddyv1/games/pizza_game.dart';
import 'package:douddyv1/games/card_sort_game.dart';

class GameSelectionScreen extends StatelessWidget {
  final int number;
  const GameSelectionScreen({required this.number, super.key});

  @override
  Widget build(BuildContext context) {
    final games = [
      {'title': 'Logico', 'icon': Icons.psychology, 'widget': LogicoGameScreen()},
      {'title': 'Pizza Game', 'icon': Icons.local_pizza, 'widget': PizzaGameScreen()},
      {'title': 'Card Slot', 'icon': Icons.credit_card, 'widget': CardSortGameScreen()},
    ];

    return Scaffold(
      appBar: AppBar(title: Text('ألعاب للرقم $number')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.separated(
          itemCount: games.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final g = games[index];
            return GameCard(
              title: g['title'] as String,
              icon: g['icon'] as IconData,
              onTap: () {
                HapticFeedback.lightImpact();
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => g['widget'] as Widget));
              },
            );
          },
        ),
      ),
    );
  }
}
