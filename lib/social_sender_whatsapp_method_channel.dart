import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'social_sender_whatsapp_platform_interface.dart';

/// An implementation of [SocialSenderWhatsappPlatform] that uses method channels.
class MethodChannelSocialSenderWhatsapp extends SocialSenderWhatsappPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('social_sender_whatsapp');

  @override
  Future<bool> send({
    String? phone,
    String? text,
    List<String>? files,
  }) async {
    return await methodChannel.invokeMethod<bool>('send', <String, dynamic>{
      'text': text ?? '',
      'phone': phone,
      'files': files,
    }) ??
        false;
  }
}
