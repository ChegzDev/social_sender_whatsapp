# Social Sender WhatsApp

[![Pub Version](https://img.shields.io/pub/v/social_sender_whatsapp?color=blue)](https://pub.dev/packages/social_sender_whatsapp)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Pub Likes](https://img.shields.io/pub/likes/social_sender_whatsapp)](https://pub.dev/packages/social_sender_whatsapp/score)
[![Pub Points](https://img.shields.io/pub/points/social_sender_whatsapp)](https://pub.dev/packages/social_sender_whatsapp/score)
[![Popularity](https://img.shields.io/pub/popularity/social_sender_whatsapp)](https://pub.dev/packages/social_sender_whatsapp/score)

A Flutter plugin for sending WhatsApp messages and sharing files directly to specific phone numbers or via a general share sheet on both Android and iOS.

<a href="https://www.buymeacoffee.com/chegz" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" alt="Buy Me A Coffee" style="height: 60px !important;width: 217px !important;" ></a>

## Features

*   **Send Text Messages**: Open WhatsApp with a pre-filled message for a specific contact.
*   **Share Files**: Share single or multiple files (PDFs, Images, etc.) to WhatsApp.
*   **Optional Phone Number**: If the phone number is not provided, it opens the WhatsApp contact picker (Android) or the system share sheet (iOS).
*   **WhatsApp Business Support**: Automatically detects and offers sharing via WhatsApp or WhatsApp Business on Android.
*   **Integrated Error Handling**: Throws structured exceptions for easier debugging.

## Getting Started

### Android Setup

To enable file sharing and ensure compatibility with Android 11+ (API 30+), add the following to your `AndroidManifest.xml` within the `<manifest>` tag (outside `<application>`):

```xml
<queries>
    <package android:name="com.whatsapp" />
    <package android:name="com.whatsapp.w4b" />
    <intent>
        <action android:name="android.intent.action.SEND" />
        <data android:mimeType="*/*" />
    </intent>
    <intent>
        <action android:name="android.intent.action.VIEW" />
        <data android:scheme="https" android:host="wa.me" />
    </intent>
</queries>
```

Add the `FileProvider` within the `<application>` tag:

```xml
<application>
    <provider
        android:name="androidx.core.content.FileProvider"
        android:authorities="${applicationId}.provider"
        android:exported="false"
        android:grantUriPermissions="true">
        <meta-data
            android:name="android.support.FILE_PROVIDER_PATHS"
            android:resource="@xml/provider_paths" />
    </provider>
</application>
```

Create `android/app/src/main/res/xml/provider_paths.xml`:

```xml
<?xml version="1.0" encoding="utf-8"?>
<paths xmlns:android="http://schemas.android.com/apk/res/android">
    <external-path name="external_files" path="." />
</paths>
```

### iOS Setup

Add the following to your `Info.plist` to allow the app to check if WhatsApp is installed:

```xml
<key>LSApplicationQueriesSchemes</key>
<array>
  <string>whatsapp</string>
</array>
```

## Usage

### Simple Text Message

```dart
import 'package:social_sender_whatsapp/social_sender_whatsapp.dart';

// Send a pre-filled message to a specific number
await SocialSenderWhatsapp.instance.send(
  phone: "1234567890",
  text: "Hello from Flutter!",
);
```

### Sharing Files

```dart
// Share multiple files with an optional message
await SocialSenderWhatsapp.instance.send(
  phone: "1234567890", // Optional: opens contact picker if omitted on Android
  text: "Check out these files",
  files: [
    "/path/to/file1.pdf",
    "/path/to/file2.png",
  ],
);
```

## Exceptions

The plugin throws `SocialSenderWhatsappException` which contains a `type` identifying the error:

*   `WHATSAPP_NOT_INSTALLED`: WhatsApp is not found on the device.
*   `FILE_NOT_FOUND`: One or more provided file paths are invalid or inaccessible (Android).
*   `UNKNOWN`: Any other platform-specific error.

## Support and Feedback

If you encounter any issues or have suggestions, feel free to open an issue on the [GitHub repository](https://github.com/ChegzDev/social_sender_whatsapp/issues).

## Contributors

<a href="https://github.com/ChegzDev/social_sender_whatsapp/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=ChegzDev/social_sender_whatsapp" alt="Contributors" />
</a>

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
