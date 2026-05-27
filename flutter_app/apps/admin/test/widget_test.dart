import 'package:flutter_test/flutter_test.dart';
import 'package:gomandap_admin/app.dart';

void main() {
  testWidgets('AdminApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const AdminApp());
    expect(find.byType(AdminApp), findsOneWidget);
  });
}
