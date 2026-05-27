import 'package:flutter/services.dart';
import 'social_sender_whatsapp_platform_interface.dart';

/// A class that provides methods for sending messages and files to WhatsApp.
class SocialSenderWhatsapp {
  SocialSenderWhatsapp._();

  /// Returns the singleton instance of [SocialSenderWhatsapp].
  static final SocialSenderWhatsapp instance = SocialSenderWhatsapp._();

  /// Sends a message or files to WhatsApp.
  ///
  /// The [phone] parameter is optional. If provided, it will attempt to open the chat with that number.
  /// Note: On iOS, file sharing always opens the share sheet regardless of whether a phone is provided.
  /// 
  /// The [text] parameter is optional and can be used to specify the message to send.
  /// 
  /// The [files] parameter is optional and can be used to share one or more files by providing their local paths.
  ///
  /// Returns a [Future] that completes with `true` if the operation was successful.
  ///
  /// Throws a [SocialSenderWhatsappException] if an error occurs.
  Future<bool> send({
    String? phone,
    String? text,
    List<String>? files,
  }) async {
    try {
      return await SocialSenderWhatsappPlatform.instance.send(
        phone: phone,
        text: text,
        files: files,
      );
    } on PlatformException catch (e) {
      final code = SocialSenderWhatsappExceptionType.values.where(
        (element) {
          final enumName = element.name.toLowerCase();
          final errorCode = e.code.toLowerCase().replaceAll('_', '');
          return enumName == errorCode;
        },
      ).firstOrNull ?? SocialSenderWhatsappExceptionType.unknown;
      throw SocialSenderWhatsappException(type: code, message: e.message);
    }
  }
}

/// An exception that is thrown when an error occurs while sending a message to WhatsApp.
class SocialSenderWhatsappException implements Exception {
  /// The type of exception.
  final SocialSenderWhatsappExceptionType type;

  /// The message associated with the exception.
  final String? message;

  /// Creates a new [SocialSenderWhatsappException].
  SocialSenderWhatsappException({
    required this.type,
    this.message,
  });

  @override
  String toString() => 'SocialSenderWhatsappException: $type - $message';
}

/// An enum that defines the types of exceptions that can be thrown by the [SocialSenderWhatsapp] class.
enum SocialSenderWhatsappExceptionType {
  /// WhatsApp is not installed on the device.
  whatsappNotInstalled,

  /// One or more provided file paths are invalid or inaccessible.
  fileNotFound,

  /// An unknown error occurred.
  unknown,
}
