import 'dart:io';

class Fileloader {
  static List<String> getFileContentsSync (String filePath) {
    var fileInstance = File(filePath);
    return fileInstance.readAsLinesSync();
  }
}