import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'; // ── ADDED FOR PREMIUM APPLE ICONS ──
import '../features/home/ui/home_screen.dart';
import '../features/analytics/ui/analytics_dashboardscreen.dart';
import '../features/accounts/ui/account.dart';
import '../features/goals/ui/financial_goals_screen.dart';

/// GLOBAL NAV SERVICE
class NavigationService {
  static final ValueNotifier<int> bottomIndex = ValueNotifier(0);

  static String? selectedAccountName;
}

class MainNavigation extends StatelessWidget {
  const MainNavigation({super.key});

  static const List<Widget> _screens = [
    HomeScreen(),
    FinancialGoalsScreen(),
    AccountsOverviewScreen(),
    AnalyticsDashboardScreen(),
  ];

  void _handleSwipe(DragEndDetails details) {
    int index = NavigationService.bottomIndex.value;

    /// Swipe Left → Next Page
    if (details.primaryVelocity! < 0) {
      if (index < _screens.length - 1) {
        NavigationService.bottomIndex.value = index + 1;
      }
    }

    /// Swipe Right → Previous Page
    if (details.primaryVelocity! > 0) {
      if (index > 0) {
        NavigationService.bottomIndex.value = index - 1;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // --- PREMIUM BRAND COLORS ---
    const Color premiumGreen = Color(0xFF0F766E); // Grasshopper Green 
    const Color darkNavBg = Color(0xFF092215);    // Deep Forest Green for dark mode

    return ValueListenableBuilder<int>(
      valueListenable: NavigationService.bottomIndex,
      builder: (context, index, _) {
        return Scaffold(
          /// SWIPE DETECTOR
          body: GestureDetector(
            onHorizontalDragEnd: _handleSwipe,
            child: IndexedStack(
              index: index,
              children: _screens,
            ),
          ),

          /// PREMIUM BOTTOM NAVIGATION BAR
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: isDark 
                      ? Colors.black.withOpacity(0.50) 
                      : Colors.black.withOpacity(0.06),
                  blurRadius: 24,
                  offset: const Offset(0, -8),
                ),
              ],
              border: Border(
                top: BorderSide(
                  color: isDark 
                      ? Colors.white.withOpacity(0.05) 
                      : Colors.black.withOpacity(0.03),
                  width: 1.0,
                ),
              ),
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              child: BottomNavigationBar(
                currentIndex: index,
                onTap: (i) => NavigationService.bottomIndex.value = i,

                // ── Solid Backgrounds ──
                backgroundColor: isDark ? const Color.fromARGB(255, 0, 0, 0) : Colors.white,

                // ── Active State: ONLY COLOR CHANGES ──
                selectedItemColor: premiumGreen,
                selectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.2,
                ),
                
                // ── Inactive State ──
                unselectedItemColor: isDark ? Colors.white.withOpacity(0.45) : Colors.black45,
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.1,
                ),

                showUnselectedLabels: true,
                showSelectedLabels: true,
                selectedFontSize: 12,
                unselectedFontSize: 12, 

                type: BottomNavigationBarType.fixed,
                elevation: 0, 

                items: const [
                  BottomNavigationBarItem(
                    icon: Padding(
                      padding: EdgeInsets.only(bottom: 6.0, top: 4.0),
                      child: Icon(Icons.home_outlined, size: 26),
                    ),
                    activeIcon: Padding(
                      padding: EdgeInsets.only(bottom: 6.0, top: 4.0),
                      child: Icon(Icons.home_rounded, size: 26),
                    ),
                    label: 'Home',
                  ),

                  BottomNavigationBarItem(
                    icon: Padding(
                      padding: EdgeInsets.only(bottom: 6.0, top: 4.0),
                      child: Icon(Icons.track_changes_outlined, size: 26),
                    ),
                    activeIcon: Padding(
                      padding: EdgeInsets.only(bottom: 6.0, top: 4.0),
                      child: Icon(Icons.track_changes_rounded, size: 26),
                    ),
                    label: 'Goals',
                  ),

                  // ── ABSTRACT PORTFOLIO ICON (Layers) ──
                  BottomNavigationBarItem(
                    icon: Padding(
                      padding: EdgeInsets.only(bottom: 6.0, top: 4.0),
                      child: Icon(Icons.layers_outlined, size: 26),
                    ),
                    activeIcon: Padding(
                      padding: EdgeInsets.only(bottom: 6.0, top: 4.0),
                      child: Icon(Icons.layers, size: 26),
                    ),
                    label: 'Assets',
                  ),

                  // ── PREMIUM APPLE PIE CHART ──
                  BottomNavigationBarItem(
                    icon: Padding(
                      padding: EdgeInsets.only(bottom: 6.0, top: 4.0),
                      child: Icon(CupertinoIcons.chart_pie, size: 26),
                    ),
                    activeIcon: Padding(
                      padding: EdgeInsets.only(bottom: 6.0, top: 4.0),
                      child: Icon(CupertinoIcons.chart_pie_fill, size: 26),
                    ),
                    label: 'Analytics',
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}