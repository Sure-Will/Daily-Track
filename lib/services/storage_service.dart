import 'package:shared_preferences/shared_preferences.dart';
import '../models/backup_v1.dart';

/// Local storage service using SharedPreferences
/// Persists habit data to browser localStorage (Web) or device storage (Mobile)
class StorageService {
  static const String _keyHabitsData = 'daily_routine_habits_data';

  /// Save habits to local storage
  static Future<void> saveHabits(BackupV1 backup) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = backup.toJsonString();
      await prefs.setString(_keyHabitsData, jsonString);
    } catch (e) {
      throw Exception('Failed to save habits to local storage: $e');
    }
  }

  /// Load habits from local storage
  /// Returns null if no data exists
  static Future<BackupV1?> loadHabits() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_keyHabitsData);

      if (jsonString == null || jsonString.isEmpty) {
        return null;
      }

      return BackupV1.fromJsonString(jsonString);
    } catch (e) {
      // If data is corrupted, return null instead of crashing
      print('Failed to load habits from local storage: $e');
      return null;
    }
  }

  /// Clear all habit data from local storage
  static Future<void> clearHabits() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyHabitsData);
    } catch (e) {
      throw Exception('Failed to clear habits from local storage: $e');
    }
  }

  /// Check if habit data exists in local storage
  static Future<bool> hasHabits() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey(_keyHabitsData);
    } catch (e) {
      return false;
    }
  }
}
