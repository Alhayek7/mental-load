// lib/services/google_stt_service.dart
import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;

class GoogleSTTService {
  static const String _credentialsPath = 'assets/google_credentials.json';

  Future<String?> transcribeAudio(String audioPath) async {
    try {
      final accessToken = await _getAccessToken();
      if (accessToken == null) return null;

      final audioBytes = await File(audioPath).readAsBytes();
      final base64Audio = base64Encode(audioBytes);

      final response = await http.post(
        Uri.parse('https://speech.googleapis.com/v1/speech:recognize'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json; charset=utf-8',
        },
        body: jsonEncode({
          'config': {
            'encoding': 'MPEG_AUDIO',
            'sampleRateHertz': 44100,
            'languageCode': 'ar-EG',
            'enableAutomaticPunctuation': true,
            'useEnhanced': true,
            'model': 'default',
          },
          'audio': {
            'content': base64Audio,
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['results'] != null && data['results'].isNotEmpty) {
          final result = data['results'][0];
          if (result['alternatives'] != null && result['alternatives'].isNotEmpty) {
            return result['alternatives'][0]['transcript'];
          }
        }
        return null;
      } else {
        debugPrint('❌ Google STT error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('❌ Google STT exception: $e');
      return null;
    }
  }

  Future<String?> _getAccessToken() async {
    try {
      final jsonString = await rootBundle.loadString(_credentialsPath);
      final credentials = jsonDecode(jsonString);
      
      final jwt = _createJWT(credentials);
      
      final response = await http.post(
        Uri.parse('https://oauth2.googleapis.com/token'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'grant_type': 'urn:ietf:params:oauth:grant-type:jwt-bearer',
          'assertion': jwt,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['access_token'];
      } else {
        debugPrint('❌ Token error: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('❌ Google STT Auth error: $e');
      return null;
    }
  }

  String _createJWT(Map<String, dynamic> credentials) {
    // ✅ هذه دالة مبسطة - استخدم googleapis_auth للحصول على JWT صحيح
    throw Exception('JWT creation requires googleapis_auth package');
  }
}