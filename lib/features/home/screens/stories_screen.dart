import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/story_progress_service.dart';
import 'story_video_screen.dart';

class StoriesScreen extends StatelessWidget {
  const StoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 600;
    final crossAxis = isTablet ? 5 : 3;

    return Scaffold(
      appBar: AppBar(title: const Text('قصص دودي')),
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
            final n = index + 1;
            final svc = context.watch<StoryProgressService>();
            final watched = svc.isWatched(n);

            final color = Colors.primaries[n % Colors.primaries.length];

            return GestureDetector(
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => StoryVideoScreen(number: n))),
              child: Stack(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      gradient: watched
                          ? LinearGradient(colors: [Colors.teal.shade300, Colors.teal.shade600])
                          : LinearGradient(colors: [color.shade200, color.shade400]),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 12, offset: Offset(0, 6))],
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('$n', style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                          SizedBox(height: 8),
                          Icon(Icons.play_circle_outline, color: Colors.white, size: 36),
                          SizedBox(height: 8),
                          Text(watched ? 'Watched' : 'Tap to watch', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70)),
                        ],
                      ),
                    ),
                  ),
                  if (watched)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                        child: Icon(Icons.check, color: Colors.white, size: 18),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
