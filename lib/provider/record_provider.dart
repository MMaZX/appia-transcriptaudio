import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

final isRecordingProvider = StateProvider<bool>((ref) {
  return false;
});

class LogManager {
  static Future<File> _getLogFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/app.log';
    return File(path);
  }

  static Future<void> logException(dynamic e) async {
    final file = await _getLogFile();
    final timestamp = DateTime.now().toIso8601String();
    final logMessage = '$timestamp - ${e.toString()}\n';
    await file.writeAsString(logMessage, mode: FileMode.append);
    await file.writeAsString("----------------------------------- ->",
        mode: FileMode.append);
  }
}
