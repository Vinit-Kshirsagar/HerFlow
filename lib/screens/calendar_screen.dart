import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/models.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../providers/app_provider.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen>
    with TickerProviderStateMixin {
  late DateTime _currentMonth;
  late AnimationController _fadeController;
  late AnimationController _gridController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _gridAnimation;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime(DateTime.now().year, DateTime.now().month);
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 350), // was 400
      vsync: this,
    );
    _gridController = AnimationController(
      duration: const Duration(milliseconds: 500), // was 600
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutQuart, // was easeOutCubic — slightly snappier
    );
    _gridAnimation = CurvedAnimation(
      parent: _gridController,
      curve: Curves.easeOutCubic,
    );
    _fadeController.forward();
    _gridController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _gridController.dispose();
    super.dispose();
  }

  void _changeMonth(int delta) {
    _fadeController.reset();
    _gridController.reset();
    setState(() {
      _currentMonth =
          DateTime(_currentMonth.year, _currentMonth.month + delta);
    });
    _fadeController.forward();
    _gridController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            bottom: false,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Calendar', style: AppTypography.displaySmall),
                  const SizedBox(height: 20),
                  _buildMonthNav(),
                  const SizedBox(height: 16),
                  _buildWeekdayHeaders(),
                  const SizedBox(height: 8),
                  FadeTransition(
                    opacity: _gridAnimation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.04), // was 0.06 — subtler slide-in
                        end: Offset.zero,
                      ).animate(_gridAnimation),
                      child: _buildCalendarGrid(provider),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildLegend(),
                  const SizedBox(height: 16),
                  Expanded(child: _buildDayDetails(provider)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMonthNav() {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _NavArrow(
            icon: Icons.chevron_left_rounded,
            onTap: () => _changeMonth(-1),
          ),
          FadeTransition(
            opacity: _fadeAnimation,
            child: Text(
              '${months[_currentMonth.month - 1]} ${_currentMonth.year}',
              style: AppTypography.headingMedium,
            ),
          ),
          _NavArrow(
            icon: Icons.chevron_right_rounded,
            onTap: () => _changeMonth(1),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekdayHeaders() {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return Row(
      children: days
          .map((d) => Expanded(
                child: Center(
                  child: Text(
                    d,
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ))
          .toList(),
    );
  }

  Widget _buildCalendarGrid(AppProvider provider) {
    final firstDay =
        DateTime(_currentMonth.year, _currentMonth.month, 1);
    final lastDay =
        DateTime(_currentMonth.year, _currentMonth.month + 1, 0);
    final startWeekday = firstDay.weekday;

    final cells = <Widget>[];

    for (int i = 1; i < startWeekday; i++) {
      cells.add(const SizedBox());
    }

    for (int day = 1; day <= lastDay.day; day++) {
      final date =
          DateTime(_currentMonth.year, _currentMonth.month, day);
      cells.add(_buildDayCell(date, provider));
    }

    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1,
      children: cells,
    );
  }

  Widget _buildDayCell(DateTime date, AppProvider provider) {
    final now = DateTime.now();
    final isToday = date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;

    final isPeriodDay = _isPeriodDay(date, provider.periodEntries);
    final hasCheckIn = _hasCheckIn(date, provider.checkInEntries);
    final isPredicted = _isPredictedPeriod(date, provider);

    Color? bgColor;
    Color textColor = AppColors.textPrimary;

    if (isPeriodDay) {
      bgColor = AppColors.periodRed.withValues(alpha: 0.2);
      textColor = AppColors.periodRed;
    } else if (isPredicted) {
      bgColor = AppColors.periodRed.withValues(alpha: 0.08);
      textColor = AppColors.periodRed.withValues(alpha: 0.5);
    } else if (isToday) {
      bgColor = AppColors.primary.withValues(alpha: 0.15);
      textColor = AppColors.primary;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200), // was 250 — slightly crisper
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: isToday
            ? Border.all(color: AppColors.primary, width: 2)
            : null,
        boxShadow: isPeriodDay
            ? [
                BoxShadow(
                  color: AppColors.periodRed.withValues(alpha: 0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            '${date.day}',
            style: AppTypography.bodyMedium.copyWith(
              color: textColor,
              fontWeight: isToday || isPeriodDay
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
          ),
          if (hasCheckIn)
            Positioned(
              bottom: 4,
              child: Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 3,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  bool _isPeriodDay(DateTime date, List<PeriodEntry> entries) {
    for (final entry in entries) {
      final start = DateTime(
          entry.startDate.year, entry.startDate.month, entry.startDate.day);
      final end = entry.endDate != null
          ? DateTime(
              entry.endDate!.year, entry.endDate!.month, entry.endDate!.day)
          : start.add(const Duration(days: 5));
      final check = DateTime(date.year, date.month, date.day);
      if (!check.isBefore(start) && !check.isAfter(end)) return true;
    }
    return false;
  }

  bool _hasCheckIn(DateTime date, List<CheckInEntry> entries) {
    return entries.any((e) =>
        e.date.year == date.year &&
        e.date.month == date.month &&
        e.date.day == date.day);
  }

  bool _isPredictedPeriod(DateTime date, AppProvider provider) {
    final prediction = provider.prediction;
    if (prediction == null) return false;
    final start = prediction.nextPeriodStart;
    final end =
        start.add(Duration(days: prediction.predictedPeriodDuration));
    return !date.isBefore(start) && !date.isAfter(end);
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _legendItem(
              AppColors.periodRed.withValues(alpha: 0.2), 'Period'),
          _legendItem(
              AppColors.periodRed.withValues(alpha: 0.08), 'Predicted'),
          _legendItem(AppColors.primary, 'Check-in', isDot: true),
        ],
      ),
    );
  }

  Widget _legendItem(Color color, String label, {bool isDot = false}) {
    return Row(
      children: [
        Container(
          width: isDot ? 8 : 14,
          height: isDot ? 8 : 14,
          decoration: BoxDecoration(
            color: color,
            shape: isDot ? BoxShape.circle : BoxShape.rectangle,
            borderRadius: isDot ? null : BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }

  Widget _buildDayDetails(AppProvider provider) {
    final prediction = provider.prediction;
    if (prediction == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.insights_rounded,
                  size: 32, color: AppColors.secondary),
            ),
            const SizedBox(height: 12),
            Text(
              'Log more data for insights',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Next Period', style: AppTypography.headingSmall),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.periodRed.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.calendar_today_rounded,
                    size: 20, color: AppColors.periodRed),
              ),
              const SizedBox(width: 14),
              Text(
                '${prediction.nextPeriodStart.day}/${prediction.nextPeriodStart.month}/${prediction.nextPeriodStart.year}',
                style: AppTypography.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: prediction.confidence.color
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: prediction.confidence.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      prediction.confidence.label,
                      style: AppTypography.labelSmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NavArrow extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _NavArrow({required this.icon, required this.onTap});

  @override
  State<_NavArrow> createState() => _NavArrowState();
}

class _NavArrowState extends State<_NavArrow> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.85 : 1.0,
        duration: const Duration(milliseconds: 100), // was 120 — snappier press feel
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(widget.icon, color: AppColors.textPrimary, size: 22),
        ),
      ),
    );
  }
}