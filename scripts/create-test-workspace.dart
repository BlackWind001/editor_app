import 'dart:io';
import 'package:path/path.dart' as path;

const TEST_WORKSPACE = 'test-workspace';
const DIR1 = 'dir1';
const FILE1 = 'file1';
const FILE2 = 'file2';
const file1Contents = 'Hello World!\nThis is file 1';
const file2Contents = 'This is file 2';

void main () async {
  await createTestWorkspace();
}

Future<Directory> getOrCreateTempDir () async {
  final scriptPath = Platform.script.toFilePath();
  final rootDir = path.dirname(path.dirname(scriptPath));
  final tempDir = Directory(path.join(rootDir, 'temp'));

  await tempDir.create();

  return tempDir;
}

Future<void> createTestWorkspace () async {
  Directory tempDir = await getOrCreateTempDir();
  Directory dir1 = Directory(path.join(tempDir.path, TEST_WORKSPACE, DIR1));

  await dir1.create(recursive: true);

  File file1 = File(path.join(dir1.path, FILE1));
  File file2 = File(path.join(dir1.path, FILE2));

  await Future.wait([
    file1.writeAsString(file1Contents),
    file2.writeAsString(file2Contents)
  ]);
}