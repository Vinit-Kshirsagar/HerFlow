import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import 'home_screen.dart';
import 'calendar_screen.dart';
import 'checkin_screen.dart';
import 'settings_screen.dart';

/// Provides global tab navigation access from child widgets
class MainShellScope extends InheritedWidget {
  final void Function(int index) navigateTo;

  const MainShellScope({
    super.key,
    required this.navigateTo,
    required super.child,
  });

  static MainShellScope? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<MainShellScope>();
  }

  @override
  bool updateShouldNotify(MainShellScope oldWidget) => false;
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final _screens = const [
    HomeScreen(),
    CalendarScreen(),
    CheckInScreen(),
    SettingsScreen(),
  ];

  void _navigateTo(int index) {
    if (index >= 0 && index < _screens.length) {
      setState(() => _currentIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainShellScope(
      navigateTo: _navigateTo,
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: AppColors.cardWhite,
            boxShadow: [
              BoxShadow(
                color: AppColors.textPrimary.withValues(alpha: 0.05),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 8, vertical: 6),
              child: Row(
                children: [
                  _NavItem(
                    emoji: '🏠',
                    label: 'Home',
                    isActive: _currentIndex == 0,
                    onTap: () => _navigateTo(0),
                  ),
                  _NavItem(
                    emoji: '📅',
                    label: 'Calendar',
                    isActive: _currentIndex == 1,
                    onTap: () => _navigateTo(1),
                  ),
                  _NavItem(
                    emoji: '✨',
                    label: 'Check-in',
                    isActive: _currentIndex == 2,
                    onTap: () => _navigateTo(2),
                  ),
                  _NavItem(
                    emoji: '⚙️',
                    label: 'Settings',
                    isActive: _currentIndex == 3,
                    onTap: () => _navigateTo(3),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String emoji;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.emoji,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.primary.withValues(alpha: 0.08)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                emoji,
                style: TextStyle(
                  fontSize: isActive ? 22 : 20,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: AppTypography.labelSmall.copyWith(
                  color: isActive
                      ? AppColors.primary
                      : AppColors.textMuted,
                  fontWeight:
                      isActive ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
