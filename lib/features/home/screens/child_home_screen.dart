import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/responsive.dart';
import '../../../../services/auth_service.dart';
import 'package:douddyv1/games/chairs_game.dart';
import 'package:douddyv1/games/ball_game.dart';
import 'package:douddyv1/games/card_sort_game.dart';
import 'package:douddyv1/games/jump_numbers_game.dart';
import 'package:douddyv1/games/pizza_game.dart';
import 'package:douddyv1/games/logico_game.dart';

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

      int columns;
      if (isTablet) {
        columns = width >= 1000 ? 4 : 3;
      } else if (isPhoneLandscape) {
        columns = 4;
      } else {
        columns = 2;
      }

      final horizontalPadding = isTablet
          ? (width * 0.03).clamp(24.0, 32.0) as double
          : 16.0;
      final verticalPadding = isPhoneLandscape ? 8.0 : 16.0;

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
              SizedBox(height: 1.5.h),
              Flexible(
                flex: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text('Hi ${auth.appUser?.name ?? 'Friend'}!', style: greetingStyle, overflow: TextOverflow.ellipsis),
                    ),
                    SizedBox(width: 2.w),
                    ConstrainedBox(
                      constraints: BoxConstraints(minWidth: 6.w, minHeight: 6.h),
                      child: InkWell(
                        onTap: () => auth.signOut(),
                        borderRadius: BorderRadius.circular(2.w),
                        child: Padding(
                          padding: EdgeInsets.all(1.5.w),
                          child: Icon(Icons.logout, size: 3.5.w),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 2.h),
              Expanded(
                child: LayoutBuilder(builder: (context, gridConstraints) {
                  return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      crossAxisSpacing: math.max(2.w, horizontalPadding / 4),
                      mainAxisSpacing: math.max(1.5.h, verticalPadding / 2),
                      childAspectRatio: (gridConstraints.maxWidth / columns) / ((gridConstraints.maxHeight) / math.max(3, columns)),
                    ),
                    itemCount: 6,
                    itemBuilder: (context, index) {
                      final games = [
                        {'title': 'Chaises Musicales\nلعبة الكراسي', 'widget': ChairsGameScreen()},
                        {'title': 'Passer la balle\nتمرير الكرة', 'widget': BallGameScreen()},
                        {'title': 'Trier les cartes\nفرز الأرقام', 'widget': CardSortGameScreen()},
                        {'title': 'Sauter sur les nombres\nالقفز على الأرقام', 'widget': JumpNumbersGameScreen()},
                        {'title': 'Pizza Game\nلعبة البيتزا', 'widget': PizzaGameScreen()},
                        {'title': 'Logico\nنشاط Logico', 'widget': LogicoGameScreen()},
                      ];
                      final g = games[index];
                      return ConstrainedBox(
                        constraints: BoxConstraints(minWidth: 12.w, minHeight: 12.h),
                        child: InkWell(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(builder: (_) => g['widget'] as Widget));
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(3.w),
                            ),
                            child: Center(
                              child: Padding(
                                padding: EdgeInsets.all(2.w),
                                child: Text(
                                  g['title'] as String,
                                  textAlign: TextAlign.center,
                                  style: baseTextTheme.titleMedium?.copyWith(fontSize: (isTablet ? 2.6.sp : 2.0.sp) * scale),
                                ),
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

      final decorated = DecoratedBox(
        decoration: BoxDecoration(
          image: DecorationImage(image: AssetImage('images/img.png'), fit: BoxFit.cover),
        ),
        child: content,
      );

      if (isTablet) {
        return Scaffold(
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

      return Scaffold(
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
