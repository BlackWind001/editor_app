import 'package:editor_app/base/models/EditorSettings.dart';
import 'package:editor_app/base/models/TabsModel.dart';
import 'package:editor_app/base/styles/editorStyles.dart';
import 'package:flutter/material.dart';

const MAX_CHARS = 30;

class _Tab extends StatefulWidget {
  final String title;

  const _Tab({ super.key, required this.title });

  @override
  State<_Tab> createState() => _TabImpl();
}

class _TabImpl extends State<_Tab> {
  late String title;
  late double tabHeight;
  late double tabVerticalPadding;
  late double tabHorizontalPadding;
  late double tabContentSpacing;
  TextStyle tabTextStyle = getContentStyle();

  @override
  void initState() {
    super.initState();

    title = widget.title;
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
  }

  void updateTabStyles () {
    determineTabStyles();
    determineTextStyle();
    setState(() {});
  }

  void determineTextStyle () {
    final TextStyle defaultStyle = DefaultTextStyle.of(context).style;
    final TextStyle customStyle = TextStyle(
      color: Colors.red
    );

    tabTextStyle = defaultStyle.merge(getContentStyle()).merge(customStyle);
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      height: tabHeight,
      padding: EdgeInsetsGeometry.symmetric(
        vertical: tabVerticalPadding,
        horizontal: tabHorizontalPadding
      ),
      child: Row(
        spacing: tabContentSpacing,
        children: [
          Text(
            title,
            style: tabTextStyle,
          ),
          Icon(
            Icons.close,
            size: edSettings.fontSize,
          )
        ],
      ),
    );
  }

}

class TabsHeader extends StatefulWidget {

  final TabsModel model;

  const TabsHeader({ super.key, required this.model });

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
                return _Tab(title: tab.title ?? '');
              })
            ],
          )
        ),
        // IconButton(
        //   onPressed: () {},
        //   icon: Icon(Icons.add),
        //   iconSize: 12.0,
        //   style: IconButton.styleFrom(
        //     backgroundColor: Colors.amber,
        //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        //     fixedSize: Size(16.0, 16.0)
        //   ),
        // )
      ],
    );
  }
}
