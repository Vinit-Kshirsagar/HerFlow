import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../core/constants/enums.dart';
import '../core/constants/models.dart';
import '../services/local_storage_service.dart';
import '../services/cycle_prediction_service.dart';

/// Main app state provider
class AppProvider extends ChangeNotifier {
  final LocalStorageService _storage = LocalStorageService();

  UserProfile _profile = UserProfile();
  List<PeriodEntry> _periodEntries = [];
  List<CheckInEntry> _checkInEntries = [];
  CyclePrediction? _prediction;
  CyclePhase _currentPhase = CyclePhase.unknown;
  int _cycleDay = 0;
  bool _isLoading = true;

  // Getters
  UserProfile get profile => _profile;
  List<PeriodEntry> get periodEntries => _periodEntries;
  List<CheckInEntry> get checkInEntries => _checkInEntries;
  CyclePrediction? get prediction => _prediction;
  CyclePhase get currentPhase => _currentPhase;
  int get cycleDay => _cycleDay;
  bool get isLoading => _isLoading;
  bool get hasCompletedOnboarding => _profile.onboardingComplete;

  /// Initialize storage and load data
  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    await _storage.init();

    // Load profile
    final savedProfile = _storage.getProfile();
    if (savedProfile != null) {
      _profile = savedProfile;
    }

    // Load period entries
    _periodEntries = _storage.getPeriodEntries();

    // Load check-in entries
    _checkInEntries = _storage.getCheckInEntries();

    // Compute predictions
    _refreshPredictions();

    _isLoading = false;
    notifyListeners();
  }

  // ─── Profile ───
  Future<void> updateProfile(UserProfile profile) async {
    _profile = profile;
    await _storage.saveProfile(profile);
    _refreshPredictions();
    notifyListeners();
  }

  Future<void> completeOnboarding({
    required String name,
    required DateTime lastPeriodDate,
  }) async {
    // Create initial period entry from onboarding
    final entry = PeriodEntry(
      id: const Uuid().v4(),
      startDate: lastPeriodDate,
    );
    await _storage.addPeriodEntry(entry);
    _periodEntries = _storage.getPeriodEntries();

    _profile = _profile.copyWith(
      name: name,
      lastPeriodDate: lastPeriodDate,
      onboardingComplete: true,
    );
    await _storage.saveProfile(_profile);

    _refreshPredictions();
    notifyListeners();
  }

  // ─── Period Logs ───
  Future<void> logPeriodStart(DateTime startDate,
      {FlowIntensity intensity = FlowIntensity.medium}) async {
    final entry = PeriodEntry(
      id: const Uuid().v4(),
      startDate: startDate,
      intensity: intensity,
    );
    await _storage.addPeriodEntry(entry);
    _periodEntries = _storage.getPeriodEntries();
    _refreshPredictions();
    notifyListeners();
  }

  Future<void> logPeriodEnd(String entryId, DateTime endDate) async {
    final entry = _periodEntries.firstWhere((e) => e.id == entryId);
    final updated = entry.copyWith(endDate: endDate);
    await _storage.updatePeriodEntry(updated);
    _periodEntries = _storage.getPeriodEntries();
    _refreshPredictions();
    notifyListeners();
  }

  Future<void> updatePeriodIntensity(
      String entryId, FlowIntensity intensity) async {
    final entry = _periodEntries.firstWhere((e) => e.id == entryId);
    final updated = entry.copyWith(intensity: intensity);
    await _storage.updatePeriodEntry(updated);
    _periodEntries = _storage.getPeriodEntries();
    notifyListeners();
  }

  /// Get the latest period (the one that's possibly still active)
  PeriodEntry? get activePeriod {
    if (_periodEntries.isEmpty) return null;
    final latest = _periodEntries.first;
    if (latest.endDate == null) return latest;
    return null;
  }

  // ─── Check-ins ───
  Future<void> submitCheckIn({
    required List<Mood> moods,
    required List<Symptom> symptoms,
    FlowIntensity? flowIntensity,
    String? notes,
  }) async {
    final entry = CheckInEntry(
      id: const Uuid().v4(),
      date: DateTime.now(),
      moods: moods,
      symptoms: symptoms,
      flowIntensity: flowIntensity,
      notes: notes,
    );
    await _storage.addCheckInEntry(entry);
    _checkInEntries = _storage.getCheckInEntries();

    // Update streak
    _profile = _profile.copyWith(streak: _profile.streak + 1);
    await _storage.saveProfile(_profile);

    notifyListeners();
  }

  bool get hasCheckedInToday {
    final now = DateTime.now();
    return _checkInEntries.any((e) =>
        e.date.year == now.year &&
        e.date.month == now.month &&
        e.date.day == now.day);
  }

  CheckInEntry? get todaysCheckIn {
    final now = DateTime.now();
    try {
      return _checkInEntries.firstWhere((e) =>
          e.date.year == now.year &&
          e.date.month == now.month &&
          e.date.day == now.day);
    } catch (_) {
      return null;
    }
  }

  // ─── Predictions ───
  void _refreshPredictions() {
    _prediction = CyclePredictionService.predictNextCycle(_periodEntries);
    _currentPhase =
        CyclePredictionService.getCurrentPhase(_periodEntries, _prediction);
    _cycleDay = CyclePredictionService.getCycleDay(_periodEntries);
  }

  // ─── Phase helpers ───
  Color getPhaseColor() {
    switch (_currentPhase) {
      case CyclePhase.period:
        return const Color(0xFFE8749A);
      case CyclePhase.follicular:
        return const Color(0xFFC084FC);
      case CyclePhase.ovulation:
        return const Color(0xFF6EE7B7);
      case CyclePhase.luteal:
        return const Color(0xFFFBBF24);
      case CyclePhase.unknown:
        return const Color(0xFFB89AAB);
    }
  }

  Color getPhaseColorLight() {
    switch (_currentPhase) {
      case CyclePhase.period:
        return const Color(0xFFFCE4EC);
      case CyclePhase.follicular:
        return const Color(0xFFF3E8FF);
      case CyclePhase.ovulation:
        return const Color(0xFFD1FAE5);
      case CyclePhase.luteal:
        return const Color(0xFFFEF3C7);
      case CyclePhase.unknown:
        return const Color(0xFFF5EDF1);
    }
  }

  // ─── Aliases used by screens ───

  /// Alias for updateProfile – called from settings_screen
  Future<void> saveProfile(UserProfile profile) => updateProfile(profile);

  /// Quick check-in – called from checkin_screen
  Future<void> saveCheckIn({
    required Mood mood,
    List<Symptom> symptoms = const [],
    FlowLevel? flow,
    String? note,
  }) async {
    await submitCheckIn(
      moods: [mood],
      symptoms: symptoms,
      flowIntensity: flow != null
          ? FlowIntensity.values[flow.index.clamp(0, FlowIntensity.values.length - 1)]
          : null,
      notes: note,
    );
  }

  /// Wipe all data – called from settings_screen
  Future<void> clearAllData() async {
    _profile = UserProfile();
    _periodEntries = [];
    _checkInEntries = [];
    _prediction = null;
    _currentPhase = CyclePhase.unknown;
    _cycleDay = 0;
    await _storage.clearAll();
    notifyListeners();
  }
}
