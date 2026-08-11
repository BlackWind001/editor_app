import 'package:editor_app/base/components/EditorsSet.dart';
import 'package:editor_app/base/helpers/ShortcutsAndActionMaps.dart';
import 'package:editor_app/base/helpers/commandPaletteShortcutsAndActions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class CommandPalette extends StatefulWidget {
  final VoidCallback onDismiss;

  const CommandPalette({ super.key, required this.onDismiss });

  @override
  State<CommandPalette> createState() {
    return _CommandPalette();
  }
}

class _CommandPalette extends State<CommandPalette> {
  final FocusScopeNode _focusScopeNode = FocusScopeNode();
  late ShortcutsAndActionsMaps sAndAMaps;
  late FocusNode? _prevFocus;

  @override
  void initState() {
    super.initState();

    _prevFocus = FocusManager.instance.primaryFocus;
    sAndAMaps = getCommandPaletteShortcutsAndActions(onCmdP: (_) {
      widget.onDismiss();
    });

    _focusScopeNode.addListener(_hanldeFocusChange);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusScopeNode.requestFocus();
    });
  }

  @override
  void dispose() {
    final prev = _prevFocus;

    if (prev != null && prev.context != null && prev.canRequestFocus) {
      prev.requestFocus();
    }

    _focusScopeNode.removeListener(_hanldeFocusChange);
    _focusScopeNode.dispose();
    super.dispose();
  }

  void _hanldeFocusChange () {
    print('_handleFocusChange: { hasFocus: ${_focusScopeNode.hasFocus} }');
    if (!_focusScopeNode.hasFocus) {
      widget.onDismiss();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: sAndAMaps.shortcuts,
      child: Actions(
        actions: sAndAMaps.actions,
        child: FocusScope(
          node: _focusScopeNode,
            child: LayoutBuilder(
            builder: (context, constraints) {
              double parentWidth = constraints.maxWidth;
              double parentHeight = constraints.maxHeight;
              return Container(
                margin: EdgeInsets.only(
                  top: parentHeight * 0.1,
                  left: parentWidth * 0.1,
                  right: parentWidth * 0.1,
                  bottom: parentHeight * 0.1
                ),
                color: Colors.amber
              );
            }
          ),
        ),
      )
    );
  }
}

class CommandPaletteWrapper extends StatefulWidget {
  const CommandPaletteWrapper({ super.key });

  @override
  State<CommandPaletteWrapper> createState() {
    return _CommandPaletteWrapper();
  }
}

class _CommandPaletteWrapper extends State<CommandPaletteWrapper> {
  OverlayEntry? _paletteEntry;
  late ShortcutsAndActionsMaps sAndAMaps;

  @override
  void initState () {
    super.initState();

    sAndAMaps = getCommandPaletteShortcutsAndActions(onCmdP: _togglePalette);
  }

  void _togglePalette (Intent _) {
    if (_paletteEntry == null) {
      _showPalette();
    }
    else {
      _hidePalette();
    }
  }

  void _showPalette () {
    _paletteEntry = OverlayEntry(
      builder: (context) => CommandPalette(onDismiss: _hidePalette)
    );
    Overlay.of(context).insert(_paletteEntry!);
  }

  void _hidePalette () {
    _paletteEntry?.remove();
    _paletteEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: sAndAMaps.shortcuts,
      child: Actions(
        actions: sAndAMaps.actions,
        child: EditorsSet(),
      ),
    );
  }
}