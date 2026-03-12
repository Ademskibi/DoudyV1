import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../services/auth_service.dart';

const double kTabletBreakpoint = 600;
const double kMinTouchTarget = 44.0;

class ChildHomeScreen extends StatefulWidget {
  const ChildHomeScreen({super.key});

  @override
  State<ChildHomeScreen> createState() => _ChildHomeScreenState();
}

class _ChildHomeScreenState extends State<ChildHomeScreen> {
  int _selectedIndex = 0;

  void _onNavSelected(int idx) => setState(() => _selectedIndex = idx);

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);

    return LayoutBuilder(builder: (context, constraints) {
      final width = constraints.maxWidth;
      final height = constraints.maxHeight;
      final orientation = MediaQuery.of(context).orientation;
      final isTablet = width >= kTabletBreakpoint;
      final isPhoneLandscape = width < kTabletBreakpoint && orientation == Orientation.landscape;

      // Columns: tablet 3-4, phone portrait 1-2, phone landscape 4+
      int columns;
      if (isTablet) {
        columns = width >= 1000 ? 4 : 3;
      } else if (isPhoneLandscape) {
        columns = 4;
      } else {
        columns = 2;
      }

      // Padding: tablet generous 24-32, phone standard 16. Phone landscape reduces vertical padding.
      final horizontalPadding = isTablet
          ? (width * 0.03).clamp(24.0, 32.0) as double
          : 16.0;
      final verticalPadding = isPhoneLandscape ? 8.0 : 16.0;

      // Font scaling: increase 20-30% on tablet
      final baseTextTheme = Theme.of(context).textTheme;
      final scale = isTablet ? 1.25 : 1.0;

      final titleFontSize = (baseTextTheme.titleLarge?.fontSize ?? 20.0) * scale;
      final greetingStyle = baseTextTheme.titleLarge?.copyWith(fontSize: titleFontSize) ?? TextStyle(fontSize: titleFontSize);

      final appBarHeight = isPhoneLandscape ? kToolbarHeight * 0.75 : kToolbarHeight;

      Widget content = SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 8),
              Flexible(
                flex: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text('Hi ${auth.appUser?.name ?? 'Friend'}!', style: greetingStyle, overflow: TextOverflow.ellipsis),
                    ),
                    SizedBox(width: 8),
                    ConstrainedBox(
                      constraints: BoxConstraints(minWidth: kMinTouchTarget, minHeight: kMinTouchTarget),
                      child: InkWell(
                        onTap: () => auth.signOut(),
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(Icons.logout, size: 20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12),
              Expanded(
                child: LayoutBuilder(builder: (context, gridConstraints) {
                  return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      crossAxisSpacing: math.max(8.0, horizontalPadding / 4),
                      mainAxisSpacing: math.max(8.0, verticalPadding / 2),
                      childAspectRatio: (gridConstraints.maxWidth / columns) / ((gridConstraints.maxHeight) / math.max(3, columns)),
                    ),
                    itemCount: 12,
                    itemBuilder: (context, index) {
                      return ConstrainedBox(
                        constraints: BoxConstraints(minWidth: kMinTouchTarget, minHeight: kMinTouchTarget),
                        child: InkWell(
                          onTap: () {},
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text('Item ${index + 1}', style: baseTextTheme.bodyMedium?.copyWith(fontSize: (baseTextTheme.bodyMedium?.fontSize ?? 14.0) * scale) ?? TextStyle(fontSize: (baseTextTheme.bodyMedium?.fontSize ?? 14.0) * scale)),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      );

      // Decorated background preserved
      final decorated = DecoratedBox(
        decoration: BoxDecoration(
          image: DecorationImage(image: AssetImage('images/img.png'), fit: BoxFit.cover),
        ),
        child: content,
      );

      if (isTablet) {
        return Scaffold(
          appBar: AppBar(title: Text('Child Home'), toolbarHeight: appBarHeight),
          body: Row(
            children: [
              NavigationRail(
                selectedIndex: _selectedIndex,
                onDestinationSelected: _onNavSelected,
                labelType: NavigationRailLabelType.all,
                destinations: const [
                  NavigationRailDestination(icon: Icon(Icons.home), label: Text('Home')),
                  NavigationRailDestination(icon: Icon(Icons.book), label: Text('Lessons')),
                  NavigationRailDestination(icon: Icon(Icons.settings), label: Text('Settings')),
                ],
              ),
              VerticalDivider(width: 1),
              Expanded(child: decorated),
            ],
          ),
        );
      }

      // Phone: use bottom navigation
      return Scaffold(
        appBar: AppBar(title: Text('Child Home'), toolbarHeight: appBarHeight),
        body: decorated,
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onNavSelected,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Lessons'),
            BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
          ],
        ),
      );
    });
  }
}
