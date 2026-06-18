// ============================================================
// 📄 lib/services/ai_service.dart
// 📌 خدمة الذكاء الاصطناعي - ربط Flutter بالخادم
// ============================================================

import 'dart:convert';
import 'package:flutter/foundation.dart';  // ✅ لـ debugPrint
import 'package:http/http.dart' as http;
import 'package:internet_connection_checker/internet_connection_checker.dart';

class AIService {
  static final AIService _instance = AIService._internal();
  factory AIService() => _instance;
  AIService._internal();

  // ============================================================
  // خادم Flask المحلي
  // ============================================================
  static const String _localServerUrl = 'http://localhost:5000';
  static const String _healthEndpoint = '$_localServerUrl/health';
  static const String _analyzeEndpoint = '$_localServerUrl/analyze';

  // ============================================================
  // التحقق من الاتصال بالإنترنت
  // ============================================================
  Future<bool> get hasInternet async {
    return await InternetConnectionChecker().hasConnection;
  }

  // ============================================================
  // التحقق من أن الخادم يعمل
  // ============================================================
  Future<bool> get isServerRunning async {
    try {
      final response = await http.get(
        Uri.parse(_healthEndpoint),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 3));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // ============================================================
  // الدالة الرئيسية: تحليل النص
  // ============================================================
  Future<Map<String, dynamic>> analyzeText(String text) async {
    final online = await hasInternet;
    final serverRunning = await isServerRunning;

    if (online && serverRunning) {
      try {
        return await _analyzeWithModel(text);
      } catch (e) {
        debugPrint('❌ AI Server error: $e');
        return _analyzeOffline(text);
      }
    } else {
      return _analyzeOffline(text);
    }
  }

  // ============================================================
  // تحليل مع النماذج (Flask)
  // ============================================================
  Future<Map<String, dynamic>> _analyzeWithModel(String text) async {
    final response = await http.post(
      Uri.parse(_analyzeEndpoint),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'text': text}),
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      return {
        'score': (result['score'] ?? 3) as int,
        'confidence': (result['confidence'] ?? 80) as int,
        'recommendation': result['recommendation'] ?? _getDefaultRecommendation(result['score'] ?? 3),
        'factors': result['factors'] ?? 'AI model analysis.',
        'mode': 'ai_model',
        'category': result['category'] ?? 'Moderate',
      };
    } else {
      throw Exception('AI Server failed: ${response.statusCode}');
    }
  }

  // ============================================================
  // تحليل محلي (بدون إنترنت)
  // ============================================================
  Map<String, dynamic> _analyzeOffline(String text) {
    final score = _calculateScoreOffline(text);
    final category = _getCategory(score);
    
    return {
      'score': score,
      'confidence': 65,
      'recommendation': _getDefaultRecommendation(score),
      'factors': 'Local analysis based on keyword detection.',
      'mode': 'offline',
      'category': category,
    };
  }

  // ============================================================
  // حساب Score محلي (تعمل مع double)
  // ============================================================
  int _calculateScoreOffline(String text) {
    double score = 2.0;  // ✅ استخدم double
    final lowerText = text.toLowerCase();

    final highWords = [
      'tired', 'exhausted', 'headache', 'can\'t focus', 'overwhelmed',
      'stressed', 'burnout', 'fatigue', 'drained', 'heavy', 'brain fog'
    ];
    final lowWords = [
      'productive', 'focused', 'great', 'good', 'energized',
      'refreshed', 'calm', 'clear', 'motivated', 'sharp'
    ];

    for (var word in highWords) {
      if (lowerText.contains(word)) {
        score += 0.5;
        if (score >= 5) break;
      }
    }

    for (var word in lowWords) {
      if (lowerText.contains(word)) {
        score -= 0.3;
        if (score <= 1) break;
      }
    }

    if (text.length > 100) score += 0.2;
    if (text.length < 20) score -= 0.2;

    return score.round().clamp(1, 5);
  }

  // ============================================================
  // دوال مساعدة
  // ============================================================
  String _getCategory(int score) {
    if (score <= 2) return 'Low';
    if (score == 3) return 'Moderate';
    return 'High';
  }

  String _getDefaultRecommendation(int score) {
    switch (score) {
      case 1:
      case 2:
        return '🌟 You\'re doing great! Keep up your current habits.';
      case 3:
        return '📊 Moderate cognitive load. Take a short break.';
      case 4:
        return '⚠️ High cognitive load. Take a 20-minute break.';
      case 5:
        return '🚨 Very high cognitive load. Take a 30-minute break.';
      default:
        return 'Keep monitoring your cognitive load.';
    }
  }
}