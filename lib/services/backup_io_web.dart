import 'dart:js_interop';

import 'package:file_selector/file_selector.dart';
import 'package:web/web.dart' as web;

Future<void> exportBackupFile({
  required String fileName,
  required String content,
}) async {
  final blob = web.Blob(
    <JSAny>[content.toJS].toJS,
    web.BlobPropertyBag(type: 'application/json'),
  );
  final url = web.URL.createObjectURL(blob);
  final anchor = web.HTMLAnchorElement()
    ..href = url
    ..download = fileName;

  web.document.body?.append(anchor);
  anchor.click();
  anchor.remove();
  web.URL.revokeObjectURL(url);
}

Future<String?> importBackupFile() async {
  const typeGroup = XTypeGroup(
    label: 'json',
    extensions: <String>['json'],
    mimeTypes: <String>['application/json'],
  );

  final file = await openFile(acceptedTypeGroups: <XTypeGroup>[typeGroup]);
  if (file == null) {
    return null;
  }

  return file.readAsString();
}

bool get backupIoSupported => true;
