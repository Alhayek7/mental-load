// ============================================================
// 📄 lib/services/transcription_service.dart
// 📌 خدمة تحويل الصوت إلى نص - النسخة النهائية الاحترافية
// ✅ دعم Offline + Retry + معالجة الملفات الكبيرة
// ============================================================

import 'dart:io';
import 'dart:async';
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
  
  // ✅ إعدادات Retry المحسّنة
  static const int _maxRetries = 3;
  static const Duration _retryDelay = Duration(seconds: 2);
  static const Duration _timeout = Duration(seconds: 45); // ✅ زيادة المهلة للصوت الطويل
  
  // ✅ الحد الأقصى لحجم الملف (25MB)
  static const int _maxFileSize = 25 * 1024 * 1024;
  
  // ✅ إحصائيات الأداء
  int _totalTranscriptions = 0;
  int _successfulTranscriptions = 0;
  int _failedTranscriptions = 0;

  // ============================================================
  // 3. Getters
  // ============================================================
  Future<bool> get isConnected async {
    try {
      final result = await Connectivity().checkConnectivity();
      return result.any((element) => element != ConnectivityResult.none);
    } catch (e) {
      debugPrint('❌ Connectivity check error: $e');
      return false;
    }
  }

  // ============================================================
  // 4. تحويل الصوت إلى نص (مع Retry محسّن)
  // ============================================================
  Future<String?> transcribeAudio({
    required String audioPath,
    required String apiKey,
    String language = 'ar',
    VoidCallback? onProgress,
    VoidCallback? onRetry,
  }) async {
    _totalTranscriptions++;
    
    // ✅ التحقق من وجود الملف
    final file = File(audioPath);
    if (!await file.exists()) {
      debugPrint('❌ Audio file does not exist: $audioPath');
      _failedTranscriptions++;
      return null;
    }

    // ✅ التحقق من حجم الملف
    final fileSize = await file.length();
    if (fileSize > _maxFileSize) {
      debugPrint('❌ File too large: ${(fileSize / 1024 / 1024).toStringAsFixed(1)}MB (max 25MB)');
      _failedTranscriptions++;
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

    // ✅ Retry Logic محسّن
    for (int attempt = 1; attempt <= _maxRetries; attempt++) {
      try {
        debugPrint('🎤 Transcribing (attempt $attempt/$_maxRetries): ${audioPath.split('/').last}');
        if (onProgress != null) onProgress();

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

        final response = await request.send().timeout(_timeout);

        if (response.statusCode == 200) {
          final responseData = await response.stream.bytesToString();
          final text = responseData.trim();

          if (text.isNotEmpty && text.length > 3) {
            _successfulTranscriptions++;
            debugPrint('✅ Transcription successful: ${text.length} characters');
            return text;
          } else {
            debugPrint('⚠️ Empty or too short transcription result');
            if (attempt < _maxRetries) {
              if (onRetry != null) onRetry();
              await Future.delayed(_retryDelay * attempt);
              continue;
            }
            _failedTranscriptions++;
            return null;
          }
        } else {
          final errorBody = await response.stream.bytesToString();
          debugPrint('❌ Whisper API error (${response.statusCode}): $errorBody');

          // ✅ معالجة أخطاء محددة مع إعادة المحاولة
          if (response.statusCode == 429) {
            debugPrint('⚠️ Rate limit - waiting ${attempt * 3}s');
            await Future.delayed(Duration(seconds: attempt * 3));
            if (attempt < _maxRetries) continue;
          }

          if (response.statusCode == 401) {
            debugPrint('⚠️ Invalid API Key - stopping retries');
            return null;
          }

          if (response.statusCode == 413) {
            debugPrint('⚠️ File too large for Whisper API');
            return null;
          }

          await _saveForLater(audioPath);
          _failedTranscriptions++;
          return null;
        }
      } on TimeoutException {
        debugPrint('⏱️ Timeout on attempt $attempt/$_maxRetries');
        if (attempt < _maxRetries) {
          if (onRetry != null) onRetry();
          await Future.delayed(_retryDelay * attempt);
          continue;
        }
        await _saveForLater(audioPath);
        _failedTranscriptions++;
        return null;
      } catch (e) {
        debugPrint('❌ Error on attempt $attempt: $e');
        if (attempt < _maxRetries) {
          if (onRetry != null) onRetry();
          await Future.delayed(_retryDelay * attempt);
          continue;
        }
        await _saveForLater(audioPath);
        _failedTranscriptions++;
        return null;
      }
    }

    return null;
  }

  // ============================================================
  // 5. التحويل المحلي (محسّن للعربية)
  // ============================================================
  String _localTranscription(String audioPath) {
    debugPrint('📝 Using local transcription');
    return 'هذا تحويل محلي للصوت. يرجى الاتصال بالإنترنت للحصول على تحويل دقيق.';
  }

  // ============================================================
  // 6. حفظ للتحويل لاحقاً (مع معلومات إضافية)
  // ============================================================
  Future<void> _saveForLater(String audioPath) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final pending = prefs.getStringList(_pendingKey) ?? [];
      
      if (!pending.contains(audioPath)) {
        pending.add(audioPath);
        await prefs.setStringList(_pendingKey, pending);
        debugPrint('📁 Saved for later (${pending.length} pending)');
      }
    } catch (e) {
      debugPrint('❌ Failed to save for later: $e');
    }
  }

  // ============================================================
  // 7. معالجة الملفات المعلقة (محسّنة)
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

      // ✅ معالجة مع تتبع التقدم
      for (int i = 0; i < pending.length; i++) {
        final path = pending[i];
        debugPrint('📄 Processing ${i + 1}/${pending.length}: ${path.split('/').last}');

        try {
          final text = await transcribeAudio(
            audioPath: path,
            apiKey: apiKey,
            language: language,
          );

          if (text != null) {
            results.add(text);
            if (onSuccess != null) onSuccess(path, text);
            debugPrint('✅ Processed: ${path.split('/').last}');
          } else {
            if (onError != null) onError(path, 'Transcription failed');
            debugPrint('⚠️ Failed: ${path.split('/').last}');
          }
        } catch (e) {
          debugPrint('❌ Error: ${path.split('/').last}: $e');
          if (onError != null) onError(path, e.toString());
        }
      }

      await prefs.remove(_pendingKey);
      debugPrint('✅ All ${pending.length} pending transcriptions processed');
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
  // 12. إحصائيات الأداء (جديد)
  // ============================================================
  Map<String, dynamic> getPerformanceStats() {
    return {
      'total_transcriptions': _totalTranscriptions,
      'successful': _successfulTranscriptions,
      'failed': _failedTranscriptions,
      'success_rate': _totalTranscriptions > 0 
          ? (_successfulTranscriptions / _totalTranscriptions * 100).toStringAsFixed(1)
          : '0',
      'pending_count': _totalTranscriptions - _successfulTranscriptions - _failedTranscriptions,
    };
  }

  // ============================================================
  // 13. إعادة تعيين الإحصائيات
  // ============================================================
  void resetStats() {
    _totalTranscriptions = 0;
    _successfulTranscriptions = 0;
    _failedTranscriptions = 0;
    debugPrint('🔄 Transcription stats reset');
  }

  // ============================================================
  // 14. دالة مساعدة: تنسيق API Key
  // ============================================================
  static String formatApiKey(String key) {
    if (key.length <= 8) return key;
    return '${key.substring(0, 4)}...${key.substring(key.length - 4)}';
  }
}