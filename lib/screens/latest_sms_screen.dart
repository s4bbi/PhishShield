import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:http/http.dart' as http;
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
  SmsMessage? _latestMessage;
  bool _loading = true;
  Timer? _timer;

  // Store spam probabilities keyed by SMS id
  Map<int, double> _spamProbabilities = {};

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

  Future<void> _loadInitialMessages() async {
    var status = await Permission.sms.status;
    if (!status.isGranted) await Permission.sms.request();
    if (!status.isGranted) return;

    List<SmsMessage> messages = await _smsQuery.getAllSms;
    messages.sort((a, b) => b.date!.compareTo(a.date!)); // latest first

    if (messages.isNotEmpty) {
      setState(() {
        _messages = messages;
        _latestMessage = messages.first;
      });
      _checkForSpam(messages.first);
    }

    setState(() => _loading = false);
  }

  void _startBackgroundFetch() {
    _timer = Timer.periodic(const Duration(seconds: 5), (_) async {
      var status = await Permission.sms.status;
      if (!status.isGranted) return;

      List<SmsMessage> messages = await _smsQuery.getAllSms;
      messages.sort((a, b) => b.date!.compareTo(a.date!));

      if (messages.isNotEmpty && 
          (_latestMessage == null || messages.first.id != _latestMessage!.id)) {
        setState(() {
          _messages.insert(0, messages.first);
          _latestMessage = messages.first;
        });
        _checkForSpam(messages.first);
      }
    });
  }

  /// Mock function to send SMS to server and receive spam probability
  Future<void> _checkForSpam(SmsMessage msg) async {
    try {
      // Mock API call (replace with your actual endpoint later)
      await Future.delayed(const Duration(seconds: 1));

      // Simulated response (e.g., 0.0 = safe, 1.0 = spam)
      final double probability = msg.body!.toLowerCase().contains("win")
          ? 0.92
          : msg.body!.toLowerCase().contains("offer")
              ? 0.78
              : 0.1;

      setState(() {
        _spamProbabilities[msg.id ?? DateTime.now().millisecondsSinceEpoch] =
            probability;
      });
    } catch (e) {
      debugPrint("Error sending SMS to server: $e");
    }
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
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final id = msg.id ?? index;
                final prob = _spamProbabilities[id];
                final dateDisplay = msg.date
                        ?.toLocal()
                        .toString()
                        .split(".")
                        .first ??
                    "Unknown time";

                final bool isSpam = (prob ?? 0) > 0.5;

                return Card(
                  color: isSpam ? Colors.red[900] : Colors.grey[850],
                  margin:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: Icon(
                      Icons.message_rounded,
                      color: isSpam ? Colors.yellowAccent : Colors.redAccent,
                      size: 30,
                    ),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            msg.address ?? "Unknown Sender",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ),
                        if (isSpam)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(6)),
                            child: Text(
                              "Spam ${(prob! * 100).toStringAsFixed(1)}%",
                              style: const TextStyle(
                                  color: Colors.redAccent, fontSize: 10),
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
                          builder: (_) => DetailsScreen(details: {
                            "sender": msg.address ?? "Unknown",
                            "message": msg.body ?? "",
                            "date": dateDisplay,
                            "confidence": isSpam
                                ? "${(prob! * 100).toStringAsFixed(1)}%"
                                : "Safe",
                          }),
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
