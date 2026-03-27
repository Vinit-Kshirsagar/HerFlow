import 'package:flutter/material.dart';
import 'enums.dart';

/// Period log entry
class PeriodEntry {
  final String id;
  final DateTime startDate;
  final DateTime? endDate;
  final FlowIntensity intensity;
  final String? notes;
  final DateTime createdAt;

  PeriodEntry({
    required this.id,
    required this.startDate,
    this.endDate,
    this.intensity = FlowIntensity.medium,
    this.notes,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  int get durationDays {
    if (endDate == null) return 0;
    return endDate!.difference(startDate).inDays + 1;
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'start_date': startDate.toIso8601String(),
        'end_date': endDate?.toIso8601String(),
        'intensity': intensity.name,
        'notes': notes,
        'created_at': createdAt.toIso8601String(),
      };

  factory PeriodEntry.fromMap(Map<String, dynamic> map) => PeriodEntry(
        id: map['id'] as String,
        startDate: DateTime.parse(map['start_date'] as String),
        endDate: map['end_date'] != null
            ? DateTime.parse(map['end_date'] as String)
            : null,
        intensity: FlowIntensity.values.firstWhere(
          (e) => e.name == map['intensity'],
          orElse: () => FlowIntensity.medium,
        ),
        notes: map['notes'] as String?,
        createdAt: map['created_at'] != null
            ? DateTime.parse(map['created_at'] as String)
            : DateTime.now(),
      );

  PeriodEntry copyWith({
    String? id,
    DateTime? startDate,
    DateTime? endDate,
    FlowIntensity? intensity,
    String? notes,
  }) =>
      PeriodEntry(
        id: id ?? this.id,
        startDate: startDate ?? this.startDate,
        endDate: endDate ?? this.endDate,
        intensity: intensity ?? this.intensity,
        notes: notes ?? this.notes,
        createdAt: createdAt,
      );
}

/// Daily check-in entry
class CheckInEntry {
  final String id;
  final DateTime date;
  final List<Mood> moods;
  final List<Symptom> symptoms;
  final FlowIntensity? flowIntensity;
  final String? notes;
  final DateTime createdAt;

  CheckInEntry({
    required this.id,
    required this.date,
    this.moods = const [],
    this.symptoms = const [],
    this.flowIntensity,
    this.notes,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        'id': id,
        'date': date.toIso8601String(),
        'moods': moods.map((m) => m.name).toList(),
        'symptoms': symptoms.map((s) => s.name).toList(),
        'flow_intensity': flowIntensity?.name,
        'notes': notes,
        'created_at': createdAt.toIso8601String(),
      };

  factory CheckInEntry.fromMap(Map<String, dynamic> map) => CheckInEntry(
        id: map['id'] as String,
        date: DateTime.parse(map['date'] as String),
        moods: (map['moods'] as List<dynamic>?)
                ?.map((m) => Mood.values.firstWhere((e) => e.name == m))
                .toList() ??
            [],
        symptoms: (map['symptoms'] as List<dynamic>?)
                ?.map((s) => Symptom.values.firstWhere((e) => e.name == s))
                .toList() ??
            [],
        flowIntensity: map['flow_intensity'] != null
            ? FlowIntensity.values.firstWhere(
                (e) => e.name == map['flow_intensity'],
                orElse: () => FlowIntensity.medium,
              )
            : null,
        notes: map['notes'] as String?,
        createdAt: map['created_at'] != null
            ? DateTime.parse(map['created_at'] as String)
            : DateTime.now(),
      );
}

/// Cycle prediction result
class CyclePrediction {
  final DateTime predictedStartDate;
  final int predictedCycleLength;
  final int predictedPeriodDuration;
  final PredictionConfidence confidence;

  CyclePrediction({
    required this.predictedStartDate,
    required this.predictedCycleLength,
    required this.predictedPeriodDuration,
    required this.confidence,
  });

  /// Alias used by screens
  DateTime get nextPeriodStart => predictedStartDate;

  int get daysUntilNextPeriod {
    final now = DateTime.now();
    final diff = predictedStartDate.difference(now).inDays;
    return diff < 0 ? 0 : diff;
  }
}

enum PredictionConfidence { low, medium, high }

extension PredictionConfidenceExt on PredictionConfidence {
  String get label {
    switch (this) {
      case PredictionConfidence.low:
        return 'Low';
      case PredictionConfidence.medium:
        return 'Medium';
      case PredictionConfidence.high:
        return 'High';
    }
  }

  String get emoji {
    switch (this) {
      case PredictionConfidence.low:
        return '🔴';
      case PredictionConfidence.medium:
        return '🟡';
      case PredictionConfidence.high:
        return '🟢';
    }
  }

  Color get color {
    switch (this) {
      case PredictionConfidence.low:
        return const Color(0xFFEF4444);
      case PredictionConfidence.medium:
        return const Color(0xFFFBBF24);
      case PredictionConfidence.high:
        return const Color(0xFF22C55E);
    }
  }
}

/// Forum post
class ForumPost {
  final String id;
  final String content;
  final String anonymousName;
  final DateTime createdAt;
  final int replyCount;
  final bool isFlagged;

  ForumPost({
    required this.id,
    required this.content,
    required this.anonymousName,
    required this.createdAt,
    this.replyCount = 0,
    this.isFlagged = false,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'content': content,
        'anonymous_name': anonymousName,
        'created_at': createdAt.toIso8601String(),
        'reply_count': replyCount,
        'is_flagged': isFlagged,
      };

  factory ForumPost.fromMap(Map<String, dynamic> map) => ForumPost(
        id: map['id'] as String,
        content: map['content'] as String,
        anonymousName: map['anonymous_name'] as String? ?? 'Anonymous',
        createdAt: DateTime.parse(map['created_at'] as String),
        replyCount: map['reply_count'] as int? ?? 0,
        isFlagged: map['is_flagged'] as bool? ?? false,
      );
}

/// User profile (local)
class UserProfile {
  final String name;
  final DateTime? lastPeriodDate;
  final int cycleLength;
  final int periodDuration;
  final bool onboardingComplete;
  final bool remindersEnabled;
  final int streak;

  UserProfile({
    this.name = '',
    this.lastPeriodDate,
    this.cycleLength = 28,
    this.periodDuration = 5,
    this.onboardingComplete = false,
    this.remindersEnabled = true,
    this.streak = 0,
  });

  /// Backward-compat alias
  int get averageCycleLength => cycleLength;

  Map<String, dynamic> toMap() => {
        'name': name,
        'last_period_date': lastPeriodDate?.toIso8601String(),
        'cycle_length': cycleLength,
        'period_duration': periodDuration,
        'onboarding_complete': onboardingComplete,
        'reminders_enabled': remindersEnabled,
        'streak': streak,
      };

  factory UserProfile.fromMap(Map<String, dynamic> map) => UserProfile(
        name: map['name'] as String? ?? '',
        lastPeriodDate: map['last_period_date'] != null
            ? DateTime.parse(map['last_period_date'] as String)
            : null,
        cycleLength: map['cycle_length'] as int? ?? 28,
        periodDuration: map['period_duration'] as int? ?? 5,
        onboardingComplete: map['onboarding_complete'] as bool? ?? false,
        remindersEnabled: map['reminders_enabled'] as bool? ?? true,
        streak: map['streak'] as int? ?? 0,
      );

  UserProfile copyWith({
    String? name,
    DateTime? lastPeriodDate,
    int? cycleLength,
    int? periodDuration,
    bool? onboardingComplete,
    bool? remindersEnabled,
    int? streak,
  }) =>
      UserProfile(
        name: name ?? this.name,
        lastPeriodDate: lastPeriodDate ?? this.lastPeriodDate,
        cycleLength: cycleLength ?? this.cycleLength,
        periodDuration: periodDuration ?? this.periodDuration,
        onboardingComplete: onboardingComplete ?? this.onboardingComplete,
        remindersEnabled: remindersEnabled ?? this.remindersEnabled,
        streak: streak ?? this.streak,
      );
}
