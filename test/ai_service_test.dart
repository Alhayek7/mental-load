// test/ai_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mental_load/services/ai_service.dart';

void main() {
  group('AIService Tests', () {
    late AIService service;

    setUp(() {
      service = AIService();
      service.clearCache();
    });

    test('Offline analysis returns valid result', () async {
      final result = await service.analyzeText('I feel productive and focused');
      
      expect(result['score'], isA<int>());
      expect(result['score'], inInclusiveRange(1, 5));
      expect(result['confidence'], equals(65));
      expect(result['mode'], isIn(['offline', 'offline_fallback']));
    });

    test('Score calculation is correct - positive text', () async {
      final result = await service.analyzeText('I had a great productive day, very focused and motivated');
      expect(result['score'], lessThan(3));
    });

    test('Score calculation is correct - negative text', () async {
      final result = await service.analyzeText('I feel exhausted and overwhelmed, can\'t focus');
      expect(result['score'], greaterThan(3));
    });

    test('Caching works correctly', () async {
      const text = 'Test cache';
      
      final firstResult = await service.analyzeText(text);
      final secondResult = await service.analyzeText(text);
      
      expect(firstResult, equals(secondResult));
      expect(service.cacheSize, greaterThan(0));
    });

    test('Clear cache works', () async {
      await service.analyzeText('Test text');
      expect(service.cacheSize, greaterThan(0));
      
      service.clearCache();
      expect(service.cacheSize, equals(0));
    });

    test('Server URL management works', () {
      final defaultUrl = AIService.serverUrl;
      expect(defaultUrl, equals('http://localhost:5000'));
      
      AIService.setServerUrl('http://192.168.1.100:5000');
      expect(AIService.serverUrl, equals('http://192.168.1.100:5000'));
      
      AIService.resetServerUrl();
      expect(AIService.serverUrl, equals('http://localhost:5000'));
    });

    test('Version is correct', () {
      expect(AIService.getVersion(), equals('2.0.0'));
    });
  });
}