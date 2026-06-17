import 'package:flutter/material.dart';

typedef IntentToActionMap = Map<Type, Action<Intent>>;
typedef ActivatorToIntentMap = Map<ShortcutActivator, Intent>;

class ShortcutsAndActionsMaps {
  ActivatorToIntentMap shortcuts = {};
  IntentToActionMap actions = {};
}
