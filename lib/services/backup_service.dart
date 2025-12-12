import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'package:file_picker/file_picker.dart';
import '../models/backup_v1.dart';

/// Backup service for export/import functionality
/// Handles file operations for Web platform
class BackupService {
  /// Export backup as JSON file
  /// Downloads file to user's device (Web)
  static Future<void> exportBackup(BackupV1 backup) async {
    try {
      final jsonString = backup.toJsonString();
      final bytes = utf8.encode(jsonString);

      // Generate filename with timestamp
      final timestamp = DateTime.now();
      final filename =
          'daily_routine_backup_${timestamp.year}${timestamp.month.toString().padLeft(2, '0')}${timestamp.day.toString().padLeft(2, '0')}_${timestamp.hour.toString().padLeft(2, '0')}${timestamp.minute.toString().padLeft(2, '0')}${timestamp.second.toString().padLeft(2, '0')}.json';

      // Create blob and download (Web)
      final blob = html.Blob([bytes], 'application/json');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', filename)
        ..click();
      html.Url.revokeObjectUrl(url);
    } catch (e) {
      throw Exception('Failed to export backup: $e');
    }
  }

  /// Import backup from JSON file
  /// Returns parsed BackupV1 object or throws exception
  static Future<BackupV1> importBackup() async {
    try {
      // Pick file (Web)
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        allowMultiple: false,
        withData: true,
      );

      if (result == null || result.files.isEmpty) {
        throw Exception('No file selected');
      }

      final file = result.files.first;
      if (file.bytes == null) {
        throw Exception('Failed to read file data');
      }

      // Decode JSON
      final jsonString = utf8.decode(file.bytes!);
      final backup = BackupV1.fromJsonString(jsonString);

      return backup;
    } on FormatException catch (e) {
      // Re-throw format exceptions with user-friendly messages
      rethrow;
    } catch (e) {
      throw Exception('Failed to import backup: $e');
    }
  }

  /// Validate backup file without importing
  /// Returns true if valid, throws exception with error message if invalid
  static bool validateBackup(String jsonString) {
    try {
      BackupV1.fromJsonString(jsonString);
      return true;
    } on FormatException catch (e) {
      throw Exception('Invalid backup file: ${e.message}');
    } catch (e) {
      throw Exception('Failed to validate backup: $e');
    }
  }
}
