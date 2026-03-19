import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'numbers_screen.dart';

const double kMinTouchTarget = 44.0;

class ChildHomeScreen extends StatelessWidget {
  const ChildHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 600;
    final horizontalPadding = isTablet ? 32.0 : 16.0;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 20.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('مرحبا 👋', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
                      SizedBox(height: 6),
                      Text('اختَر نشاطًا مع دودي', style: Theme.of(context).textTheme.titleMedium),
                    ],
                  ),
                ],
              ),

              SizedBox(height: 28),

              Expanded(
                child: LayoutBuilder(builder: (context, constraints) {
                  final cardWidth = isTablet ? (constraints.maxWidth / 2) - 24 : constraints.maxWidth;
                  return Center(
                    child: Wrap(
                      spacing: 20,
                      runSpacing: 20,
                      alignment: WrapAlignment.center,
                      children: [
                        _MainChoiceCard(
                          width: cardWidth,
                          title: 'تعلم مع دودي',
                          subtitle: 'تعلم الأرقام والأشكال',
                          icon: Icons.menu_book_rounded,
                          colors: [Color(0xFF6EE7B7), Color(0xFF3B82F6)],
                          onTap: () {
                            HapticFeedback.lightImpact();
                            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NumbersScreen()));
                          },
                        ),
                        _MainChoiceCard(
                          width: cardWidth,
                          title: 'قصة دودي',
                          subtitle: 'استمع إلى قصص ممتعة',
                          icon: Icons.auto_stories_rounded,
                          colors: [Color(0xFFFBCFE8), Color(0xFFF472B6)],
                          onTap: () {
                            HapticFeedback.lightImpact();
                            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const _StoriesPlaceholder()));
                          },
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MainChoiceCard extends StatefulWidget {
  final double width;
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> colors;
  final VoidCallback onTap;

  const _MainChoiceCard({required this.width, required this.title, required this.subtitle, required this.icon, required this.colors, required this.onTap});

  @override
  State<_MainChoiceCard> createState() => _MainChoiceCardState();
}

class _MainChoiceCardState extends State<_MainChoiceCard> with SingleTickerProviderStateMixin {
  double _scale = 1.0;
  void _onTapDown(TapDownDetails _) => setState(() => _scale = 0.97);
  void _onTapUp(TapUpDetails _) => setState(() => _scale = 1.0);
  void _onTapCancel() => setState(() => _scale = 1.0);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.onTap,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 120),
        scale: _scale,
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: widget.width, maxWidth: widget.width, minHeight: 140),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: widget.colors, begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 18, offset: Offset(0, 8))],
            ),
            child: Row(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), shape: BoxShape.circle),
                  child: Icon(widget.icon, size: 40, color: widget.colors.last),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(widget.title, style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                      SizedBox(height: 6),
                      Text(widget.subtitle, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70)),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StoriesPlaceholder extends StatelessWidget {
  const _StoriesPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('قصة دودي')),
      body: Center(child: Text('قريبًا: مكتبة القصص', style: Theme.of(context).textTheme.titleLarge)),
    );
  }
}
