import 'dart:developer';
import 'dart:io';

class _WorkspaceModel {
  String? _path;
  Directory? _directory;

  void _setPath (String wPath) async {
    if (_path != null) {
      throw('NOT IMPLEMENTED');
    }

    Directory pathDir = Directory(wPath);
    bool exists = await pathDir.exists();

    if (!exists) {
      throw('Path does not exist');
    }

    _path = wPath;
    _directory = pathDir;
  }

  void _setupWatch () async {
    if (_path == null) {
      log(
        'Cannot setup workspace watchers without a valid path',
        name: '_WorkspaceModel._setupWatch'
        );
      return;
    }
  }

  void init (String wPath) {
    _setPath(wPath);
    _setupWatch();
  }
}

var WorkspaceInstance = _WorkspaceModel();
