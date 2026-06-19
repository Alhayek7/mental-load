// ============================================================
// 📄 lib/services/ai_service.dart
// 📌 خدمة الذكاء الاصطناعي - ربط Flutter بالخادم
// ✅ متوافقة مع pubspec.yaml
// ============================================================

import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';

// ============================================================
// 📊 أنواع الأخطاء المخصصة
// ============================================================
enum AIErrorType {
  network,
  serverDown,
  timeout,
  invalidResponse,
  unknown,
}

class AIException implements Exception {
  final AIErrorType type;
  final String message;
  final dynamic originalError;

  AIException({
    required this.type,
    required this.message,
    this.originalError,
  });

  @override
  String toString() => 'AIException($type): $message';
}

// ============================================================
// 🧠 خدمة الذكاء الاصطناعي الرئيسية
// ============================================================
class AIService {
  // ============================================================
  // 1. Singleton Pattern
  // ============================================================
  static final AIService _instance = AIService._internal();
  factory AIService() => _instance;
  AIService._internal();

  // ============================================================
  // 2. الخصائص
  // ============================================================
  static const String _defaultServerUrl = 'http://localhost:5000';
  static String _serverUrl = _defaultServerUrl;
  
  // ✅ Cache
  final Map<String, Map<String, dynamic>> _cache = {};
  static const int _maxCacheSize = 50;
  
  // ✅ Retry Settings
  static const int _maxRetries = 3;
  static const Duration _retryDelay = Duration(seconds: 1);
  static const Duration _timeout = Duration(seconds: 10);
  
  // ✅ Endpoints
  String get _healthEndpoint => '$_serverUrl/health';
  String get _analyzeEndpoint => '$_serverUrl/analyze';

  // ============================================================
  // 3. إدارة عنوان الخادم
  // ============================================================
  static String get serverUrl => _serverUrl;
  
  static void setServerUrl(String url) {
    _serverUrl = url;
    debugPrint('🔄 Server URL updated to: $url');
  }
  
  static void resetServerUrl() {
    _serverUrl = _defaultServerUrl;
    debugPrint('🔄 Server URL reset to default');
  }

  // ============================================================
  // 4. التحقق من الاتصال
  // ============================================================
  Future<bool> get hasInternet async {
    try {
      final result = await Connectivity().checkConnectivity();
      return result != ConnectivityResult.none;
    } catch (e) {
      debugPrint('⚠️ Connectivity check failed: $e');
      return false;
    }
  }

