import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kinder_world/core/providers/shared_preferences_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleController extends StateNotifier<Locale> {
  static const String _localeKey = 'app_locale';
  final SharedPreferences _prefs;

  LocaleController(this._prefs)
      : super(Locale(_prefs.getString(_localeKey) ?? 'en'));

  Future<bool> hasSavedLocale() async {
    final code = _prefs.getString(_localeKey);
    return code != null && code.isNotEmpty;
  }

  Future<void> loadSavedLocale() async {
    final code = _prefs.getString(_localeKey);
    if (code == null || code.isEmpty) return;
    state = Locale(code);
  }

  Future<void> setLocale(Locale locale) async {
    if (state.languageCode != locale.languageCode) {
      state = locale;
    }
    await _prefs.setString(_localeKey, locale.languageCode);
  }

  Future<void> setLanguageCode(String languageCode) async {
    await setLocale(Locale(languageCode));
  }
}

final localeProvider = StateNotifierProvider<LocaleController, Locale>((ref) {
  return LocaleController(ref.watch(sharedPreferencesProvider));
});
