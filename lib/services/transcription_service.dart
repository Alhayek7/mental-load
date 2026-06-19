// ============================================================
// 📄 lib/services/transcription_service.dart
// 📌 خدمة تحويل الصوت إلى نص - Transcription Service
// ✅ النسخة المحسّنة - جميع المشاكل محلولة
// ============================================================

import 'dart:io';
import 'dart:async';
// ✅ إزالة 'dart:convert' لأنه غير مستخدم
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

// ============================================================
// 🎯 TranscriptionService - تحويل الصوت إلى نص
// ============================================================
class TranscriptionService {
  // ============================================================
  // 1. Singleton Pattern
  // ============================================================
  static final TranscriptionService _instance = TranscriptionService._internal();
  factory TranscriptionService() => _instance;
  TranscriptionService._internal();

  // ============================================================
  // 2. الثوابت
  // ============================================================
  static const String _whisperEndpoint = 'https://api.openai.com/v1/audio/transcriptions';
  static const String _pendingKey = 'pending_transcriptions';
  
  // ============================================================
  // 3. Getters
  // ============================================================
  Future<bool> get isConnected async {
    try {
      // ✅ استخدام الطريقة الصحيحة للتحقق من الاتصال
      final result = await Connectivity().checkConnectivity();
      // ✅ نتيجة checkConnectivity هي List<ConnectivityResult>
      return result.any((element) => element != ConnectivityResult.none);
    } catch (e) {
      debugPrint('❌ Connectivity check error: $e');
      return false;
    }
  }

