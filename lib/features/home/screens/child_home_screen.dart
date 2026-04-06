import 'package:douddyv1/features/home/screens/numbers_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../services/auth_service.dart';
import '../widgets/number_card.dart';
import 'game_selection_screen.dart';
import '../../../services/story_progress_service.dart';

class ChildHomeScreen extends StatelessWidget {
  const ChildHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 600;
    final crossAxis = isTablet ? 5 : 3;

    return Scaffold(
      appBar: AppBar(
        title: const Text('تعلم الأرقام'),
        actions: [
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
            onPressed: () async {
              // Sign out and navigate to login
              try {
                await Provider.of<AuthService>(context, listen: false).signOut();
              } catch (_) {}
              // Use go_router to navigate to the login route
              try {
                GoRouter.of(context).go('/login');
              } catch (_) {
                Navigator.of(context).pushReplacementNamed('/login');
              }
            },
          ),
        ],
      ),
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
            final isUnlocked = context.watch<StoryProgressService>().isUnlocked(n);

            return Stack(
              children: [
                Opacity(
                  opacity: isUnlocked ? 1.0 : 0.4,
                  child: NumberCard(
                    number: n,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.of(context).push(MaterialPageRoute(builder: (_) => NumbersScreen(n)));
                    },
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
