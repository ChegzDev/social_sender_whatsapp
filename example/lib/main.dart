import 'package:flutter/material.dart';
import 'package:social_sender_whatsapp/social_sender_whatsapp.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final TextEditingController _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Social Sender WhatsApp Example'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: "Phone Number (with country code)",
                  hintText: "+1234567890",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () =>
                    _send(phone: _phoneController.text, text: "Hi, how are you?"),
                child: const Text('Send Text to Number'),
              ),
              ElevatedButton(
                onPressed: () => _send(text: "Hi, this is a general share"),
                child: const Text('Send Text (Optional Number)'),
              ),
              const Divider(height: 40),
              const Text("Note: Sharing files requires valid paths"),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => _send(
                  phone: _phoneController.text,
                  text: "Check out this file",
                  files: ["/storage/emulated/0/Download/test.pdf"], // Example path
                ),
                child: const Text('Send Single File'),
              ),
              ElevatedButton(
                onPressed: () => _send(
                  text: "Check out these files",
                  files: [
                    "/storage/emulated/0/Download/test1.pdf",
                    "/storage/emulated/0/Download/test2.png"
                  ], // Example paths
                ),
                child: const Text('Send Multiple Files'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _send({String? phone, String? text, List<String>? files}) async {
    try {
      final result = await SocialSenderWhatsapp.instance.send(
        phone: phone,
        text: text,
        files: files,
      );
      debugPrint("Send result: $result");
    } on SocialSenderWhatsappException catch (e) {
      debugPrint("Error: ${e.type} - ${e.message}");
    } catch (e) {
      debugPrint("Unknown error: $e");
    }
  }
}
