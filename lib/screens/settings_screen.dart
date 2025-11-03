import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    bool notificationsEnabled = true;

    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text("Enable Real-Time Protection"),
            subtitle: const Text("Automatically detect phishing messages"),
            value: notificationsEnabled,
            onChanged: (value) {},
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text("About App"),
            subtitle: const Text("Version 1.0.0 - Hackathon Edition"),
          ),
          ListTile(
            leading: const Icon(Icons.feedback),
            title: const Text("Send Feedback"),
            subtitle: const Text("Let us know if something goes wrong"),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
