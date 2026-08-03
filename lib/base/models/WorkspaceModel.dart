import 'dart:developer';
import 'dart:io';

class WorkspaceModel {
  String path = '';

  String get dirName {
    // ToDo: Get the path name here
    return '';
  }

  WorkspaceModel ();

  WorkspaceModel.fromPath (String path) {
    updatePath(path);
  }

  void updatePath (String path) {
    this.path = path;
  }
}

class WorkspaceViewModel {
  late WorkspaceModel model;
  String name = 'WorkspaceViewModel';

  WorkspaceViewModel () {
    model = WorkspaceModel();
  }

  void updatePath (String path) async {
    Directory pathDir = Directory(path);
    String name = '${this.name}~updatePath';

    if (!(await pathDir.exists())) {
      throw('$name: Path does not exist');
    }

    model.updatePath(path);
  }
  
}
