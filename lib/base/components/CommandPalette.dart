import 'package:editor_app/base/helpers/Ripgrep.dart';
import 'package:editor_app/base/helpers/ShortcutsAndActionMaps.dart';
import 'package:editor_app/base/helpers/commandPaletteShortcutsAndActions.dart';
import 'package:editor_app/base/models/WorkspaceModel.dart';
import 'package:editor_app/constants/editor.dart';
import 'package:flutter/material.dart';

typedef SubmitCallback = void Function(String text);

class CPInput extends StatefulWidget {
  SubmitCallback onSubmit;

  CPInput({super.key, required this.onSubmit});

  @override
  State<CPInput> createState() {
    return _CPInput();
  }
}

class _CPInput extends State<CPInput> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      focusNode: _focusNode,
      decoration: InputDecoration(
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.amber, width: 2.0),
        ),
        hintText: 'Enter a search term',
        fillColor: EDITOR_BACKGROUND,
        filled: true,
      ),
      cursorColor: Colors.amber,
      onSubmitted: (text) => widget.onSubmit(text),
    );
  }
}

class CommandPalette extends StatefulWidget {
  final VoidCallback onDismiss;

  const CommandPalette({super.key, required this.onDismiss});

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
    sAndAMaps = getCommandPaletteShortcutsAndActions(
      onCmdP: (_) {
        widget.onDismiss();
      },
      onEscape: (_) {
        widget.onDismiss();
      },
    );

    _focusScopeNode.addListener(_hanldeFocusChange);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusScopeNode.requestFocus();
    });
  }

  @override
  void dispose() {
    // The following sets the focus to the widget that held the focus previously.
    // This could come back to bite me in the butt later.
    // Butt
    // Big butt
    // I like big butts and I cannot lie.
    // You other brothers can't deny
    // When a girl walks in with an itty bitty waist and a.....
    final prev = _prevFocus;
    if (prev != null && prev.context != null && prev.canRequestFocus) {
      prev.requestFocus();
    }

    _focusScopeNode.removeListener(_hanldeFocusChange);
    _focusScopeNode.dispose();
    super.dispose();
  }

  void _hanldeFocusChange() {
    if (!_focusScopeNode.hasFocus) {
      widget.onDismiss();
    }
  }

  void handleInputSubmit(String text) {
    if (workspaceViewModel.getWorkspacePath().isEmpty) {
      return;
    }

    RipgrepHelper.searchFiles(
      workspaceViewModel.getWorkspacePath(),
      text,
    )?.listen((data) {}, onDone: () {});
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
                  bottom: parentHeight * 0.1,
                ),
                decoration: BoxDecoration(
                  color: EDITOR_BACKGROUND,
                  border: Border.all(color: Colors.amber, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                child: Column(
                  children: [
                    Expanded(child: Container()),
                    Material(
                      color: Colors.transparent,
                      child: CPInput(onSubmit: handleInputSubmit),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
