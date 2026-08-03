import 'dart:developer';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;

var DARWIN_ARM64_FILE_NAME = 'ripgrep-15.2.0-aarch64-apple-darwin';
var DARWIN_X86_FILE_NAME = 'ripgrep-15.2.0-x86_64-apple-darwin';
var DARWIN_ARM64_URI = Uri.https('github.com', 'BurntSushi/ripgrep/releases/download/15.2.0/$DARWIN_ARM64_FILE_NAME.tar.gz');
var DARWIN_X86_URI = Uri.https('github.com', 'BurntSushi/ripgrep/releases/download/15.2.0/$DARWIN_X86_FILE_NAME.tar.gz');


Future<void> downloadAndSave (Uri uri, String filePath) async {
  final http.Response response = await http.get(uri);

  if (response.statusCode == 200) {
    final File file = File(filePath);

    await file.parent.create(recursive: true);

    if (await file.exists()) {
      log('File $filePath already exists');
      return;
    }

    await file.writeAsBytes(response.bodyBytes);
  }
  else {
    log('Server error ${response.statusCode}');
  }
}

Future<void> unpack (String filePath) async {
  File file = File(filePath);

  if (!await file.exists()) {
    throw '$filePath does not exist';
  }

  final result = await Process.run('tar', [
    '-xzf', filePath,
    '-C', file.parent.path
  ]);

  if (result.exitCode != 0) {
    throw Exception('Extraction failed: ${result.stderr}');
  }
}

Future<void> downloadAssets () async{
  String currentDir = File(Platform.script.toFilePath()).parent.path;
  if (Platform.isMacOS) {
    String armSavePath = path.join(currentDir, '..', 'external', 'ripgrep', 'darwin', 'arm', 'ripgrep.tar.gz');
    String x86SavePath = path.join(currentDir, '..', 'external', 'ripgrep', 'darwin', 'x86', 'ripgrep.tar.gz');
    String resourcesPath = path.join(currentDir, '..', 'macos', 'Runner', 'Resources');
    String armFinalDestinationPath = path.join(resourcesPath, 'rg-arm');
    String x86FinalDestinationPath = path.join(resourcesPath, 'rg-x86');

    // ARM download, unpack and move
    await downloadAndSave(
      DARWIN_ARM64_URI,
      armSavePath
    );
    await unpack(armSavePath);
    File armExec = File(path.join(currentDir, '..', 'external', 'ripgrep', 'darwin', 'arm', DARWIN_ARM64_FILE_NAME, 'rg'));
    await Directory(resourcesPath).create(recursive: true);
    await armExec.rename(armFinalDestinationPath);


    // X86 download, unpack and move
    await downloadAndSave(DARWIN_X86_URI, x86SavePath);
    await unpack(x86SavePath);
    File x86Exec = File(path.join(currentDir, '..', 'external', 'ripgrep', 'darwin', 'x86', DARWIN_X86_FILE_NAME, 'rg'));
    await x86Exec.rename(x86FinalDestinationPath);
  }
}

void main () async {
  await downloadAssets();
}
