// ============================================================
// 📄 lib/services/ai_service.dart
// 📌 خدمة الذكاء الاصطناعي - النسخة النهائية الاحترافية
// ✅ دعم Offline + Cache + Retry + تحليل تفصيلي
// ============================================================

import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  static const int _maxCacheSize = 100; // ✅ زيادة إلى 100
  
  // ✅ Retry Settings
  static const int _maxRetries = 3;
  static const Duration _retryDelay = Duration(seconds: 1);
  static const Duration _timeout = Duration(seconds: 10);
  
  // ✅ إحصائيات الأداء
  int _totalRequests = 0;
  int _cacheHits = 0;
  int _failedRequests = 0;
  
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
  // 5. الدالة الرئيسية - تحليل النص (محسّنة)
  // ============================================================
  Future<Map<String, dynamic>> analyzeText(String text) async {
    _totalRequests++;
    final key = text.hashCode.toString();
    
    // ✅ التحقق من Cache
    if (_cache.containsKey(key)) {
      _cacheHits++;
      debugPrint('📦 Cache hit (${_cacheHits}/$_totalRequests)');
      return _cache[key]!;
    }

    debugPrint('📝 Analyzing: "${text.substring(0, _min(50, text.length))}..."');
    
    final online = await hasInternet;
    final serverRunning = await isServerRunning;

    Map<String, dynamic> result;
    
    if (online && serverRunning) {
      try {
        result = await _analyzeWithRetry(text);
        debugPrint('✅ AI analysis: score=${result['score']}, mode=${result['mode']}');
      } catch (e) {
        _failedRequests++;
        debugPrint('❌ AI Server error: $e');
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
    
    // ✅ حفظ الإحصائيات
    await _savePerformanceStats();
    
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
  // 8. معالجة الاستجابة (محسّنة)
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
        // ✅ إضافة تحليل تفصيلي
        'details': result['details'] ?? _getDetailedAnalysis(response.body),
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
  // 9. التحليل المحلي (محسّن جداً)
  // ============================================================
  Map<String, dynamic> _analyzeOffline(String text) {
    final score = _calculateScoreOffline(text);
    final category = _getCategory(score);
    final details = _getDetailedAnalysis(text);
    
    return {
      'score': score,
      'confidence': 65,
      'recommendation': _getDefaultRecommendation(score),
      'factors': 'Local analysis based on keyword detection and text patterns.',
      'mode': 'offline',
      'category': category,
      'details': details,
    };
  }

  // ============================================================
  // 10. حساب Score محلي (محسّن جداً)
  // ============================================================
  int _calculateScoreOffline(String text) {
    double score = 2.0;
    final lowerText = text.toLowerCase();

    // ✅ كلمات مع أوزان دقيقة
    final Map<String, double> weightMap = {
      // 🔴 كلمات عالية التأثير (تزيد Score)
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
      'anxious': 0.5,
      'pressure': 0.4,
      'deadline': 0.3,
      'rush': 0.3,
      'panic': 0.5,
      
      // 🟢 كلمات منخفضة التأثير (تقلل Score)
      'productive': -0.5,
      'focused': -0.5,
      'great': -0.4,
      'energized': -0.6,
      'refreshed': -0.6,
      'calm': -0.4,
      'clear': -0.4,
      'motivated': -0.5,
      'sharp': -0.5,
      'efficient': -0.3,
      'accomplished': -0.3,
      'satisfied': -0.2,
    };

    // ✅ تطبيق الأوزان مع التكرارات
    for (var entry in weightMap.entries) {
      final occurrences = lowerText.split(entry.key).length - 1;
      if (occurrences > 0) {
        score += entry.value * occurrences.clamp(1, 3);
      }
    }

    // ✅ عامل طول النص
    if (text.length > 200) {
      score += 0.4;
    } else if (text.length > 100) {
      score += 0.2;
    } else if (text.length < 20) {
      score -= 0.2;
    }

    // ✅ عامل علامات الترقيم
    final exclamationCount = '!'.allMatches(text).length;
    if (exclamationCount > 3) {
      score += 0.3;
    }

    final questionCount = '?'.allMatches(text).length;
    if (questionCount > 2) {
      score += 0.2;
    }

    // ✅ عامل الأحرف الكبيرة
    final upperCount = text.split('').where((c) => c.toUpperCase() == c && c != ' ' && c != '.').length;
    if (upperCount > 10) {
      score += 0.2;
    }

    return score.round().clamp(1, 5);
  }

  // ============================================================
  // 11. تحليل تفصيلي للنص (جديد)
  // ============================================================
  Map<String, dynamic> _getDetailedAnalysis(String text) {
    final lowerText = text.toLowerCase();
    
    final factors = <String>[];
    final recommendations = <String>[];
    final wordCount = text.split(' ').length;

    // ✅ الكشف عن العوامل المؤثرة
    if (lowerText.contains('tired') || lowerText.contains('exhausted')) {
      factors.add('Physical fatigue detected');
      recommendations.add('Take a 15-minute power nap or rest break');
    }
    if (lowerText.contains('headache') || lowerText.contains('stressed')) {
      factors.add('Stress indicators present');
      recommendations.add('Practice deep breathing exercises (5-5-5 method)');
    }
    if (lowerText.contains("can't focus") || lowerText.contains('distracted')) {
      factors.add('Focus difficulties identified');
      recommendations.add('Try the Pomodoro technique (25 min work, 5 min break)');
    }
    if (lowerText.contains('overwhelmed')) {
      factors.add('Overwhelm detected');
      recommendations.add('Break tasks into smaller, manageable steps');
    }
    if (lowerText.contains('productive') || lowerText.contains('focused')) {
      factors.add('Positive productivity indicators');
      recommendations.add('Maintain current habits and track progress');
    }
    if (lowerText.contains('great') || lowerText.contains('good')) {
      factors.add('Positive mindset detected');
      recommendations.add('Celebrate small wins and stay consistent');
    }

    // ✅ نصائح إضافية حسب طول النص
    if (wordCount > 150) {
      recommendations.add('Consider summarizing your thoughts for better clarity');
    }
    if (wordCount < 20) {
      recommendations.add('Try to elaborate more on your thoughts for deeper analysis');
    }

    // ✅ تحديد المشاعر
    String sentiment = 'Neutral';
    if (factors.any((f) => f.contains('Positive'))) {
      sentiment = 'Positive';
    } else if (factors.any((f) => f.contains('fatigue') || f.contains('stress') || f.contains('overwhelm'))) {
      sentiment = 'Needs Attention';
    }

    return {
      'factors': factors,
      'recommendations': recommendations,
      'word_count': wordCount,
      'sentiment': sentiment,
    };
  }

  // ============================================================
  // 12. دوال مساعدة محسّنة
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
        return '🌟 Excellent! You\'re managing your cognitive load perfectly. Keep up your current habits and maintain this balance.';
      case 2:
        return '👍 You\'re doing great! Maintain your current balance and take short breaks when needed to stay fresh.';
      case 3:
        return '📊 Moderate cognitive load detected. Consider taking a 10-minute break and limiting AI tools to 2 per session.';
      case 4:
        return '⚠️ High cognitive load detected. Take a 20-minute break, reduce AI tools to 1-2, and practice deep breathing.';
      case 5:
        return '🚨 Critical cognitive overload! Stop all AI tools immediately, rest for 30+ minutes, and avoid screens.';
      default:
        return 'Keep monitoring your cognitive load regularly.';
    }
  }

  // ============================================================
  // 13. إدارة الإحصائيات (جديد)
  // ============================================================
  Future<void> _savePerformanceStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('ai_total_requests', _totalRequests);
      await prefs.setInt('ai_cache_hits', _cacheHits);
      await prefs.setInt('ai_failed_requests', _failedRequests);
    } catch (e) {
      debugPrint('⚠️ Failed to save performance stats: $e');
    }
  }

  Map<String, dynamic> getPerformanceStats() {
    return {
      'total_requests': _totalRequests,
      'cache_hits': _cacheHits,
      'cache_hit_rate': _totalRequests > 0 ? (_cacheHits / _totalRequests * 100).toStringAsFixed(1) : '0',
      'failed_requests': _failedRequests,
      'cache_size': _cache.length,
    };
  }

  // ============================================================
  // 14. إدارة Cache
  // ============================================================
  void clearCache() {
    _cache.clear();
    _totalRequests = 0;
    _cacheHits = 0;
    _failedRequests = 0;
    debugPrint('🗑️ Cache cleared and stats reset');
  }

  int get cacheSize => _cache.length;

  // ============================================================
  // 15. دوال مساعدة
  // ============================================================
  static String getVersion() {
    return '2.1.0';
  }

  int _min(int a, int b) => a < b ? a : b;
}