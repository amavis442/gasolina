// ABOUTME: App-level Riverpod provider for SharedPreferences instance
// ABOUTME: Overridden in main() after async initialisation; used by any feature that needs prefs

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden in main');
});
