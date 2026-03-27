// Basic smoke test for HerFlow app
import 'package:flutter_test/flutter_test.dart';
import 'package:herflow/main.dart';

void main() {
  testWidgets('App launches without errors', (WidgetTester tester) async {
    await tester.pumpWidget(const HerFlowApp());
    // App should render without crashing
    expect(find.byType(HerFlowApp), findsOneWidget);
  });
}
