## 2.0.0

* **Breaking Change**: Major internal refactor and stabilization.
* **iOS Refactor**: Complete rewrite of the iOS plugin in Swift for better reliability and modern API usage.
* **WhatsApp Business (iOS)**: Added support for WhatsApp Business on iOS, including automatic detection and fallbacks.
* **Improved File Sharing (iOS)**: Implemented WhatsApp-specific UTIs (`net.whatsapp.image`, etc.) to filter the system share sheet, ensuring a more direct sharing experience.
* **Smart Chooser (Android)**: Implemented an intelligent app chooser that appears only if both WhatsApp and WhatsApp Business are installed.
* **Permission Management (Android)**: Enhanced URI permission handling using `ClipData` for more robust file sharing across different Android versions.
* **Cleanup**: Added automatic temporary file cleanup on iOS.
* **Build Compatibility**: 
    * Replaced `compilerOptions` with `kotlinOptions` in `build.gradle.kts`.
    * Improved compatibility with older Flutter and AGP versions via conditional Kotlin plugin application.
* **JVM Target**: Explicitly set to `17` to align with modern Flutter requirements.
* **Android SDK**: Updated `compileSdk` to `35` for broader compatibility.
* **File Sharing Fix**: Added `<root-path>` to `provider_paths.xml` to resolve "Failed to find configured root" errors.
* **Documentation**: Updated `README.md` with critical configuration details.

## 1.0.3

* **Build Compatibility**: Improved compatibility with older Flutter versions (e.g., 3.41.x) and Android Gradle Plugin (AGP) versions.
    * Implemented conditional Kotlin plugin application to support both AGP 9.0+ built-in Kotlin and legacy plugin application.
    * Migrated to task-based JVM target configuration to avoid "unresolved reference" errors in various build environments.
    * Updated source set configuration to use non-deprecated syntax.

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
