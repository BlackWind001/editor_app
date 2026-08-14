import 'dart:convert';
import 'dart:developer';
import 'dart:ffi';
import 'dart:io';
import 'package:path/path.dart' as path;

class RipgrepHelper {
  static bool _isRipgrepPresent = false;
  static Process? _runningRG;

  RipgrepHelper._ () {
    testRipGrep();
  }

  static void _setIsRipgrepPresent (bool value) {
    _isRipgrepPresent = value;
  }

  static String? getRgPath () {
    final resourcesDir = path.join(path.dirname(Platform.resolvedExecutable), '..', 'Resources');
    Abi arch = Abi.current();
    String? rg;

    if (arch == Abi.macosArm64) {
      rg = path.join(resourcesDir, 'rg-arm');
    }
    else if (arch == Abi.macosX64) {
      rg = path.join(resourcesDir, 'rg-x86');
    }
    else {
      _setIsRipgrepPresent(false);
      throw('RipgrepHelper~testRipGrep: ERROR: Unsupported platform');
    }

    return rg;
  }

  static Future<void> testRipGrep () async {
    String? rg = getRgPath();

    if (rg == null) {
      _setIsRipgrepPresent(false);
      throw('');
    }

    if (!(await File(rg).exists())) {
      _setIsRipgrepPresent(false);
      throw('RipgrepHelper~testRipGrep: ERROR: rg not found');
    }

    try {
      await Process.run(rg, ['--version']);
    }
    catch (err) {
      _setIsRipgrepPresent(false);
      rethrow;
    }
  }

  static Stream<String>? searchFiles (String workspaceRoot, String query) async* {
    String? rg = getRgPath();

    if (rg == null || !_isRipgrepPresent) {
      return;
    }

    if (_runningRG != null) {
      _runningRG?.kill();
    }

    try {
      final process = await Process.start(
        rg,
        [
          '--files',
          '--color', 'never',
          '--line-buffered',
          query
        ],
        workingDirectory: workspaceRoot
      );

      _runningRG = process;

      yield* process.stdout
        .transform(utf8.decoder)
        .transform(const LineSplitter());

      final code = await process.exitCode;

      if (code != 0 && code != 1) {
        final err = await process.stderr.transform(utf8.decoder).join();
        log('RipgrepHelper~searchFiles: Ripgrep exit unexpectedly: $err');
      }
    }
    catch (err) {
      log('RipgrepHelper~searchFiles: Facing error $err');
    }
    finally {
      _runningRG = null;
    }
  }
}