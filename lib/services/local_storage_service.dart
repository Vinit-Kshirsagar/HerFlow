import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/models.dart';

/// Local storage service using SharedPreferences
class LocalStorageService {
  static const String _profileKey = 'user_profile';
  static const String _periodsKey = 'period_entries';
  static const String _checkInsKey = 'checkin_entries';

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ─── Profile ───
  Future<void> saveProfile(UserProfile profile) async {
    await _prefs.setString(_profileKey, jsonEncode(profile.toMap()));
  }

  UserProfile? getProfile() {
    final data = _prefs.getString(_profileKey);
    if (data == null) return null;
    return UserProfile.fromMap(jsonDecode(data) as Map<String, dynamic>);
  }

  // ─── Period Entries ───
  Future<void> savePeriodEntries(List<PeriodEntry> entries) async {
    final data = entries.map((e) => jsonEncode(e.toMap())).toList();
    await _prefs.setStringList(_periodsKey, data);
  }

  List<PeriodEntry> getPeriodEntries() {
    final data = _prefs.getStringList(_periodsKey);
    if (data == null) return [];
    return data
        .map((e) =>
            PeriodEntry.fromMap(jsonDecode(e) as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.startDate.compareTo(a.startDate));
  }

  Future<void> addPeriodEntry(PeriodEntry entry) async {
    final entries = getPeriodEntries();
    entries.add(entry);
    await savePeriodEntries(entries);
  }

  Future<void> updatePeriodEntry(PeriodEntry entry) async {
    final entries = getPeriodEntries();
    final index = entries.indexWhere((e) => e.id == entry.id);
    if (index != -1) {
      entries[index] = entry;
      await savePeriodEntries(entries);
    }
  }

  Future<void> deletePeriodEntry(String id) async {
    final entries = getPeriodEntries();
    entries.removeWhere((e) => e.id == id);
    await savePeriodEntries(entries);
  }

  // ─── Check-in Entries ───
  Future<void> saveCheckInEntries(List<CheckInEntry> entries) async {
    final data = entries.map((e) => jsonEncode(e.toMap())).toList();
    await _prefs.setStringList(_checkInsKey, data);
  }

  List<CheckInEntry> getCheckInEntries() {
    final data = _prefs.getStringList(_checkInsKey);
    if (data == null) return [];
    return data
        .map((e) =>
            CheckInEntry.fromMap(jsonDecode(e) as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> addCheckInEntry(CheckInEntry entry) async {
    final entries = getCheckInEntries();
    // Remove existing entry for the same day
    entries.removeWhere((e) =>
        e.date.year == entry.date.year &&
        e.date.month == entry.date.month &&
        e.date.day == entry.date.day);
    entries.add(entry);
    await saveCheckInEntries(entries);
  }

  CheckInEntry? getCheckInForDate(DateTime date) {
    final entries = getCheckInEntries();
    try {
      return entries.firstWhere((e) =>
          e.date.year == date.year &&
          e.date.month == date.month &&
          e.date.day == date.day);
    } catch (_) {
      return null;
    }
  }

  // ─── Clear all ───
  Future<void> clearAll() async {
    await _prefs.clear();
  }
}
