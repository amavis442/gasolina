// ABOUTME: Provider for the configurable wage day setting (1–28)
// ABOUTME: Persists to SharedPreferences; drives wage period grouping in the list screen

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/providers/shared_preferences_provider.dart';

final wageDayProvider = StateNotifierProvider<WageDayNotifier, int>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return WageDayNotifier(prefs);
});

class WageDayNotifier extends StateNotifier<int> {
  static const _key = 'wage_day';
  static const defaultDay = 25;

  final SharedPreferences _prefs;

  WageDayNotifier(this._prefs) : super(_prefs.getInt(_key) ?? defaultDay);

  Future<void> setWageDay(int day) async {
    await _prefs.setInt(_key, day);
    state = day;
  }
}
