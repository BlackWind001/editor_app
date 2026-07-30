import 'package:editor_app/base/components/EditorContainer.dart';
import 'package:editor_app/base/components/EditorsSet.dart';
import 'package:editor_app/base/components/TabsHeader.dart';
import 'package:editor_app/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('the app boots into a multi-tab editors set without errors',
      (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump();

    expect(find.byType(EditorsSet), findsOneWidget);
    expect(find.byType(TabsHeader), findsOneWidget);
    expect(find.byType(EditorContainer), findsOneWidget);
    expect(find.text('Untitled'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
