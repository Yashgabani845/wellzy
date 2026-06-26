import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const String _keyUid = 'auth_uid';
  static const String _keyLoggedIn = 'auth_logged_in';

  Future<void> saveUserSession({required String uid}) async {
    await _storage.write(key: _keyUid, value: uid);
    await _storage.write(key: _keyLoggedIn, value: 'true');
  }

  Future<String?> getUid() async {
    return await _storage.read(key: _keyUid);
  }

  Future<bool> isLoggedIn() async {
    final value = await _storage.read(key: _keyLoggedIn);
    return value == 'true';
  }

  Future<void> clearSession() async {
    await _storage.delete(key: _keyUid);
    await _storage.delete(key: _keyLoggedIn);
  }
}
