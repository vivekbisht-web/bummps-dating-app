import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService()
      : _storage = const FlutterSecureStorage(
          aOptions: AndroidOptions(encryptedSharedPreferences: true),
          iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
        );

  static const String _keyToken = 'auth_token';
  static const String _keyRefreshToken = 'refresh_token';
  static const String _keyUserId = 'user_id';

  // Generic write
  Future<void> write(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  // Generic read
  Future<String?> read(String key) async {
    return await _storage.read(key: key);
  }

  // Generic delete
  Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  // Clear all storage
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  // Convenient helpers for tokens
  Future<void> saveToken(String token) async {
    await write(_keyToken, token);
  }

  Future<String?> getToken() async {
    return await read(_keyToken);
  }

  Future<void> saveRefreshToken(String token) async {
    await write(_keyRefreshToken, token);
  }

  Future<String?> getRefreshToken() async {
    return await read(_keyRefreshToken);
  }

  Future<void> saveUserId(String userId) async {
    await write(_keyUserId, userId);
  }

  Future<String?> getUserId() async {
    return await read(_keyUserId);
  }

  Future<void> deleteTokens() async {
    await delete(_keyToken);
    await delete(_keyRefreshToken);
    await delete(_keyUserId);
  }
}
