import 'package:flutter_test/flutter_test.dart';
import 'package:gomandap_vendor/app.dart';

void main() {
  testWidgets('VendorApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const VendorApp());
    expect(find.byType(VendorApp), findsOneWidget);
  });
}
