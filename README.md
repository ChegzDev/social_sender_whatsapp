# Social Sender WhatsApp

[![Pub Version](https://img.shields.io/pub/v/social_sender_whatsapp?color=blue)](https://pub.dev/packages/social_sender_whatsapp)
[![License: MIT](https://img.shields.io/github/license/ChegzDev/social_sender_whatsapp)](https://opensource.org/licenses/MIT)
[![Pub Likes](https://img.shields.io/pub/likes/social_sender_whatsapp)](https://pub.dev/packages/social_sender_whatsapp/score)
[![Pub Points](https://img.shields.io/pub/points/social_sender_whatsapp)](https://pub.dev/packages/social_sender_whatsapp/score)
[![Popularity](https://img.shields.io/pub/popularity/social_sender_whatsapp)](https://pub.dev/packages/social_sender_whatsapp/score)

A Flutter plugin for sending WhatsApp messages and sharing files directly to specific phone numbers or via a general share sheet on both Android and iOS.

<a href="https://www.buymeacoffee.com/chegz" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" alt="Buy Me A Coffee" style="height: 60px !important;width: 217px !important;" ></a>


## Features

*   **Send Text Messages**: Open WhatsApp with a pre-filled message for a specific contact.
*   **Share Files**: Share files (PDFs, Images, Videos, etc.) to WhatsApp.
*   **Optional Phone Number**: If the phone number is not provided, it opens the WhatsApp contact picker (Android) or the system share sheet (iOS).
*   **WhatsApp Business Support**: Automatically detects and offers sharing via WhatsApp or WhatsApp Business on both platforms.
*   **Integrated Error Handling**: Throws structured exceptions for easier debugging.

## Platform Capabilities

Due to strict differences in operating system capabilities and WhatsApp's official platform integrations, some features behave differently on Android and iOS:

| Feature | Android | iOS |
| :--- | :---: | :---: |
| **Send Text Message** | ✅ Yes | ✅ Yes |
| **Direct to specific phone number** | ✅ Yes | ✅ Yes |
| **WhatsApp Business Support** | ✅ Yes | ✅ Yes |
| **Share Multiple Files** | ✅ Yes | ❌ No (Only first file is shared)* |
| **Share File with Text Caption** | ✅ Yes | ❌ No (WhatsApp iOS limitation) |
| **Target specific app for file sharing** | ✅ Yes (Intent filtering) | ⚠️ OS Share Sheet presented** |

> [!NOTE]
> * **iOS Multiple Files**: `UIDocumentInteractionController` is used to trigger file sharing natively on iOS, which strictly supports only a single file at a time.
>
> ** **iOS Share Sheet Limitation**: On modern iOS (16+), Apple's strict sandboxing design prevents apps from programmatically restricting the native share sheet to a specific third-party app. When sharing files, the OS evaluates the file content and presents a system share sheet containing all apps capable of handling that file type (e.g., sharing an image will show WhatsApp alongside other image-capable apps like Notes, Save to Files, Chrome, etc.). This is a core iOS OS-level behavior and cannot be bypassed.

## Getting Started

### Android Setup

The plugin automatically includes the necessary `<queries>` configuration in its own manifest. For most projects, **no manual setup is required**.

However, to ensure compatibility with all build environments and Android 11+ (API 30+), you can optionally add the following to your `android/app/src/main/AndroidManifest.xml` within the `<manifest>` tag (outside `<application>`) if you encounter visibility issues:

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

> [!IMPORTANT]
> **Do NOT add a FileProvider** manually to your `AndroidManifest.xml`. The plugin handles this internally to prevent manifest merger conflicts.

### iOS Setup

Add the following to your `ios/Runner/Info.plist` to allow the app to check if WhatsApp and WhatsApp Business are installed:

```xml
<key>LSApplicationQueriesSchemes</key>
<array>
  <string>whatsapp</string>
  <string>whatsapp-business</string>
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

*   `whatsappNotInstalled`: WhatsApp is not found on the device.
*   `fileNotFound`: One or more provided file paths are invalid or inaccessible.
*   `unknown`: Any other platform-specific error.

## Support and Feedback

If you encounter any issues or have suggestions, feel free to open an issue on the [GitHub repository](https://github.com/ChegzDev/social_sender_whatsapp/issues).

## Contributors

<a href="https://github.com/ChegzDev/social_sender_whatsapp/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=ChegzDev/social_sender_whatsapp" alt="Contributors" />
</a>

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

