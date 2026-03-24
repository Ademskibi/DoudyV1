import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../widgets/number_card.dart';
import 'game_selection_screen.dart';
import '../../../services/story_progress_service.dart';

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
            final isUnlocked = context.watch<StoryProgressService>().isUnlocked(index);

            return Stack(
              children: [
                Opacity(
                  opacity: isUnlocked ? 1.0 : 0.4,
                  child: NumberCard(
                    number: index,
                    onTap: isUnlocked
                        ? () {
                            HapticFeedback.selectionClick();
                            Navigator.of(context).push(MaterialPageRoute(builder: (_) => GameSelectionScreen(number: index)));
                          }
                        : null,
                  ),
                ),
                if (!isUnlocked)
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Row(
                      children: [
                        Icon(Icons.lock, size: 18, color: Colors.black54),
                      ],
                    ),
                  ),
                if (!isUnlocked)
                  Positioned(
                    left: 8,
                    right: 8,
                    bottom: 8,
                    child: Center(
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: Colors.black.withOpacity(0.25), borderRadius: BorderRadius.circular(8)),
                        child: Text('Watch story first', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white)),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
