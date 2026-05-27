import 'package:flutter_test/flutter_test.dart';
import 'package:social_sender_whatsapp_example/main.dart';

void main() {
  testWidgets('Verify Example UI has all buttons', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that buttons are present
    expect(find.text('Send Text to Number'), findsOneWidget);
    expect(find.text('Send Text (Optional Number)'), findsOneWidget);
    expect(find.text('Send Single File'), findsOneWidget);
    expect(find.text('Send Multiple Files'), findsOneWidget);
  });
}