  Future<bool> get isServerRunning async {
    try {
      final response = await http.get(
        Uri.parse(_healthEndpoint),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 3));
      
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('🖥️ Server health check: $e');
      return false;
    }
  }

  // ============================================================
  // 5. الدالة الرئيسية - تحليل النص
  // ============================================================
  Future<Map<String, dynamic>> analyzeText(String text) async {
    final key = text.hashCode.toString();
    
    // ✅ التحقق من Cache
    if (_cache.containsKey(key)) {
      debugPrint('📦 Using cached result for: ${text.substring(0, _min(50, text.length))}...');
      return _cache[key]!;
    }

    debugPrint('📝 Analyzing text: "${text.substring(0, _min(50, text.length))}..."');
    
    final online = await hasInternet;
    final serverRunning = await isServerRunning;

    Map<String, dynamic> result;
    
    if (online && serverRunning) {
      try {
        result = await _analyzeWithRetry(text);
        debugPrint('✅ AI analysis complete: score=${result['score']}, mode=${result['mode']}');
      } catch (e) {
        debugPrint('❌ AI Server error: $e');
        debugPrint('⚠️ Falling back to offline analysis');
        result = _analyzeOffline(text);
        result['mode'] = 'offline_fallback';
      }
    } else {
      final reason = !online ? 'No internet' : 'Server unavailable';
      debugPrint('⚠️ Using offline mode ($reason)');
      result = _analyzeOffline(text);
      result['mode'] = 'offline';
    }
    
    // ✅ حفظ في Cache
    if (_cache.length >= _maxCacheSize) {
      _cache.remove(_cache.keys.first);
    }
    _cache[key] = result;
    
    return result;
  }

  // ============================================================
  // 6. التحليل مع Retry Logic
  // ============================================================
  Future<Map<String, dynamic>> _analyzeWithRetry(String text) async {
    int attempts = 0;
    Exception? lastError;

    while (attempts < _maxRetries) {
      try {
        final result = await _analyzeWithModel(text);
        return result;
      } catch (e) {
        attempts++;
        lastError = e is Exception ? e : Exception(e.toString());
        debugPrint('⚠️ Attempt $attempts/$_maxRetries failed: $e');
        
        if (attempts < _maxRetries) {
          final delay = _retryDelay * attempts;
          debugPrint('⏳ Retrying in ${delay.inSeconds}s...');
          await Future.delayed(delay);
        }
      }
    }

    throw lastError ?? Exception('All retries failed');
  }

  // ============================================================
  // 7. التحليل مع النماذج (Flask Server)
  // ============================================================
  Future<Map<String, dynamic>> _analyzeWithModel(String text) async {
    try {
      final response = await http.post(
        Uri.parse(_analyzeEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'text': text}),
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        return _parseResponse(response);
      } else {
        throw AIException(
          type: AIErrorType.serverDown,
          message: 'Server error: ${response.statusCode}',
          originalError: response.body,
        );
      }
    } on http.ClientException catch (e) {
      throw AIException(
        type: AIErrorType.network,
        message: 'Network error - check your connection',
        originalError: e,
      );
    } on TimeoutException catch (e) {
      throw AIException(
        type: AIErrorType.timeout,
        message: 'Server timeout - try again',
        originalError: e,
      );
    } catch (e) {
      throw AIException(
        type: AIErrorType.unknown,
        message: 'Unexpected error: $e',
        originalError: e,
      );
    }
  }

  // ============================================================
  // 8. معالجة الاستجابة
  // ============================================================
  Map<String, dynamic> _parseResponse(http.Response response) {
    try {
      final result = jsonDecode(response.body);
      
      // ✅ التحقق من صحة البيانات
      final score = (result['score'] ?? 3) as int;
      if (score < 1 || score > 5) {
        throw AIException(
          type: AIErrorType.invalidResponse,
          message: 'Invalid score value: $score',
        );
      }
      
      return {
        'score': score.clamp(1, 5),
        'confidence': (result['confidence'] ?? 80).clamp(0, 100) as int,
        'recommendation': result['recommendation'] ?? _getDefaultRecommendation(score),
        'factors': result['factors'] ?? 'AI model analysis.',
        'mode': 'ai_model',
        'category': result['category'] ?? _getCategory(score),
      };
    } catch (e) {
      throw AIException(
        type: AIErrorType.invalidResponse,
        message: 'Invalid response format: $e',
        originalError: e,
      );
    }
  }

  // ============================================================
  // 9. التحليل المحلي (بدون إنترنت)
  // ============================================================
  Map<String, dynamic> _analyzeOffline(String text) {
    final score = _calculateScoreOffline(text);
    final category = _getCategory(score);
    
    return {
      'score': score,
      'confidence': 65,
      'recommendation': _getDefaultRecommendation(score),
      'factors': 'Local analysis based on keyword detection and text patterns.',
      'mode': 'offline',
      'category': category,
    };
  }

  // ============================================================
  // 10. حساب Score محلي (محسّن)
  // ============================================================
  int _calculateScoreOffline(String text) {
    double score = 2.0;
    final lowerText = text.toLowerCase();

    // ✅ كلمات مع أوزان مختلفة
    final Map<String, double> weightMap = {
      // كلمات عالية التأثير (تزيد Score)
      'exhausted': 0.8,
      'overwhelmed': 0.8,
      'burnout': 0.8,
      'tired': 0.5,
      'headache': 0.6,
      'stressed': 0.5,
      'fatigue': 0.6,
      'drained': 0.7,
      'brain fog': 0.7,
      "can't focus": 0.6,
      
      // كلمات منخفضة التأثير (تقلل Score)
      'productive': -0.5,
      'focused': -0.5,
      'great': -0.4,
      'energized': -0.6,
      'refreshed': -0.6,
      'calm': -0.4,
      'clear': -0.4,
      'motivated': -0.5,
      'sharp': -0.5,
    };

    // ✅ تطبيق الأوزان
    for (var entry in weightMap.entries) {
      if (lowerText.contains(entry.key)) {
        score += entry.value;
        debugPrint('📊 Word match: "${entry.key}" => ${entry.value > 0 ? '+' : ''}${entry.value}');
      }
    }

    // ✅ عامل طول النص (محسّن)
    if (text.length > 150) {
      score += 0.3;
      debugPrint('📊 Long text: +0.3');
    } else if (text.length > 80) {
      score += 0.1;
      debugPrint('📊 Medium text: +0.1');
    }

    // ✅ عامل علامات الترقيم (تعبر عن المشاعر)
    final exclamationCount = '!'.allMatches(text).length;
    if (exclamationCount > 3) {
      score += 0.2;
      debugPrint('📊 Many exclamation marks: +0.2');
    }

    // ✅ عامل الأسئلة (تدل على الحيرة)
    final questionCount = '?'.allMatches(text).length;
    if (questionCount > 2) {
      score += 0.2;
      debugPrint('📊 Many questions: +0.2');
    }

    // ✅ التأكد من النطاق
    final finalScore = score.round().clamp(1, 5);
    debugPrint('📊 Final score: $finalScore (from $score)');
    
    return finalScore;
  }

  // ============================================================
  // 11. دوال مساعدة
  // ============================================================
  String _getCategory(int score) {
    if (score <= 2) return 'Low';
    if (score == 3) return 'Moderate';
    if (score == 4) return 'High';
    return 'Critical';
  }

  String _getDefaultRecommendation(int score) {
    switch (score) {
      case 1:
        return '🌟 Excellent! You\'re managing your cognitive load perfectly. Keep up your current habits!';
      case 2:
        return '👍 You\'re doing great! Maintain your current balance and take short breaks when needed.';
      case 3:
        return '📊 Moderate cognitive load detected. Consider taking a 10-minute break and limiting AI tools.';
      case 4:
        return '⚠️ High cognitive load detected. Take a 20-minute break and reduce AI tools to 1-2.';
      case 5:
        return '🚨 Critical cognitive overload! Stop all AI tools immediately, rest for 30+ minutes.';
      default:
        return 'Keep monitoring your cognitive load regularly.';
    }
  }

  // ============================================================
  // 12. إدارة Cache
  // ============================================================
  void clearCache() {
    _cache.clear();
    debugPrint('🗑️ Cache cleared (${_cache.length} items)');
  }

  int get cacheSize => _cache.length;

  // ============================================================
  // 13. دالة مساعدة للتحديثات المستقبلية
  // ============================================================
  static String getVersion() {
    return '2.0.0';
  }

  // ============================================================
  // 14. دالة مساعدة خاصة
  // ============================================================
  int _min(int a, int b) => a < b ? a : b;
}