// lib/services/key_service.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';

class KeyService {
  static final KeyService _instance = KeyService._internal();
  factory KeyService() => _instance;
  KeyService._internal();

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // ✅ تخزين API Key
  Future<void> saveOpenAIKey(String key) async {
    try {
      await _storage.write(key: 'openai_api_key', value: key);
      debugPrint('✅ OpenAI API Key saved securely');
    } catch (e) {
      debugPrint('❌ Failed to save API Key: $e');
    }
  }

  // ✅ استرجاع API Key
  Future<String?> getOpenAIKey() async {
    try {
      final key = await _storage.read(key: 'openai_api_key');
      debugPrint('🔑 OpenAI API Key retrieved: ${key != null ? 'Yes' : 'No'}');
      return key;
    } catch (e) {
      debugPrint('❌ Failed to retrieve API Key: $e');
      return null;
    }
  }

  // ✅ حذف API Key
  Future<void> deleteOpenAIKey() async {
    try {
      await _storage.delete(key: 'openai_api_key');
      debugPrint('🗑️ OpenAI API Key deleted');
    } catch (e) {
      debugPrint('❌ Failed to delete API Key: $e');
    }
  }

  // ✅ التحقق من وجود API Key
  Future<bool> hasOpenAIKey() async {
    final key = await getOpenAIKey();
    return key != null && key.isNotEmpty;
  }

  // ✅ تخزين أي مفتاح عام
  Future<void> saveKey(String keyName, String value) async {
    try {
      await _storage.write(key: keyName, value: value);
      debugPrint('✅ $keyName saved securely');
    } catch (e) {
      debugPrint('❌ Failed to save $keyName: $e');
    }
  }

  // ✅ استرجاع أي مفتاح
  Future<String?> getKey(String keyName) async {
    try {
      return await _storage.read(key: keyName);
    } catch (e) {
      debugPrint('❌ Failed to retrieve $keyName: $e');
      return null;
    }
  }

  // ✅ حذف أي مفتاح
  Future<void> deleteKey(String keyName) async {
    try {
      await _storage.delete(key: keyName);
      debugPrint('🗑️ $keyName deleted');
    } catch (e) {
      debugPrint('❌ Failed to delete $keyName: $e');
    }
  }

  // ✅ مسح جميع المفاتيح
  Future<void> clearAllKeys() async {
    try {
      await _storage.deleteAll();
      debugPrint('🗑️ All keys cleared');
    } catch (e) {
      debugPrint('❌ Failed to clear keys: $e');
    }
  }
}