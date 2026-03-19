import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/number_card.dart';
import 'game_selection_screen.dart';

class NumbersScreen extends StatelessWidget {
  const NumbersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 600;
    final crossAxis = isTablet ? 5 : 3;

    return Scaffold(
      appBar: AppBar(title: const Text('تعلم الأرقام')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxis,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1,
          ),
          itemCount: 10,
          itemBuilder: (context, index) {
            return NumberCard(
              number: index,
              onTap: () {
                HapticFeedback.selectionClick();
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => GameSelectionScreen(number: index)));
              },
            );
          },
        ),
      ),
    );
  }
}
