import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:social_sender_whatsapp/social_sender_whatsapp.dart';
import 'package:image_picker/image_picker.dart';

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
  final TextEditingController _messageController = TextEditingController();
  List<String> _selectedFilePaths = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _phoneController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage();
      if (images.isNotEmpty) {
        setState(() {
          _selectedFilePaths = images.map((image) => image.path).toList();
        });
      }
    } catch (e) {
      debugPrint("Error picking images: $e");
    }
  }

  Future<void> _send() async {
    final phone = _phoneController.text.trim();
    final text = _messageController.text.trim();

    try {
      final result = await SocialSenderWhatsapp.instance.send(
        phone: phone.isEmpty ? null : phone,
        text: text.isEmpty ? null : text,
        files: _selectedFilePaths.isEmpty ? null : _selectedFilePaths,
      );
      debugPrint("Send result: $result");
    } on SocialSenderWhatsappException catch (e) {
      if (mounted) {
        log("Error: ${e.type} - ${e.message}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${e.type} - ${e.message}")),
        );
      }
    } catch (e) {
      debugPrint("Unknown error: $e");
    }
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "WhatsApp Message Form",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: "Phone Number (Optional)",
                  hintText: "+1234567890",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _messageController,
                decoration: const InputDecoration(
                  labelText: "Message Text (Optional)",
                  hintText: "Hi, how are you?",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.message),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      ElevatedButton.icon(
                        onPressed: _pickImages,
                        icon: const Icon(Icons.photo_library),
                        label: const Text("Select Images (Optional)"),
                      ),
                      if (_selectedFilePaths.isNotEmpty) ...[
                        const Divider(),
                        Text(
                          "${_selectedFilePaths.length} image(s) selected:",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        ..._selectedFilePaths.map((path) => Text(
                              path.split('/').last,
                              style: const TextStyle(fontSize: 12),
                            )),
                        TextButton(
                          onPressed: () => setState(() => _selectedFilePaths = []),
                          child: const Text("Clear Selection",
                              style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _send,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  'Send via WhatsApp',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Note: If phone number is omitted, it will open the contact picker (Android) or share sheet (iOS).",
                style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
