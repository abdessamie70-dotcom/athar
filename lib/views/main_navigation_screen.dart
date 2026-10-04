import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'capsule/legacy_capsule_view.dart';
import 'dashboard/dashboard_view.dart';
import 'initiatives/initiatives_view.dart';
import 'perspective/perspective_view.dart';
import 'settings/settings_view.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DashboardView(),
    PerspectiveView(),
    InitiativesView(),
    LegacyCapsuleView(),
    SettingsView(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: isDark ? const Color(0xFF28362E) : const Color(0xFFE8E4DA),
              width: 1,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          selectedItemColor: isDark ? AppTheme.accentGoldLight : AppTheme.primarySlateGreen,
          unselectedItemColor: isDark ? AppTheme.textMutedLight : AppTheme.textMutedDark,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.wb_sunny_outlined),
              activeIcon: Icon(Icons.wb_sunny_rounded),
              label: 'اليوم',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.balance_outlined),
              activeIcon: Icon(Icons.balance_rounded),
              label: 'الميزان',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.eco_outlined),
              activeIcon: Icon(Icons.eco_rounded),
              label: 'المبادرات',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.lock_clock_outlined),
              activeIcon: Icon(Icons.lock_clock_rounded),
              label: 'الخزنة',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.tune_outlined),
              activeIcon: Icon(Icons.tune_rounded),
              label: 'الإعدادات',
            ),
          ],
        ),
      ),
    );
  }
}
