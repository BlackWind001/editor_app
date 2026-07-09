import 'dart:developer';

import 'package:flutter/widgets.dart';


// ---------MODEL---------
class SingleTabModel {
  final String id;
  final String type;
  final String title;

  const SingleTabModel({ required this.id, required this.type, required this.title,});
}

// ---------VIEWMODEL---------
class TabsModel extends ChangeNotifier {
  List<SingleTabModel> tabs = [];
  String _name = 'TabsModel';

  TabsModel ({ List<SingleTabModel>? tabs }) {
    this.tabs = tabs ?? [];
  }

  void addTab (SingleTabModel newTab) {
    int index = tabs.indexWhere((tab) => tab.id == newTab.id);
    String methodName = '$_name~addTab';

    if (index >= 0) {
      log('Tab with id ${newTab.id} is already present', name: methodName);
      return;
    }

    tabs.add(newTab);
    notifyListeners();
  }

  void removeTab (String id) {
    int index = tabs.indexWhere((tab) => tab.id == id);
    String methodName = '$_name~removeTab';

    if (index < 0) {
      log('Tab with id $id was not present in the list', name: methodName);
      return;
    }
    
    tabs.removeAt(index);
    notifyListeners();
  }

}