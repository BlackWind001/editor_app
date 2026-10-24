import 'package:editor_app/base/components/CommandPalette.dart';
import 'package:editor_app/base/components/EditorsSet.dart';
import 'package:editor_app/base/helpers/ShortcutsAndActionMaps.dart';
import 'package:editor_app/base/helpers/commandPaletteShortcutsAndActions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class CommandPaletteWrapper extends StatefulWidget {
  const CommandPaletteWrapper({super.key});

  @override
  State<CommandPaletteWrapper> createState() {
    return _CommandPaletteWrapper();
  }
}

class _CommandPaletteWrapper extends State<CommandPaletteWrapper> {
  OverlayEntry? _paletteEntry;
  late ShortcutsAndActionsMaps sAndAMaps;

  @override
  void initState() {
    super.initState();

    sAndAMaps = getCommandPaletteShortcutsAndActions(
      onCmdP: _togglePalette,
      onEscape: (Intent i) => _togglePalette(i, shouldHide: true),
    );
  }

  void _togglePalette(Intent _, {bool shouldHide = false}) {
    if (shouldHide) {
      _hidePalette();
      return;
    }
    if (_paletteEntry == null) {
      _showPalette();
    } else {
      _hidePalette();
    }
  }

  void _showPalette() {
    _paletteEntry = OverlayEntry(
      builder: (context) => CommandPalette(onDismiss: _hidePalette),
    );
    Overlay.of(context).insert(_paletteEntry!);
  }

  void _hidePalette() {
    _paletteEntry?.remove();
    _paletteEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: sAndAMaps.shortcuts,
      child: Actions(actions: sAndAMaps.actions, child: EditorsSet()),
    );
  }
}
