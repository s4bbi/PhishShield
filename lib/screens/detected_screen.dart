import 'package:flutter/material.dart';
import 'details_screen.dart';

class DetectedScreen extends StatelessWidget {
  const DetectedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> detectedMessages = [
      {
        "sender": "Bank Support",
        "message": "Your account is locked. Verify now: http://bank-login-secure.com",
        "date": "Today, 10:45 AM",
        "confidence": "97%"
      },
      {
        "sender": "Delivery Service",
        "message": "Click here to track your parcel: http://delivery-safe.net",
        "date": "Yesterday, 8:10 PM",
        "confidence": "88%"
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Detected Messages")),
      body: ListView.builder(
        itemCount: detectedMessages.length,
        itemBuilder: (context, index) {
          final msg = detectedMessages[index];
          return Card(
            color: Colors.grey[900],
            margin: const EdgeInsets.all(8),
            child: ListTile(
              leading: const Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
              title: Text(msg["sender"]!),
              subtitle: Text(msg["message"]!, maxLines: 2, overflow: TextOverflow.ellipsis),
              trailing: Text(msg["confidence"]!, style: const TextStyle(color: Colors.redAccent)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DetailsScreen(details: msg),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
