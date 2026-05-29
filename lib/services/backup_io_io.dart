import 'dart:io';

import 'package:file_selector/file_selector.dart';

const _jsonTypeGroup = XTypeGroup(
  label: 'json',
  extensions: <String>['json'],
  mimeTypes: <String>['application/json'],
);

Future<void> exportBackupFile({
  required String fileName,
  required String content,
}) async {
  final location = await getSaveLocation(
    acceptedTypeGroups: const <XTypeGroup>[_jsonTypeGroup],
    suggestedName: fileName,
  );
  if (location == null) {
    return;
  }

  await File(location.path).writeAsString(content);
}

Future<String?> importBackupFile() async {
  final file = await openFile(
    acceptedTypeGroups: const <XTypeGroup>[_jsonTypeGroup],
  );
  if (file == null) {
    return null;
  }

  return file.readAsString();
}

bool get backupIoSupported => true;
