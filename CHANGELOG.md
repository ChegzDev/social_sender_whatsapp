## 1.0.2

* **Android Optimization**: Improved intent handling to launch WhatsApp directly if only one version is installed.
* **Bug Fix**: Resolved "Can't send empty message" error when sharing files without additional text.
* **Stability**: Enhanced image and file sharing reliability with explicit URI permission management.

## 1.0.1

* **Privacy Fix**: Removed hardcoded personal phone number from example and git history.
* **Major Example Update**: Replaced the static example app with a dynamic form.
    * Added ability to input custom phone numbers and messages.
    * Integrated `image_picker` to demonstrate real-world file sharing capabilities.
* **Android Improvements**: 
    * Enhanced image and file sharing reliability with automatic MIME type detection.
    * Fixed "Permission Denial" errors by explicitly granting URI read permissions.
    * Resolved "Can't send empty message" error when sharing files without text.
    * Optimized app launch to open WhatsApp directly if only one version is installed.

## 1.0.0

* Initial release of the `social_sender_whatsapp` plugin.
* Support for sending text messages to specific phone numbers on WhatsApp.
* Support for sharing single or multiple files (PDFs, images, etc.).
* Automatic detection and support for WhatsApp Business on Android.
* Optional phone number handling: opens contact picker (Android) or system share sheet (iOS) if omitted.
* Integrated error handling with `SocialSenderWhatsappException`.
