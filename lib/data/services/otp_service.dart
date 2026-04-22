import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class OtpService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  static String _pinKey(String userId) => 'nova_otp_pin_$userId';

  static String _setupKey(String userId) => 'nova_otp_setup_$userId';

  static String _hashPin(String pin, String userId) {
    final input = '$userId:$pin:nova_banking_salt';
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  static Future<bool> isSetup(String userId) async {
    final val = await _storage.read(key: _setupKey(userId));
    return val == 'true';
  }

  static Future<bool> setupPin(String userId, String pin) async {
    if (!_isValidPin(pin)) return false;
    final hash = _hashPin(pin, userId);
    await _storage.write(key: _pinKey(userId), value: hash);
    await _storage.write(key: _setupKey(userId), value: 'true');
    return true;
  }

  static Future<bool> verifyPin(String userId, String pin) async {
    if (!_isValidPin(pin)) return false;
    final stored = await _storage.read(key: _pinKey(userId));
    if (stored == null) return false;
    final hash = _hashPin(pin, userId);
    return stored == hash;
  }

  static Future<void> clearPin(String userId) async {
    await _storage.delete(key: _pinKey(userId));
    await _storage.delete(key: _setupKey(userId));
  }
  static bool _isValidPin(String pin) {
    return RegExp(r'^\d{6}$').hasMatch(pin);
  }
}
