import 'package:flutter_test/flutter_test.dart';
import 'package:ai_benchmate/main.dart';

void main() {
  testWidgets('BenchMate welcome screen loads', (tester) async {
    await tester.pumpWidget(const BenchMateApp());

    expect(find.text('Welcome to AI BenchMate'), findsOneWidget);
  });
}