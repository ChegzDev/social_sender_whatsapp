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
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Social Sender WhatsApp Example'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => _send(phone: "+919995462015", text: "Hi, how are you?"),
                child: const Text('Send Text to Number'),
              ),
              ElevatedButton(
                onPressed: () => _send(text: "Hi, this is a general share"),
                child: const Text('Send Text (Optional Number)'),
              ),
              const Divider(),
              const Text("Note: Sharing files requires valid paths"),
              ElevatedButton(
                onPressed: () => _send(
                  phone: "+919995462015",
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
