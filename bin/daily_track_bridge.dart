import 'dart:convert';
import 'dart:io';

import 'package:daily_track/models/habit.dart';

const _defaultPort = 8765;
const _defaultDataPath = 'data/daily-track.json';

Future<void> main(List<String> args) async {
  final port = _readIntArg(args, '--port') ?? _defaultPort;
  final dataPath = _readStringArg(args, '--file') ?? _defaultDataPath;
  final dataFile = File(dataPath).absolute;

  await _ensureDataFile(dataFile);

  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, port);
  stdout.writeln('Daily Track bridge listening on http://127.0.0.1:$port');
  stdout.writeln('Data file: ${dataFile.path}');

  await for (final request in server) {
    await _handleRequest(request, dataFile);
  }
}

Future<void> _handleRequest(HttpRequest request, File dataFile) async {
  _applyCors(request.response);

  if (request.method == 'OPTIONS') {
    request.response.statusCode = HttpStatus.noContent;
    await request.response.close();
    return;
  }

  try {
    final path = request.uri.path;

    if (request.method == 'GET' && path == '/health') {
      await _sendJson(request.response, {
        'ok': true,
        'filePath': dataFile.path,
      });
      return;
    }

    if (request.method == 'GET' && path == '/habits') {
      await _sendJson(request.response, await _readPayload(dataFile));
      return;
    }

    if (request.method == 'PUT' && path == '/habits') {
      final body = await utf8.decoder.bind(request).join();
      final decoded = jsonDecode(body);
      if (decoded is! Map<String, dynamic>) {
        await _sendError(request.response, 'Payload must be a JSON object');
        return;
      }

      final payload = _normalizePayload(decoded, dataFile);
      await _writePayload(dataFile, payload);
      await _sendJson(request.response, payload);
      return;
    }

    if (request.method == 'POST' && path == '/checkins') {
      final body = await utf8.decoder.bind(request).join();
      final decoded = jsonDecode(body);
      if (decoded is! Map<String, dynamic>) {
        await _sendError(request.response, 'Payload must be a JSON object');
        return;
      }

      final payload = await _applyCheckin(dataFile, decoded);
      await _writePayload(dataFile, payload);
      await _sendJson(request.response, payload);
      return;
    }

    await _sendError(
      request.response,
      'Not found',
      statusCode: HttpStatus.notFound,
    );
  } on FormatException catch (error) {
    await _sendError(request.response, error.message);
  } catch (error) {
    await _sendError(
      request.response,
      'Bridge error: $error',
      statusCode: HttpStatus.internalServerError,
    );
  }
}

Future<Map<String, dynamic>> _applyCheckin(
  File dataFile,
  Map<String, dynamic> checkin,
) async {
  final habitId = (checkin['habitId'] as String? ?? 'fitness').trim();
  final habitTitle = (checkin['title'] as String? ?? '健身').trim();
  final dateRaw = (checkin['date'] as String? ?? '').trim();
  final completed = checkin['completed'] as bool? ?? true;

  if (habitId.isEmpty) {
    throw const FormatException('habitId is required');
  }

  final date = dateRaw.isEmpty
      ? DateTime.now()
      : DateTime.tryParse(dateRaw) ??
            (throw const FormatException('date must be YYYY-MM-DD'));
  final dateKey = Habit.dateKeyFor(date);
  final payload = await _readPayload(dataFile);
  final habits = _readHabits(payload);
  final index = habits.indexWhere((habit) => habit.id == habitId);
  final habit = index == -1
      ? Habit(id: habitId, title: habitTitle.isEmpty ? habitId : habitTitle)
      : habits[index];
  final dates = {...habit.completedDates};

  if (completed) {
    dates.add(dateKey);
  } else {
    dates.remove(dateKey);
  }

  final updatedHabit = habit.copyWith(
    title: habit.title.isEmpty ? habitTitle : habit.title,
    completedDates: (dates.toList()..sort()),
  );

  if (index == -1) {
    habits.add(updatedHabit);
  } else {
    habits[index] = updatedHabit;
  }

  return _payloadFromHabits(habits, dataFile);
}

Future<void> _ensureDataFile(File dataFile) async {
  if (await dataFile.exists()) {
    return;
  }

  await dataFile.parent.create(recursive: true);
  await _writePayload(
    dataFile,
    _payloadFromHabits(const <Habit>[
      Habit(id: 'fitness', title: '健身'),
    ], dataFile),
  );
}

Future<Map<String, dynamic>> _readPayload(File dataFile) async {
  await _ensureDataFile(dataFile);

  final decoded = jsonDecode(await dataFile.readAsString());
  if (decoded is! Map<String, dynamic>) {
    throw const FormatException('Data file must contain a JSON object');
  }

  return _normalizePayload(decoded, dataFile);
}

Map<String, dynamic> _normalizePayload(
  Map<String, dynamic> raw,
  File dataFile,
) {
  final habits = _readHabits(raw);
  return _payloadFromHabits(habits, dataFile);
}

List<Habit> _readHabits(Map<String, dynamic> payload) {
  final items = payload['habits'] as List<dynamic>? ?? <dynamic>[];
  final habits = items
      .whereType<Map<String, dynamic>>()
      .map(Habit.fromJson)
      .toList();

  return habits.isEmpty
      ? const <Habit>[Habit(id: 'fitness', title: '健身')]
      : habits;
}

Map<String, dynamic> _payloadFromHabits(List<Habit> habits, File dataFile) {
  return {
    'version': 2,
    'savedAt': DateTime.now().toIso8601String(),
    'filePath': dataFile.path,
    'habits': habits.map((habit) => habit.toJson()).toList(),
  };
}

Future<void> _writePayload(File dataFile, Map<String, dynamic> payload) async {
  await dataFile.parent.create(recursive: true);
  final tempFile = File('${dataFile.path}.tmp');
  await tempFile.writeAsString(
    const JsonEncoder.withIndent('  ').convert(payload),
  );

  if (await dataFile.exists()) {
    await dataFile.delete();
  }
  await tempFile.rename(dataFile.path);
}

Future<void> _sendJson(
  HttpResponse response,
  Map<String, dynamic> payload,
) async {
  response.headers.contentType = ContentType.json;
  response.statusCode = HttpStatus.ok;
  response.write(jsonEncode(payload));
  await response.close();
}

Future<void> _sendError(
  HttpResponse response,
  String message, {
  int statusCode = HttpStatus.badRequest,
}) async {
  response.headers.contentType = ContentType.json;
  response.statusCode = statusCode;
  response.write(jsonEncode({'error': message}));
  await response.close();
}

void _applyCors(HttpResponse response) {
  response.headers
    ..set('Access-Control-Allow-Origin', '*')
    ..set('Access-Control-Allow-Methods', 'GET, PUT, POST, OPTIONS')
    ..set('Access-Control-Allow-Headers', 'Content-Type');
}

String? _readStringArg(List<String> args, String name) {
  final index = args.indexOf(name);
  if (index == -1 || index + 1 >= args.length) {
    return null;
  }

  return args[index + 1];
}

int? _readIntArg(List<String> args, String name) {
  final value = _readStringArg(args, name);
  return value == null ? null : int.tryParse(value);
}
