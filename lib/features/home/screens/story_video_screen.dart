import 'package:flutter/material.dart';
import '../../../services/story_progress_service.dart';
import 'package:provider/provider.dart';

class StoryVideoScreen extends StatelessWidget {
  final int number;
  const StoryVideoScreen({required this.number, super.key});

  @override
  Widget build(BuildContext context) {
    final svc = context.watch<StoryProgressService>();
    final watched = svc.isWatched(number);

    return Scaffold(
      appBar: AppBar(title: Text('Story $number')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(12)),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.play_circle_outline, color: Colors.white70, size: 56),
                      SizedBox(height: 8),
                      Text('Video coming soon', style: TextStyle(color: Colors.white70)),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: watched
                    ? null
                    : () async {
                        await context.read<StoryProgressService>().markWatched(number);
                        if (Navigator.of(context).canPop()) Navigator.of(context).pop();
                      },
                child: watched ? Text('Already Watched ✓') : Text('Mark as Watched'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
