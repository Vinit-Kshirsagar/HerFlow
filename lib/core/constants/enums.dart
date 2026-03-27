/// Cycle phase enum with display metadata
enum CyclePhase {
  period,
  follicular,
  ovulation,
  luteal,
  unknown,
}

/// Extension for phase display data
extension CyclePhaseExt on CyclePhase {
  String get label {
    switch (this) {
      case CyclePhase.period:
        return 'Period';
      case CyclePhase.follicular:
        return 'Follicular';
      case CyclePhase.ovulation:
        return 'Ovulation';
      case CyclePhase.luteal:
        return 'Luteal';
      case CyclePhase.unknown:
        return 'Unknown';
    }
  }

  String get description {
    switch (this) {
      case CyclePhase.period:
        return 'Your period is here. Rest and take care 💕';
      case CyclePhase.follicular:
        return 'Energy is building up! You\'re blooming 🌸';
      case CyclePhase.ovulation:
        return 'Peak energy! You\'re glowing ✨';
      case CyclePhase.luteal:
        return 'Winding down. Be gentle with yourself 🌙';
      case CyclePhase.unknown:
        return 'Log your cycle to see your phase';
    }
  }

  /// Luna's mood for each phase
  String get lunaMood {
    switch (this) {
      case CyclePhase.period:
        return 'tired';
      case CyclePhase.follicular:
        return 'hopeful';
      case CyclePhase.ovulation:
        return 'radiant';
      case CyclePhase.luteal:
        return 'moody';
      case CyclePhase.unknown:
        return 'neutral';
    }
  }

  /// Emoji for cycle phase (used by home_screen)
  String get emoji {
    switch (this) {
      case CyclePhase.period:
        return '😴';
      case CyclePhase.follicular:
        return '🌱';
      case CyclePhase.ovulation:
        return '✨';
      case CyclePhase.luteal:
        return '🌙';
      case CyclePhase.unknown:
        return '🫧';
    }
  }

  /// Backward-compat alias
  String get lunaEmoji => emoji;
}

/// Flow level for check-ins
enum FlowLevel {
  none,
  light,
  medium,
  heavy,
}

extension FlowLevelExt on FlowLevel {
  String get label {
    switch (this) {
      case FlowLevel.none:
        return 'None';
      case FlowLevel.light:
        return 'Light';
      case FlowLevel.medium:
        return 'Medium';
      case FlowLevel.heavy:
        return 'Heavy';
    }
  }

  String get emoji {
    switch (this) {
      case FlowLevel.none:
        return '∅';
      case FlowLevel.light:
        return '💧';
      case FlowLevel.medium:
        return '💧💧';
      case FlowLevel.heavy:
        return '💧💧💧';
    }
  }
}

/// Flow intensity (used by period logs)
enum FlowIntensity {
  light,
  medium,
  heavy,
}

extension FlowIntensityExt on FlowIntensity {
  String get label {
    switch (this) {
      case FlowIntensity.light:
        return 'Light';
      case FlowIntensity.medium:
        return 'Medium';
      case FlowIntensity.heavy:
        return 'Heavy';
    }
  }

  String get emoji {
    switch (this) {
      case FlowIntensity.light:
        return '💧';
      case FlowIntensity.medium:
        return '💧💧';
      case FlowIntensity.heavy:
        return '💧💧💧';
    }
  }
}

/// Mood options for daily check-in
enum Mood {
  great,
  good,
  okay,
  low,
  bad,
}

extension MoodExt on Mood {
  String get label {
    switch (this) {
      case Mood.great:
        return 'Great';
      case Mood.good:
        return 'Good';
      case Mood.okay:
        return 'Okay';
      case Mood.low:
        return 'Low';
      case Mood.bad:
        return 'Bad';
    }
  }

  String get emoji {
    switch (this) {
      case Mood.great:
        return '😊';
      case Mood.good:
        return '🙂';
      case Mood.okay:
        return '😐';
      case Mood.low:
        return '😔';
      case Mood.bad:
        return '😢';
    }
  }
}

/// Symptom options for daily check-in
enum Symptom {
  cramps,
  headache,
  backPain,
  acne,
  breastTenderness,
  nausea,
  fatigue,
  moodSwings,
  cravings,
  insomnia,
}

extension SymptomExt on Symptom {
  String get label {
    switch (this) {
      case Symptom.cramps:
        return 'Cramps';
      case Symptom.headache:
        return 'Headache';
      case Symptom.backPain:
        return 'Back Pain';
      case Symptom.acne:
        return 'Acne';
      case Symptom.breastTenderness:
        return 'Breast Tenderness';
      case Symptom.nausea:
        return 'Nausea';
      case Symptom.fatigue:
        return 'Fatigue';
      case Symptom.moodSwings:
        return 'Mood Swings';
      case Symptom.cravings:
        return 'Cravings';
      case Symptom.insomnia:
        return 'Insomnia';
    }
  }

  String get emoji {
    switch (this) {
      case Symptom.cramps:
        return '🔥';
      case Symptom.headache:
        return '🤕';
      case Symptom.backPain:
        return '💪';
      case Symptom.acne:
        return '🫣';
      case Symptom.breastTenderness:
        return '😣';
      case Symptom.nausea:
        return '🤢';
      case Symptom.fatigue:
        return '😩';
      case Symptom.moodSwings:
        return '🎭';
      case Symptom.cravings:
        return '🍫';
      case Symptom.insomnia:
        return '🌙';
    }
  }
}
