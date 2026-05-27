import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:social_sender_whatsapp/social_sender_whatsapp.dart';
import 'package:social_sender_whatsapp/social_sender_whatsapp_platform_interface.dart';
import 'package:social_sender_whatsapp/social_sender_whatsapp_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockSocialSenderWhatsappPlatform
    with MockPlatformInterfaceMixin
    implements SocialSenderWhatsappPlatform {
  bool sendCalled = false;
  String? lastPhone;
  String? lastText;
  List<String>? lastFiles;
  bool returnSuccess = true;
  PlatformException? throwException;

  @override
  Future<bool> send({String? phone, String? text, List<String>? files}) async {
    sendCalled = true;
    lastPhone = phone;
    lastText = text;
    lastFiles = files;
    if (throwException != null) {
      throw throwException!;
    }
    return returnSuccess;
  }
}

void main() {
  final SocialSenderWhatsappPlatform initialPlatform =
      SocialSenderWhatsappPlatform.instance;

  test('$MethodChannelSocialSenderWhatsapp is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelSocialSenderWhatsapp>());
  });

  group('SocialSenderWhatsapp (Public API)', () {
    late SocialSenderWhatsapp plugin;
    late MockSocialSenderWhatsappPlatform mockPlatform;

    setUp(() {
      plugin = SocialSenderWhatsapp.instance;
      mockPlatform = MockSocialSenderWhatsappPlatform();
      SocialSenderWhatsappPlatform.instance = mockPlatform;
    });

    test('send calls platform with correct arguments', () async {
      final result = await plugin.send(
        phone: "+1234567890",
        text: "Hello",
        files: ["path/to/file.pdf"],
      );

      expect(mockPlatform.sendCalled, isTrue);
      expect(mockPlatform.lastPhone, "+1234567890");
      expect(mockPlatform.lastText, "Hello");
      expect(mockPlatform.lastFiles, ["path/to/file.pdf"]);
      expect(result, isTrue);
    });

    test('send works with only text', () async {
      await plugin.send(text: "Only text");
      expect(mockPlatform.lastPhone, isNull);
      expect(mockPlatform.lastText, "Only text");
      expect(mockPlatform.lastFiles, isNull);
    });

    test('send works with only phone', () async {
      await plugin.send(phone: "+1234567890");
      expect(mockPlatform.lastPhone, "+1234567890");
      expect(mockPlatform.lastText, isNull);
      expect(mockPlatform.lastFiles, isNull);
    });

    test('send works with only files', () async {
      await plugin.send(files: ["f1", "f2"]);
      expect(mockPlatform.lastPhone, isNull);
      expect(mockPlatform.lastText, isNull);
      expect(mockPlatform.lastFiles, ["f1", "f2"]);
    });

    test('throws SocialSenderWhatsappException on whatsappNotInstalled', () async {
      mockPlatform.throwException = PlatformException(
        code: 'WHATSAPP_NOT_INSTALLED',
        message: 'WhatsApp not found',
      );

      expect(
        () => plugin.send(phone: "123"),
        throwsA(isA<SocialSenderWhatsappException>().having(
          (e) => e.type,
          'type',
          SocialSenderWhatsappExceptionType.whatsappNotInstalled,
        )),
      );
    });

    test('throws SocialSenderWhatsappException on fileNotFound', () async {
      mockPlatform.throwException = PlatformException(
        code: 'FILE_NOT_FOUND',
        message: 'File not found',
      );

      expect(
        () => plugin.send(files: ["bad/path"]),
        throwsA(isA<SocialSenderWhatsappException>().having(
          (e) => e.type,
          'type',
          SocialSenderWhatsappExceptionType.fileNotFound,
        )),
      );
    });

    test('throws SocialSenderWhatsappException on unknown error', () async {
      mockPlatform.throwException = PlatformException(
        code: 'RANDOM_ERROR',
        message: 'Something went wrong',
      );

      expect(
        () => plugin.send(phone: "123"),
        throwsA(isA<SocialSenderWhatsappException>().having(
          (e) => e.type,
          'type',
          SocialSenderWhatsappExceptionType.unknown,
        )),
      );
    });
  });
}
