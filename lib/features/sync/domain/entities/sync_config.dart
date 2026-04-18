// ABOUTME: Value object holding the sync configuration provided by the user
// ABOUTME: Carries API base URL and device secret; both are required to sync

import 'package:equatable/equatable.dart';

class SyncConfig extends Equatable {
  final String apiBaseUrl;
  final String deviceSecret;

  const SyncConfig({
    required this.apiBaseUrl,
    required this.deviceSecret,
  });

  bool get isConfigured => apiBaseUrl.isNotEmpty && deviceSecret.isNotEmpty;

  @override
  List<Object?> get props => [apiBaseUrl, deviceSecret];
}
