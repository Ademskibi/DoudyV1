import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/colors.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _page = 0;

  final List<Map<String, String>> pages = [
    {'title': 'Welcome to DOUDY', 'subtitle': 'Learn with playful activities'},
    {'title': 'Learn while playing', 'subtitle': 'Fun educational games'},
    {'title': 'Parents can track progress', 'subtitle': 'Monitor growth easily'},
    {'title': "Let's start", 'subtitle': 'Create an account and join'},
  ];

void _finish() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('seenOnboarding', true);

  if (!mounted) return;
  context.go('/login');
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: pages.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (ctx, i) => Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 240,
                        width: 240,
                        decoration: BoxDecoration(
                          color: AppColors.blue.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Center(child: Icon(Icons.school, size: 96, color: AppColors.blue)),
                      ),
                      SizedBox(height: 24),
                      Text(pages[i]['title']!, style: Theme.of(context).textTheme.headlineMedium),
                      SizedBox(height: 8),
                      Text(pages[i]['subtitle']!, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Row(
                    children: List.generate(
                      pages.length,
                      (i) => Container(
                        margin: EdgeInsets.symmetric(horizontal: 4),
                        width: _page == i ? 18 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _page == i ? AppColors.primaryGreen : Colors.grey.shade400,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  Spacer(),
                  ElevatedButton(
                    onPressed: _page == pages.length - 1
                        ? _finish
                        : () => _controller.nextPage(duration: Duration(milliseconds: 300), curve: Curves.easeInOut),
                    child: Text(_page == pages.length - 1 ? 'Get Started' : 'Next'),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
