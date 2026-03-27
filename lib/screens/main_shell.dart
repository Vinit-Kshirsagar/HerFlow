import 'dart:ui';
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

class _MainShellState extends State<MainShell> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late final AnimationController _navAnimController;
  late final Animation<double> _navSlideAnimation;

  final _screens = const [
    HomeScreen(),
    CalendarScreen(),
    CheckInScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _navAnimController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _navSlideAnimation = CurvedAnimation(
      parent: _navAnimController,
      curve: Curves.easeOutCubic,
    );
    _navAnimController.forward();
  }

  @override
  void dispose() {
    _navAnimController.dispose();
    super.dispose();
  }

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
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          child: KeyedSubtree(
            key: ValueKey(_currentIndex),
            child: _screens[_currentIndex],
          ),
        ),
        extendBody: true,
        bottomNavigationBar: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(_navSlideAnimation),
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.glassWhite,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: AppColors.glassBorder,
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        blurRadius: 30,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 8),
                      child: Row(
                        children: [
                          _NavItem(
                            icon: Icons.home_rounded,
                            label: 'Home',
                            isActive: _currentIndex == 0,
                            onTap: () => _navigateTo(0),
                          ),
                          _NavItem(
                            icon: Icons.calendar_month_rounded,
                            label: 'Calendar',
                            isActive: _currentIndex == 1,
                            onTap: () => _navigateTo(1),
                          ),
                          _NavItem(
                            icon: Icons.add_circle_outline_rounded,
                            label: 'Check-in',
                            isActive: _currentIndex == 2,
                            onTap: () => _navigateTo(2),
                          ),
                          _NavItem(
                            icon: Icons.settings_rounded,
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
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
      lowerBound: 0.0,
      upperBound: 1.0,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTapDown: (_) => _scaleController.forward(),
        onTapUp: (_) {
          _scaleController.reverse();
          widget.onTap();
        },
        onTapCancel: () => _scaleController.reverse(),
        behavior: HitTestBehavior.opaque,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: widget.isActive
                  ? AppColors.primary.withValues(alpha: 0.12)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedScale(
                  scale: widget.isActive ? 1.15 : 1.0,
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutBack,
                  child: Icon(
                    widget.icon,
                    size: widget.isActive ? 24 : 22,
                    color: widget.isActive
                        ? AppColors.primary
                        : AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 3),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: AppTypography.labelSmall.copyWith(
                    color: widget.isActive
                        ? AppColors.primary
                        : AppColors.textMuted,
                    fontWeight:
                        widget.isActive ? FontWeight.w700 : FontWeight.normal,
                    fontSize: 11,
                  ),
                  child: Text(widget.label),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
