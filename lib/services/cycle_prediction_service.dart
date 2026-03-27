import '../core/constants/models.dart';
import '../core/constants/enums.dart';

/// AI Cycle Prediction Service
/// Uses weighted moving average for cycle prediction
class CyclePredictionService {
  /// Predict next period based on past entries
  static CyclePrediction? predictNextCycle(List<PeriodEntry> entries) {
    if (entries.isEmpty) return null;

    // Sort by start date descending
    final sorted = List<PeriodEntry>.from(entries)
      ..sort((a, b) => b.startDate.compareTo(a.startDate));

    if (sorted.length < 2) {
      // With only one entry, use standard 28-day cycle
      final lastPeriod = sorted.first;
      return CyclePrediction(
        predictedStartDate: lastPeriod.startDate.add(const Duration(days: 28)),
        predictedCycleLength: 28,
        predictedPeriodDuration: lastPeriod.durationDays > 0
            ? lastPeriod.durationDays
            : 5,
        confidence: PredictionConfidence.low,
      );
    }

    // Calculate cycle lengths between periods
    final cycleLengths = <int>[];
    final periodDurations = <int>[];

    for (int i = 0; i < sorted.length - 1; i++) {
      final cycleLength =
          sorted[i].startDate.difference(sorted[i + 1].startDate).inDays;
      if (cycleLength > 15 && cycleLength < 60) {
        cycleLengths.add(cycleLength);
      }
      if (sorted[i].durationDays > 0) {
        periodDurations.add(sorted[i].durationDays);
      }
    }

    if (cycleLengths.isEmpty) {
      return CyclePrediction(
        predictedStartDate: sorted.first.startDate.add(const Duration(days: 28)),
        predictedCycleLength: 28,
        predictedPeriodDuration: 5,
        confidence: PredictionConfidence.low,
      );
    }

    // Weighted Moving Average — recent cycles have more weight
    final weightedCycleLength = _weightedAverage(cycleLengths);
    final avgPeriodDuration = periodDurations.isNotEmpty
        ? (periodDurations.reduce((a, b) => a + b) / periodDurations.length)
            .round()
        : 5;

    // Confidence based on data volume and consistency
    final confidence = _calculateConfidence(cycleLengths);

    final lastPeriod = sorted.first;
    final predictedStart = lastPeriod.startDate
        .add(Duration(days: weightedCycleLength));

    return CyclePrediction(
      predictedStartDate: predictedStart,
      predictedCycleLength: weightedCycleLength,
      predictedPeriodDuration: avgPeriodDuration,
      confidence: confidence,
    );
  }

  /// Determine current cycle phase
  static CyclePhase getCurrentPhase(
      List<PeriodEntry> entries, CyclePrediction? prediction) {
    if (entries.isEmpty) return CyclePhase.unknown;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Check if currently on period
    final sorted = List<PeriodEntry>.from(entries)
      ..sort((a, b) => b.startDate.compareTo(a.startDate));

    final latestPeriod = sorted.first;
    final periodStart =
        DateTime(latestPeriod.startDate.year, latestPeriod.startDate.month,
            latestPeriod.startDate.day);

    // If period has no end date and started within 7 days, assume still on period
    if (latestPeriod.endDate == null) {
      final daysSinceStart = today.difference(periodStart).inDays;
      if (daysSinceStart >= 0 && daysSinceStart <= 7) {
        return CyclePhase.period;
      }
    } else {
      final periodEnd = DateTime(latestPeriod.endDate!.year,
          latestPeriod.endDate!.month, latestPeriod.endDate!.day);
      if (!today.isBefore(periodStart) && !today.isAfter(periodEnd)) {
        return CyclePhase.period;
      }
    }

    // Calculate cycle day
    final daysSincePeriodStart = today.difference(periodStart).inDays;
    final cycleLength = prediction?.predictedCycleLength ?? 28;

    if (daysSincePeriodStart < 0) return CyclePhase.unknown;

    // Phase boundaries (approximate)
    final follicularEnd = (cycleLength * 0.35).round(); // ~day 10
    final ovulationEnd = (cycleLength * 0.55).round(); // ~day 15
    // Luteal goes until next period

    if (daysSincePeriodStart <= follicularEnd) {
      return CyclePhase.follicular;
    } else if (daysSincePeriodStart <= ovulationEnd) {
      return CyclePhase.ovulation;
    } else {
      return CyclePhase.luteal;
    }
  }

  /// Weighted average — recent values get more weight
  static int _weightedAverage(List<int> values) {
    if (values.isEmpty) return 28;
    if (values.length == 1) return values.first;

    double totalWeight = 0;
    double weightedSum = 0;

    for (int i = 0; i < values.length; i++) {
      // Most recent = highest weight
      final weight = values.length - i.toDouble();
      weightedSum += values[i] * weight;
      totalWeight += weight;
    }

    return (weightedSum / totalWeight).round();
  }

  /// Calculate prediction confidence
  static PredictionConfidence _calculateConfidence(List<int> cycleLengths) {
    if (cycleLengths.length < 2) return PredictionConfidence.low;
    if (cycleLengths.length < 4) return PredictionConfidence.medium;

    // Check consistency — standard deviation
    final avg = cycleLengths.reduce((a, b) => a + b) / cycleLengths.length;
    final variance = cycleLengths
            .map((v) => (v - avg) * (v - avg))
            .reduce((a, b) => a + b) /
        cycleLengths.length;

    if (variance < 4) return PredictionConfidence.high; // Very consistent
    if (variance < 16) return PredictionConfidence.medium; // Somewhat variable
    return PredictionConfidence.low; // Very irregular
  }

  /// Get cycle day number (1-based)
  static int getCycleDay(List<PeriodEntry> entries) {
    if (entries.isEmpty) return 0;

    final sorted = List<PeriodEntry>.from(entries)
      ..sort((a, b) => b.startDate.compareTo(a.startDate));

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastPeriodStart = DateTime(
      sorted.first.startDate.year,
      sorted.first.startDate.month,
      sorted.first.startDate.day,
    );

    return today.difference(lastPeriodStart).inDays + 1;
  }
}
