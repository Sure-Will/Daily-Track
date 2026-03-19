import 'backup_io_stub.dart'
    if (dart.library.html) 'backup_io_web.dart' as backup_io;

Future<void> exportBackupFile({
  required String fileName,
  required String content,
}) {
  return backup_io.exportBackupFile(fileName: fileName, content: content);
}

Future<String?> importBackupFile() {
  return backup_io.importBackupFile();
}

bool get backupIoSupported => backup_io.backupIoSupported;
