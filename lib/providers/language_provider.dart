import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

enum AppLanguage { vi, en }

class LanguageProvider extends ChangeNotifier {
  static const _storageKey = 'app_language';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  AppLanguage _language = AppLanguage.vi;

  AppLanguage get language => _language;
  bool get isVietnamese => _language == AppLanguage.vi;
  String get code => _language.name.toUpperCase();

  Future<void> load() async {
    final value = await _storage.read(key: _storageKey);
    if (value == AppLanguage.en.name) {
      _language = AppLanguage.en;
    } else {
      _language = AppLanguage.vi;
    }
  }

  Future<void> setLanguage(AppLanguage language) async {
    if (_language == language) return;
    _language = language;
    await _storage.write(key: _storageKey, value: language.name);
    notifyListeners();
  }
}
