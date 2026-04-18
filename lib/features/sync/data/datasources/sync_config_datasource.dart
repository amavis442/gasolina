// ABOUTME: Persists and retrieves sync configuration (API URL, JWT token, last_sync_at)
// ABOUTME: Uses shared_preferences for non-sensitive data and secure_storage for the JWT

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/sync_config.dart';

class SyncConfigDataSource {
  static const _keyApiBaseUrl = 'sync_api_base_url';
  static const _keyDeviceSecret = 'sync_device_secret';
  static const _keyJwtToken = 'sync_jwt_token';
  static const _keyLastSyncAt = 'sync_last_sync_at';

  final SharedPreferences prefs;
  final FlutterSecureStorage secureStorage;

  SyncConfigDataSource({
    required this.prefs,
    required this.secureStorage,
  });

  Future<SyncConfig> loadConfig() async {
    final apiBaseUrl = prefs.getString(_keyApiBaseUrl) ?? '';
    final deviceSecret =
        await secureStorage.read(key: _keyDeviceSecret) ?? '';
    return SyncConfig(apiBaseUrl: apiBaseUrl, deviceSecret: deviceSecret);
  }

  Future<void> saveConfig(SyncConfig config) async {
    await prefs.setString(_keyApiBaseUrl, config.apiBaseUrl);
    await secureStorage.write(
        key: _keyDeviceSecret, value: config.deviceSecret);
  }

  Future<String?> loadToken() async {
    return secureStorage.read(key: _keyJwtToken);
  }

  Future<void> saveToken(String token) async {
    await secureStorage.write(key: _keyJwtToken, value: token);
  }

  Future<int> loadLastSyncAt() async {
    return prefs.getInt(_keyLastSyncAt) ?? 0;
  }

  Future<void> saveLastSyncAt(int timestampMs) async {
    await prefs.setInt(_keyLastSyncAt, timestampMs);
  }
}
