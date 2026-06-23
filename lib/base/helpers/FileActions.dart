import 'dart:io';

import 'package:editor_app/types/OpResult.dart';

class FileActions {
  static Future<File?> getFileIfExists (String path) async {
    File f = File(path);
    bool exists = await f.exists();

    if (exists) {
      return f;
    }

    return null;
  }

  static Future<List<String>?> getFileLines (File f) async {
    bool exists = await f.exists();

    if (!exists) {
      return null;
    }

    return await f.readAsLines();
  }

  static Future<OpResult> saveFile (File f, String contents) async {
    bool exists = await f.exists();

    if (!exists) {
      return OpResult(success: false, errMsg: 'File does not exist');
    }

    f.writeAsString(contents, flush: true);

    return OpResult(success: true);
  }
}