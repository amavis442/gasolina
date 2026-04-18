// ABOUTME: HTTP datasource that communicates with the gasolina-api for sync
// ABOUTME: Handles JWT acquisition, rolling token refresh, and the sync endpoint

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/errors/exceptions.dart';
import '../../../../features/fuel_entries/data/models/fuel_entry_model.dart';
import '../models/sync_entry_dto.dart';
import 'sync_config_datasource.dart';

class SyncRemoteDataSource {
  final http.Client httpClient;
  final SyncConfigDataSource configDataSource;

  SyncRemoteDataSource({
    required this.httpClient,
    required this.configDataSource,
  });

  Future<String> _getToken(String apiBaseUrl, String deviceSecret) async {
    final cached = await configDataSource.loadToken();
    if (cached != null && cached.isNotEmpty) return cached;
    return _fetchNewToken(apiBaseUrl, deviceSecret);
  }

  Future<String> _fetchNewToken(
      String apiBaseUrl, String deviceSecret) async {
    final response = await httpClient.post(
      Uri.parse('$apiBaseUrl/auth/token'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'device_secret': deviceSecret}),
    );

    if (response.statusCode == 401) {
      throw AuthException('Invalid device secret');
    }
    if (response.statusCode != 200) {
      throw NetworkException(
        'Failed to get token: ${response.body}',
        statusCode: response.statusCode,
      );
    }

    final token = (jsonDecode(response.body) as Map<String, dynamic>)['token']
        as String;
    await configDataSource.saveToken(token);
    return token;
  }

  /// Sends local [entries] to the server and returns entries the server changed
  /// since [lastSyncAt]. Persists the rolling token from the response headers.
  Future<List<SyncEntryDto>> sync({
    required String apiBaseUrl,
    required String deviceSecret,
    required int lastSyncAt,
    required List<FuelEntryModel> entries,
  }) async {
    final token = await _getToken(apiBaseUrl, deviceSecret);

    final body = jsonEncode({
      'last_sync_at': lastSyncAt,
      'entries': entries.map((e) => SyncEntryDto.fromModel(e).toJson()).toList(),
    });

    final response = await httpClient.post(
      Uri.parse('$apiBaseUrl/v1/entries/sync'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: body,
    );

    // Persist rolling token when present
    final refreshed = response.headers['x-refresh-token'];
    if (refreshed != null && refreshed.isNotEmpty) {
      await configDataSource.saveToken(refreshed);
    }

    if (response.statusCode == 401) {
      // Token expired — clear it and retry once with a fresh token
      await configDataSource.saveToken('');
      return sync(
        apiBaseUrl: apiBaseUrl,
        deviceSecret: deviceSecret,
        lastSyncAt: lastSyncAt,
        entries: entries,
      );
    }

    if (response.statusCode != 200) {
      throw NetworkException(
        'Sync failed: ${response.body}',
        statusCode: response.statusCode,
      );
    }

    final List<dynamic> json = jsonDecode(response.body) as List<dynamic>;
    return json
        .map((e) => SyncEntryDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
