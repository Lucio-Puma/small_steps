import 'package:flutter/material.dart';

class NotificationService {
  // Singleton pattern
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  Future<void> init() async {
    // No-op for Web
    debugPrint("NotificationService: Init ignored on Web");
  }

  Future<void> requestPermissions() async {
    // No-op for Web
    debugPrint("NotificationService: Permissions ignored on Web");
  }

  Future<void> scheduleDailyNotification(
      int id, String title, TimeOfDay time) async {
    // No-op for Web
    debugPrint("NotificationService: Scheduling ignored on Web");
  }
}
