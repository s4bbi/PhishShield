import 'package:flutter/services.dart';

class SmsUtils {
  static const platform = MethodChannel('sms_default');

  static Future<void> requestDefaultSmsApp() async {
    try {
      await platform.invokeMethod('requestDefaultSmsApp');
    } on PlatformException catch (e) {
      print("Failed to request default SMS app: '${e.message}'.");
    }
  }
}
