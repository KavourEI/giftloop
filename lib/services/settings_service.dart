import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/strings.dart';

/// App-wide preferences: language and the user's own gift categories.
class SettingsService extends ChangeNotifier {
  SettingsService._();
  static final instance = SettingsService._();

  static const _langKey = 'app_language';
  static const _categoriesKey = 'custom_categories';

  String _language = 'en';
  List<String> _customCategories = [];

  String get language => _language;
  List<String> get customCategories => List.unmodifiable(_customCategories);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_langKey);
    if (saved != null && S.supportedLanguages.contains(saved)) {
      _language = saved;
    } else {
      // First launch: follow the phone's language when we support it.
      final device = ui.PlatformDispatcher.instance.locale.languageCode;
      _language = S.supportedLanguages.contains(device) ? device : 'en';
    }
    S.current = S.forLanguage(_language);
    _customCategories = prefs.getStringList(_categoriesKey) ?? [];
  }

  Future<void> setLanguage(String code) async {
    if (code == _language) return;
    _language = code;
    S.current = S.forLanguage(code);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_langKey, code);
  }

  /// Adds a category; returns false if one with the same name exists.
  Future<bool> addCategory(String label, List<String> builtIn) async {
    final norm = label.trim().toLowerCase();
    final exists = [...builtIn, ..._customCategories]
        .any((c) => c.toLowerCase() == norm);
    if (exists || norm.isEmpty) return false;
    _customCategories.add(label.trim());
    notifyListeners();
    await _saveCategories();
    return true;
  }

  Future<void> removeCategory(String label) async {
    _customCategories.remove(label);
    notifyListeners();
    await _saveCategories();
  }

  Future<void> _saveCategories() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_categoriesKey, _customCategories);
  }
}
