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

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime _currentMonth;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime(DateTime.now().year, DateTime.now().month);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Calendar', style: AppTypography.displaySmall),
                  const SizedBox(height: 20),
                  _buildMonthNav(),
                  const SizedBox(height: 16),
                  _buildWeekdayHeaders(),
                  const SizedBox(height: 8),
                  _buildCalendarGrid(provider),
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
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () {
            setState(() {
              _currentMonth = DateTime(
                  _currentMonth.year, _currentMonth.month - 1);
            });
          },
          icon: const Icon(Icons.chevron_left, color: AppColors.textPrimary),
        ),
        Text(
          '${months[_currentMonth.month - 1]} ${_currentMonth.year}',
          style: AppTypography.headingMedium,
        ),
        IconButton(
          onPressed: () {
            setState(() {
              _currentMonth = DateTime(
                  _currentMonth.year, _currentMonth.month + 1);
            });
          },
          icon: const Icon(Icons.chevron_right, color: AppColors.textPrimary),
        ),
      ],
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
                    ),
                  ),
                ),
              ))
          .toList(),
    );
  }

  Widget _buildCalendarGrid(AppProvider provider) {
    final firstDay = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final lastDay = DateTime(_currentMonth.year, _currentMonth.month + 1, 0);
    // Monday = 1 in DateTime.weekday
    final startWeekday = firstDay.weekday; // 1 = Monday

    final cells = <Widget>[];

    // Empty cells before first day
    for (int i = 1; i < startWeekday; i++) {
      cells.add(const SizedBox());
    }

    // Day cells
    for (int day = 1; day <= lastDay.day; day++) {
      final date = DateTime(_currentMonth.year, _currentMonth.month, day);
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

    // Check if this date has a period
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

    return Container(
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: isToday
            ? Border.all(color: AppColors.primary, width: 2)
            : null,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            '${date.day}',
            style: AppTypography.bodyMedium.copyWith(
              color: textColor,
              fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          if (hasCheckIn)
            Positioned(
              bottom: 4,
              child: Container(
                width: 5,
                height: 5,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
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
      final check =
          DateTime(date.year, date.month, date.day);
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
    final end = start.add(
        Duration(days: prediction.predictedPeriodDuration));
    return !date.isBefore(start) && !date.isAfter(end);
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _legendItem(AppColors.periodRed.withValues(alpha: 0.2), 'Period'),
        _legendItem(AppColors.periodRed.withValues(alpha: 0.08), 'Predicted'),
        _legendItem(AppColors.primary, 'Check-in', isDot: true),
      ],
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
            borderRadius: isDot ? null : BorderRadius.circular(3),
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
      return const Center(child: Text('Log more data for insights'));
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Next Period', style: AppTypography.headingSmall),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text('📅', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text(
                '${prediction.nextPeriodStart.day}/${prediction.nextPeriodStart.month}/${prediction.nextPeriodStart.year}',
                style: AppTypography.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: prediction.confidence.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${prediction.confidence.emoji} ${prediction.confidence.label}',
                  style: AppTypography.labelSmall,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
