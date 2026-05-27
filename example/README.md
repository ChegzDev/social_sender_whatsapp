# Social Sender WhatsApp Example

This example app demonstrates the core features of the `social_sender_whatsapp` plugin.

## Features Demonstrated

*   **Send Text to Number**: Send a pre-filled WhatsApp message to a specific phone number.
*   **Optional Phone Number**: Share text or files via WhatsApp without specifying a recipient upfront (opens WhatsApp contact picker or system share sheet).
*   **Single File Sharing**: Share a single file (PDF, Image, etc.) with an optional message.
*   **Multiple File Sharing**: Share multiple files simultaneously.

## Running the Example

1.  **Clone the repository**:
    ```bash
    git clone https://github.com/yourusername/social_sender_whatsapp.git
    cd social_sender_whatsapp/example
    ```

2.  **Install dependencies**:
    ```bash
    flutter pub get
    ```

3.  **Setup Platform Specifics**:
    *   **Android**: Ensure the `FileProvider` is configured in `AndroidManifest.xml` (see main README).
    *   **iOS**: Ensure `LSApplicationQueriesSchemes` includes `whatsapp` in `Info.plist`.

4.  **Run the app**:
    ```bash
    flutter run
    ```

## Testing

### Integration Tests
To run integration tests on a real device:
```bash
flutter test integration_test/plugin_integration_test.dart
```

### Widget Tests
To run UI verification tests:
```bash
flutter test
```
