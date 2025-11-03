import 'package:flutter/material.dart';

class DetailsScreen extends StatelessWidget {
  final Map<String, String> details;
  const DetailsScreen({super.key, required this.details});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Details - ${details["sender"]}")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Sender: ${details["sender"]}", style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text("Message:", style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            Text(details["message"]!, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 15),
            Text("Detected on: ${details["date"]}"),
            const SizedBox(height: 10),
            Text("AI Confidence: ${details["confidence"]}", style: const TextStyle(color: Colors.redAccent)),

            const SizedBox(height: 30),
            const Text("Reasons Detected:", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text("• Fake domain detected\n• Urgent tone in message\n• Suspicious link format"),
            const Spacer(),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () {},
              icon: const Icon(Icons.block),
              label: const Text("Block Sender"),
            ),
          ],
        ),
      ),
    );
  }
}
