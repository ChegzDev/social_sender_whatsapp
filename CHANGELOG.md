## 1.0.1

* **Privacy Fix**: Removed hardcoded personal phone number from example and git history.
* **Major Example Update**: Replaced the static example app with a dynamic form.
    * Added ability to input custom phone numbers and messages.
    * Integrated `file_picker` to demonstrate real-world file sharing capabilities.
* Improved example app usability for testing and documentation.

## 1.0.0

* Initial release of the `social_sender_whatsapp` plugin.
* Support for sending text messages to specific phone numbers on WhatsApp.
* Support for sharing single or multiple files (PDFs, images, etc.).
* Automatic detection and support for WhatsApp Business on Android.
* Optional phone number handling: opens contact picker (Android) or system share sheet (iOS) if omitted.
* Integrated error handling with `SocialSenderWhatsappException`.
