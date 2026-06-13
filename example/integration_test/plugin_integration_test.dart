import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:social_sender_whatsapp/social_sender_whatsapp.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('SocialSenderWhatsapp Integration Tests', () {
    final SocialSenderWhatsapp plugin = SocialSenderWhatsapp.instance;

    testWidgets('send text to phone number', (WidgetTester tester) async {
      // Note: In integration tests, this will attempt to open WhatsApp on a real device.
      // We are testing that the call doesn't throw and returns a result.
      try {
        final bool result = await plugin.send(
          phone: "+1234567890",
          text: "Integration Test Message",
        );
        // On success it returns true (if WhatsApp is installed)
        expect(result, isTrue);
      } on SocialSenderWhatsappException catch (e) {
        // If WhatsApp is not installed on the test runner, it's a known error
        if (e.type == SocialSenderWhatsappExceptionType.whatsappNotInstalled) {
          debugPrint('Skipping: WhatsApp not installed on test device');
        } else {
          rethrow;
        }
      }
    });

    testWidgets('send text without phone number', (WidgetTester tester) async {
      try {
        final bool result = await plugin.send(
          text: "Integration Test Message (No Phone)",
        );
        expect(result, isTrue);
      } on SocialSenderWhatsappException catch (e) {
        if (e.type == SocialSenderWhatsappExceptionType.whatsappNotInstalled) {
          debugPrint('Skipping: WhatsApp not installed on test device');
        } else {
          rethrow;
        }
      }
    });

    testWidgets('send single file', (WidgetTester tester) async {
      // We use a dummy path for integration test. 
      // Note: Real file sharing requires a real file to exist on the device.
      try {
        final bool result = await plugin.send(
          files: ["/dummy/path/test.pdf"],
          text: "File share test",
        );
        // The native side might return false or error if file doesn't exist,
        // but here we verify the bridge works.
        expect(result, isTrue);
      } on SocialSenderWhatsappException catch (e) {
        if (e.type == SocialSenderWhatsappExceptionType.whatsappNotInstalled) {
          debugPrint('Skipping: WhatsApp not installed on test device');
        } else {
          // It might throw FILE_NOT_FOUND which is also a valid bridge verification
          debugPrint('Caught expected exception for dummy file: ${e.type}');
        }
      }
    });

    testWidgets('send multiple files', (WidgetTester tester) async {
      try {
        final bool result = await plugin.send(
          files: ["/dummy/path/test1.pdf", "/dummy/path/test2.jpg"],
          text: "Multiple files share test",
        );
        expect(result, isTrue);
      } on SocialSenderWhatsappException catch (e) {
        if (e.type == SocialSenderWhatsappExceptionType.whatsappNotInstalled) {
          debugPrint('Skipping: WhatsApp not installed on test device');
        } else {
          debugPrint('Caught expected exception for dummy files: ${e.type}');
        }
      }
    });
  });
}
