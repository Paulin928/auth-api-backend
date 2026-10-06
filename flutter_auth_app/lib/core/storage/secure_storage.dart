import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  SecureStorage._();
  static final SecureStorage instance = SecureStorage._();

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static const _kAccessToken = 'access_token';
  static const _kUserId = 'user_id';
  static const _kUserEmail = 'user_email';
  static const _kUsername = 'user_username';
  static const _kUserRole = 'user_role';

  Future<void> saveSession({
    required String accessToken,
    required String userId,
    required String email,
    required String username,
    required String role,
  }) async {
    await _storage.write(key: _kAccessToken, value: accessToken);
    await _storage.write(key: _kUserId, value: userId);
    await _storage.write(key: _kUserEmail, value: email);
    await _storage.write(key: _kUsername, value: username);
    await _storage.write(key: _kUserRole, value: role);
  }

  Future<String?> get accessToken => _storage.read(key: _kAccessToken);
  Future<String?> get userId => _storage.read(key: _kUserId);
  Future<String?> get email => _storage.read(key: _kUserEmail);
  Future<String?> get username => _storage.read(key: _kUsername);
  Future<String?> get role => _storage.read(key: _kUserRole);

  Future<bool> get hasSession async => (await accessToken) != null;

  Future<void> clear() async => _storage.deleteAll();
}
