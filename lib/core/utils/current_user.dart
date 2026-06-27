import 'package:get/get.dart';
import 'package:healthify/controller/auth_controller.dart';
import 'package:healthify/core/services/secure_storage_service.dart';

/// Central helper to reliably get the current user's uid.
/// Tries AuthController first (fast, in-memory), falls back to SecureStorage (persistent).
class CurrentUser {
  static Future<String?> getUid() async {
    // 1. Try in-memory AuthController (instant)
    try {
      final authController = Get.find<AuthController>();
      final uid = authController.currentUser?.uid;
      if (uid != null && uid.isNotEmpty) return uid;
    } catch (_) {
      // AuthController not found — fall through
    }

    // 2. Fallback to SecureStorage (disk, always available)
    final storage = SecureStorageService();
    return await storage.getUid();
  }

  static Future<String?> getEmail() async {
    try {
      final authController = Get.find<AuthController>();
      final email = authController.currentUser?.email;
      if (email != null && email.isNotEmpty) return email;
    } catch (_) {}

    final storage = SecureStorageService();
    return await storage.getEmail();
  }

  static Future<String?> getName() async {
    try {
      final authController = Get.find<AuthController>();
      final name = authController.currentUser?.displayName;
      if (name != null && name.isNotEmpty) return name;
    } catch (_) {}

    final storage = SecureStorageService();
    return await storage.getName();
  }
}
