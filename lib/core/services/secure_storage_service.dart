import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const String _keyUid = 'auth_uid';
  static const String _keyLoggedIn = 'auth_logged_in';
  static const String _keyEmail = 'auth_email';
  static const String _keyName = 'auth_name';
  static const String _keyOnboardingCompleted = 'auth_onboarding_completed';
  static const String _keyFirstLaunch = 'first_launch';

  Future<void> saveUserSession({required String uid, String? email, String? name, bool? onboardingCompleted}) async {
    await _storage.write(key: _keyUid, value: uid);
    await _storage.write(key: _keyLoggedIn, value: 'true');
    if (email != null) await _storage.write(key: _keyEmail, value: email);
    if (name != null) await _storage.write(key: _keyName, value: name);
    if (onboardingCompleted != null) {
      await _storage.write(key: _keyOnboardingCompleted, value: onboardingCompleted ? 'true' : 'false');
    }
  }

  Future<void> setOnboardingCompleted(bool completed) async {
    await _storage.write(key: _keyOnboardingCompleted, value: completed ? 'true' : 'false');
  }

  Future<bool?> isOnboardingCompleted() async {
    final value = await _storage.read(key: _keyOnboardingCompleted);
    if (value == null) return null;
    return value == 'true';
  }

  Future<String?> getUid() async {
    return await _storage.read(key: _keyUid);
  }

  Future<String?> getEmail() async {
    return await _storage.read(key: _keyEmail);
  }

  Future<String?> getName() async {
    return await _storage.read(key: _keyName);
  }

  Future<void> saveName(String name) async {
    await _storage.write(key: _keyName, value: name);
  }

  Future<bool> isLoggedIn() async {
    final value = await _storage.read(key: _keyLoggedIn);
    return value == 'true';
  }

  Future<bool> isFirstLaunch() async {
    final value = await _storage.read(key: _keyFirstLaunch);
    return value == null || value == 'true';
  }

  Future<void> setFirstLaunchCompleted() async {
    await _storage.write(key: _keyFirstLaunch, value: 'false');
  }

  Future<void> clearSession() async {
    await _storage.delete(key: _keyUid);
    await _storage.delete(key: _keyLoggedIn);
    await _storage.delete(key: _keyEmail);
    await _storage.delete(key: _keyName);
    await _storage.delete(key: _keyOnboardingCompleted);
  }
}
