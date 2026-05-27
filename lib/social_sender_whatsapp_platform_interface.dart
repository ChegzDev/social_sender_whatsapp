import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:social_sender_whatsapp/social_sender_whatsapp_method_channel.dart';

/// The platform interface for [SocialSenderWhatsapp].
abstract class SocialSenderWhatsappPlatform extends PlatformInterface {
  /// Constructs a [SocialSenderWhatsappPlatform].
  SocialSenderWhatsappPlatform() : super(token: _token);

  static final Object _token = Object();

  static SocialSenderWhatsappPlatform _instance = MethodChannelSocialSenderWhatsapp();

  /// The default instance of [SocialSenderWhatsappPlatform] to use.
  static SocialSenderWhatsappPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [SocialSenderWhatsappPlatform].
  static set instance(SocialSenderWhatsappPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Sends a message or files to WhatsApp on the current platform.
  Future<bool> send({
    String? phone,
    String? text,
    List<String>? files,
  }) {
    throw UnimplementedError('send() has not been implemented.');
  }
}
