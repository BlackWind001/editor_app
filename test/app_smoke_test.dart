import 'package:editor_app/base/components/EditorContainer.dart';
import 'package:editor_app/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('the app boots into the editor without errors', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump();

    expect(find.byType(EditorContainer), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
