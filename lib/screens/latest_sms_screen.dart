import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:permission_handler/permission_handler.dart';
import 'details_screen.dart';
import '../services/sms_utils.dart';

class LatestSmsScreen extends StatefulWidget {
  const LatestSmsScreen({super.key});

  @override
  State<LatestSmsScreen> createState() => _LatestSmsScreenState();
}

class _LatestSmsScreenState extends State<LatestSmsScreen> {
  final SmsQuery _smsQuery = SmsQuery();
  List<SmsMessage> _messages = [];
  bool _firstLoad = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _requestDefaultSmsApp();
    _loadInitialMessages();
    _startBackgroundFetch();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _requestDefaultSmsApp() async {
    await SmsUtils.requestDefaultSmsApp();
  }

/// Fetch latest 5 messages initially
Future<void> _loadInitialMessages() async {
  var status = await Permission.sms.status;
  if (!status.isGranted) {
    status = await Permission.sms.request();
  }
  if (!status.isGranted) return;

  List<SmsMessage> messages = await _smsQuery.getAllSms;
  // Sort latest first
  messages.sort((a, b) => a.date!.compareTo(b.date!));

  setState(() {
    _messages = messages.take(5).toList();
    _firstLoad = false;
  });
}


  /// Background fetch every 5 seconds (no loading spinner)
  void _startBackgroundFetch() {
    _timer = Timer.periodic(const Duration(seconds: 5), (_) async {
      var status = await Permission.sms.status;
      if (!status.isGranted) return;

      List<SmsMessage> messages = await _smsQuery.getAllSms;
      messages.sort((a, b) => b.date!.compareTo(a.date!));

      // Add new messages at the top if they are not already in the list
      setState(() {
        for (var msg in messages) {
          if (!_messages.any((m) => m.id == msg.id)) {
            _messages.insert(0, msg);
          }
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Latest Messages"),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadInitialMessages,
            tooltip: "Refresh",
          ),
        ],
      ),
      body: _messages.isEmpty
          ? const Center(
              child: Text(
                "No messages found",
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            )
          : ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final dateDisplay =
                    msg.date?.toLocal().toString().split(".")[0] ??
                    "Unknown time";

                // Only mark the first 5 messages loaded initially as "Latest"
                final isLatestBadge = index < 5;

                return Card(
                  color: Colors.grey[850],
                  margin: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: const Icon(
                      Icons.message_rounded,
                      color: Colors.redAccent,
                      size: 30,
                    ),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            msg.address ?? "Unknown Sender",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        if (isLatestBadge)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.redAccent,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              "Latest",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                            ),
                          ),
                      ],
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            msg.body ?? "No message content",
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.white70),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            dateDisplay,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DetailsScreen(
                            details: {
                              "sender": msg.address ?? "Unknown",
                              "message": msg.body ?? "",
                              "date": dateDisplay,
                              "confidence": "—",
                            },
                          ),
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
