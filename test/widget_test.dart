
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_benchmate/main.dart';

void main() {
  testWidgets('BenchMate welcome screen loads', (tester) async {
    await tester.pumpWidget(const BenchMateApp());

    await tester.pumpAndSettle();

    expect(find.text('AI BenchMate'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);
    expect(
      find.text('Already have an account? Login'),
      findsOneWidget,
    );
  });
}
