Future<void> exportBackupFile({
  required String fileName,
  required String content,
}) async {
  throw UnsupportedError('当前平台暂不支持网页导出');
}

Future<String?> importBackupFile() async {
  throw UnsupportedError('当前平台暂不支持网页导入');
}

bool get backupIoSupported => false;
