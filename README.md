# Social Sender WhatsApp

A Flutter plugin for sending WhatsApp messages and sharing files directly to specific phone numbers or via a general share sheet on both Android and iOS.

## Features

*   **Send Text Messages**: Open WhatsApp with a pre-filled message for a specific contact.
*   **Share Files**: Share single or multiple files (PDFs, Images, etc.) to WhatsApp.
*   **Optional Phone Number**: If the phone number is not provided, it opens the WhatsApp contact picker (Android) or the system share sheet (iOS).
*   **WhatsApp Business Support**: Automatically detects and offers sharing via WhatsApp or WhatsApp Business on Android.

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

### iOS Setup

Add the following to your `Info.plist` to allow the app to check if WhatsApp is installed:

```xml
<key>LSApplicationQueriesSchemes</key>
<array>
  <string>whatsapp</string>
</array>
```

## Usage

### Send a Text Message

```dart
import 'package:social_sender_whatsapp/social_sender_whatsapp.dart';

await SocialSenderWhatsapp.instance.send(
  phone: "1234567890",
  text: "Hello from Flutter!",
);
```

### Share Files

```dart
await SocialSenderWhatsapp.instance.send(
  phone: "1234567890", // Optional
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
*   `PHONE_REQUIRED`: Thrown if logic specifically requires a phone number but none was provided (rare).
*   `UNKNOWN`: Any other platform-specific error.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
