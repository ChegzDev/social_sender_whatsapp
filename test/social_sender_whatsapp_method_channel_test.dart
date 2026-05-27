import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:social_sender_whatsapp/social_sender_whatsapp_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelSocialSenderWhatsapp platform = MethodChannelSocialSenderWhatsapp();
  const MethodChannel channel = MethodChannel('social_sender_whatsapp');

  group('MethodChannelSocialSenderWhatsapp', () {
    final List<MethodCall> log = <MethodCall>[];

    setUp(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        log.add(methodCall);
        switch (methodCall.method) {
          case 'send':
            return true;
          default:
            return null;
        }
      });
      log.clear();
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    test('send passes all arguments correctly', () async {
      final result = await platform.send(
        phone: "+910000000000",
        text: "Test Message",
        files: ["path/1", "path/2"],
      );

      expect(result, isTrue);
      expect(log, <Matcher>[
        isMethodCall(
          'send',
          arguments: <String, dynamic>{
            'phone': "+910000000000",
            'text': "Test Message",
            'files': ["path/1", "path/2"],
          },
        ),
      ]);
    });

    test('send handles null optional arguments', () async {
      await platform.send();

      expect(log, <Matcher>[
        isMethodCall(
          'send',
          arguments: <String, dynamic>{
            'phone': null,
            'text': '',
            'files': null,
          },
        ),
      ]);
    });

    test('send returns false if platform returns null', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        return null;
      });

      final result = await platform.send();
      expect(result, isFalse);
    });

    test('send handles platform exceptions', () async {
       TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        throw PlatformException(code: 'ERROR', message: 'Fail');
      });

      expect(() => platform.send(), throwsA(isA<PlatformException>()));
    });
  });
}
