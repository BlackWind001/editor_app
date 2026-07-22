import 'package:editor_app/base/models/EditorSettings.dart';
import 'package:editor_app/base/models/TabsModel.dart';
import 'package:editor_app/base/styles/editorStyles.dart';
import 'package:editor_app/constants/editor.dart';
import 'package:flutter/material.dart';

const MAX_CHARS = 30;

typedef CreateTabCallback = void Function();
typedef CloseTabCallback = void Function(String id);
typedef ClickTabCallback = void Function(String id);

class _Tab extends StatefulWidget {
  final SingleTabModel model;
  final CloseTabCallback onClose;
  final ClickTabCallback onClick;
  final bool isActive;

  const _Tab({ super.key, required this.model, required this.onClose, required this.onClick, required this.isActive });

  @override
  State<_Tab> createState() => _TabImpl();
}

class _TabImpl extends State<_Tab> {
  late double tabHeight;
  late double tabVerticalPadding;
  late double tabHorizontalPadding;
  late double tabContentSpacing;
  late double tabIconSize;
  TextStyle tabTextStyle = getContentStyle();

  @override
  void initState() {
    super.initState();

    determineTabStyles();

    edSettings.addListener(updateTabStyles);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      determineTextStyle();
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    edSettings.removeListener(updateTabStyles);
  }

  void determineTabStyles () {
    tabVerticalPadding = edSettings.fontSize * 0.5;
    tabHorizontalPadding = edSettings.fontSize * 0.75;
    tabHeight = edSettings.lineHeightMultiplier * edSettings.fontSize + 2*tabVerticalPadding;
    tabContentSpacing = edSettings.fontSize * 1;
    tabIconSize = edSettings.fontSize * 1;
  }

  void updateTabStyles () {
    determineTabStyles();
    determineTextStyle();
    setState(() {});
  }

  void determineTextStyle () {
    final TextStyle defaultStyle = DefaultTextStyle.of(context).style;
    final TextStyle customStyle = TextStyle(
      color: widget.isActive ? ACTIVE_TAB_FOREGROUND : INACTIVE_TAB_FOREGROUND
    );

    tabTextStyle = defaultStyle.merge(getContentStyle()).merge(customStyle);
  }

  @override
  Widget build(BuildContext context) {

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => widget.onClick(widget.model.id),
        child: Container(
          height: tabHeight,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blueAccent.shade100, width: 1),
            color: widget.isActive ? ACTIVE_TAB_BACKGROUND : INACTIVE_TAB_BACKGROUND
          ),
          padding: EdgeInsetsGeometry.symmetric(
            vertical: tabVerticalPadding,
            horizontal: tabHorizontalPadding
          ),
          child: Row(
            spacing: tabContentSpacing,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.model.title,
                style: tabTextStyle,
              ),
              IconButton(
                onPressed: () { widget.onClose(widget.model.id); },
                constraints: BoxConstraints(),
                icon: Icon(Icons.close),
                style: IconButton.styleFrom(
                  padding: EdgeInsets.zero,
                  iconSize: tabIconSize,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                ),
            )
            ],
          ),
        )
      )
    );
  }

}

class TabsHeader extends StatefulWidget {

  final TabsModel model;
  final String? activeTabId;
  final CreateTabCallback onCreateNewTab;
  final CloseTabCallback onCloseTab;
  final ClickTabCallback onClickOnTab;

  const TabsHeader({
    super.key,
    required this.model,
    required this.activeTabId,
    required this.onCloseTab,
    required this.onCreateNewTab,
    required this.onClickOnTab
  });

  @override
  State<TabsHeader> createState() => _TabsHeader();
}

class _TabsHeader extends State<TabsHeader> {

  late TabsModel model;

  @override
  void initState() {
    super.initState();

    model = widget.model;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Wrap(
            children: [
              ...model.tabs.map((tab) {
                return _Tab(
                  model: tab,
                  onClose: widget.onCloseTab,
                  onClick: widget.onClickOnTab,
                  isActive: widget.activeTabId == tab.id
                );
              })
            ],
          )
        ),
        IconButton(
          onPressed: () {
            widget.onCreateNewTab();
          },
          icon: Icon(Icons.add),
          iconSize: 12.0,
          style: IconButton.styleFrom(
            backgroundColor: Colors.amber,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            fixedSize: Size(16.0, 16.0)
          ),
        )
      ],
    );
  }
}
