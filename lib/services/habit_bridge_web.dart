import 'dart:convert';
import 'dart:js_interop';

import 'package:web/web.dart' as web;

import 'habit_bridge_types.dart';
import '../models/habit.dart';

const _bridgeBaseUrl = 'http://127.0.0.1:8765';

Future<HabitBridgeSnapshot?> loadFromBridge() {
  return _sendBridgeRequest('GET', '/habits');
}

Future<HabitBridgeSnapshot?> saveToBridge(List<Habit> habits) {
  return _sendBridgeRequest(
    'PUT',
    '/habits',
    body: jsonEncode({
      'version': 2,
      'savedAt': DateTime.now().toIso8601String(),
      'habits': habits.map((habit) => habit.toJson()).toList(),
    }),
  );
}

Future<HabitBridgeSnapshot?> _sendBridgeRequest(
  String method,
  String path, {
  String? body,
}) async {
  try {
    final headers =
        <String, String>{'Content-Type': 'application/json'}.jsify()!
            as web.HeadersInit;
    final init = web.RequestInit(
      method: method,
      headers: headers,
      body: body?.toJS,
    );
    final response = await web.window
        .fetch('$_bridgeBaseUrl$path'.toJS, init)
        .toDart;

    if (!response.ok) {
      return null;
    }

    final text = (await response.text().toDart).toDart;
    final decoded = jsonDecode(text);
    if (decoded is! Map<String, dynamic>) {
      return null;
    }

    return HabitBridgeSnapshot.fromJson(decoded);
  } catch (_) {
    return null;
  }
}

void setDataPathOverrideForTesting(String? path) {}

void setDisabledForTesting(bool isDisabled) {}