  // ============================================================
  // 4. تحويل الصوت إلى نص (مع Whisper API)
  // ============================================================
  Future<String?> transcribeAudio({
    required String audioPath,
    required String apiKey,
    String language = 'ar',
    VoidCallback? onProgress,
  }) async {
    // ✅ التحقق من وجود الملف
    final file = File(audioPath);
    if (!await file.exists()) {
      debugPrint('❌ Audio file does not exist: $audioPath');
      return null;
    }

    // ✅ التحقق من الاتصال بالإنترنت
    final online = await isConnected;
    if (!online) {
      debugPrint('📡 No internet - Saving audio for later');
      await _saveForLater(audioPath);
      return null;
    }

    // ✅ التحقق من صحة API Key
    if (apiKey.isEmpty || apiKey == 'YOUR_OPENAI_API_KEY') {
      debugPrint('⚠️ Invalid API Key - Using local fallback');
      return _localTranscription(audioPath);
    }

    try {
      debugPrint('🎤 Transcribing audio: $audioPath');
      if (onProgress != null) onProgress();

      // ✅ إرسال الملف إلى Whisper API
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(_whisperEndpoint),
      )
        ..headers['Authorization'] = 'Bearer $apiKey'
        ..files.add(await http.MultipartFile.fromPath('file', audioPath))
        ..fields['model'] = 'whisper-1'
        ..fields['language'] = language
        ..fields['response_format'] = 'text'
        ..fields['temperature'] = '0.0';

      final response = await request.send().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          debugPrint('⏱️ Whisper API timeout');
          throw TimeoutException('Request timeout');
        },
      );

      // ✅ معالجة الاستجابة
      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final text = responseData.trim();
        
        if (text.isNotEmpty) {
          debugPrint('✅ Transcription successful: ${text.length} characters');
          return text;
        } else {
          debugPrint('⚠️ Empty transcription result');
          return null;
        }
      } else {
        // ✅ معالجة أخطاء API
        final errorBody = await response.stream.bytesToString();
        debugPrint('❌ Whisper API error (${response.statusCode}): $errorBody');
        
        if (response.statusCode == 401) {
          debugPrint('⚠️ Invalid API Key');
        } else if (response.statusCode == 429) {
          debugPrint('⚠️ Rate limit exceeded');
        } else if (response.statusCode == 413) {
          debugPrint('⚠️ File too large (max 25MB)');
        }
        
        await _saveForLater(audioPath);
        return null;
      }

    } on http.ClientException catch (e) {
      debugPrint('❌ Network error: $e');
      await _saveForLater(audioPath);
      return null;
    } on TimeoutException catch (e) {
      debugPrint('❌ Timeout: $e');
      await _saveForLater(audioPath);
      return null;
    } catch (e) {
      debugPrint('❌ Transcription error: $e');
      await _saveForLater(audioPath);
      return null;
    }
  }

  // ============================================================
  // 5. التحويل المحلي (بدون API)
  // ============================================================
  String _localTranscription(String audioPath) {
    debugPrint('📝 Using local transcription (simulation)');
    return 'This is a simulated transcription. Please connect to the internet for real transcription.';
  }

  // ============================================================
  // 6. حفظ للتحويل لاحقاً (Offline Mode)
  // ============================================================
  Future<void> _saveForLater(String audioPath) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final pending = prefs.getStringList(_pendingKey) ?? [];
      
      if (!pending.contains(audioPath)) {
        pending.add(audioPath);
        await prefs.setStringList(_pendingKey, pending);
        debugPrint('📁 Saved for later: $audioPath (${pending.length} pending)');
      }
    } catch (e) {
      debugPrint('❌ Failed to save for later: $e');
    }
  }

  // ============================================================
  // 7. معالجة الملفات المعلقة
  // ============================================================
  Future<List<String>> processPendingTranscriptions({
    required String apiKey,
    String language = 'ar',
    Function(String path, String text)? onSuccess,
    Function(String path, String error)? onError,
  }) async {
    final results = <String>[];
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final pending = prefs.getStringList(_pendingKey) ?? [];
      
      if (pending.isEmpty) {
        debugPrint('📭 No pending transcriptions');
        return results;
      }

      debugPrint('📦 Processing ${pending.length} pending transcriptions...');

      final online = await isConnected;
      if (!online) {
        debugPrint('📡 No internet - Cannot process pending');
        return results;
      }

      for (final path in pending) {
        try {
          final text = await transcribeAudio(
            audioPath: path,
            apiKey: apiKey,
            language: language,
          );

          if (text != null) {
            results.add(text);
            if (onSuccess != null) {
              onSuccess(path, text);
            }
            debugPrint('✅ Processed pending: $path');
          } else {
            if (onError != null) {
              onError(path, 'Transcription failed');
            }
            debugPrint('⚠️ Failed to process: $path');
          }
        } catch (e) {
          debugPrint('❌ Error processing $path: $e');
          if (onError != null) {
            onError(path, e.toString());
          }
        }
      }

      await prefs.remove(_pendingKey);
      debugPrint('✅ All pending transcriptions processed');

    } catch (e) {
      debugPrint('❌ Error processing pending: $e');
    }

    return results;
  }

  // ============================================================
  // 8. الحصول على عدد الملفات المعلقة
  // ============================================================
  Future<int> getPendingCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final pending = prefs.getStringList(_pendingKey) ?? [];
      return pending.length;
    } catch (e) {
      return 0;
    }
  }

  // ============================================================
  // 9. مسح الملفات المعلقة
  // ============================================================
  Future<void> clearPending() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_pendingKey);
      debugPrint('🗑️ Pending transcriptions cleared');
    } catch (e) {
      debugPrint('❌ Failed to clear pending: $e');
    }
  }

  // ============================================================
  // 10. التحقق من وجود ملفات معلقة
  // ============================================================
  Future<bool> hasPending() async {
    final count = await getPendingCount();
    return count > 0;
  }

  // ============================================================
  // 11. الحصول على حجم الملف (بالكيلوبايت)
  // ============================================================
  Future<String> getFileSizeString(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        final bytes = await file.length();
        if (bytes > 1024 * 1024) {
          return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
        } else if (bytes > 1024) {
          return '${(bytes / 1024).toStringAsFixed(1)} KB';
        } else {
          return '$bytes B';
        }
      }
      return '0 B';
    } catch (e) {
      return 'Unknown';
    }
  }

  // ============================================================
  // 12. دالة مساعدة: تنسيق API Key
  // ============================================================
  static String formatApiKey(String key) {
    if (key.length <= 8) return key;
    return '${key.substring(0, 4)}...${key.substring(key.length - 4)}';
  }
}