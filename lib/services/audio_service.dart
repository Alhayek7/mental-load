// ============================================================
// 📄 lib/services/audio_service.dart
// 📌 خدمة التسجيل الصوتي - Audio Recording Service
// ✅ النسخة الاحترافية النهائية
// ============================================================

import 'dart:io';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';

// ============================================================
// 🎵 AudioService - إدارة التسجيل الصوتي
// ============================================================
class AudioService {
  // ============================================================
  // 1. Singleton Pattern
  // ============================================================
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  // ============================================================
  // 2. المتغيرات
  // ============================================================
  final AudioRecorder _recorder = AudioRecorder();
  String? _currentRecordingPath;
  bool _isRecording = false;
  bool _isPaused = false;
  Duration _recordingDuration = Duration.zero;
  DateTime? _recordingStartTime;

  // ============================================================
  // 3. Getters
  // ============================================================
  bool get isRecording => _isRecording;
  bool get isPaused => _isPaused;
  String? get currentRecordingPath => _currentRecordingPath;
  Duration get recordingDuration => _recordingDuration;

  // ============================================================
  // 4. التحقق من الأذونات
  // ============================================================
  Future<bool> checkMicrophonePermission() async {
    try {
      final status = await Permission.microphone.status;
      
      if (status.isGranted) {
        debugPrint('✅ Microphone permission already granted');
        return true;
      }

      if (status.isDenied) {
        debugPrint('📱 Requesting microphone permission...');
        final result = await Permission.microphone.request();
        if (result.isGranted) {
          debugPrint('✅ Microphone permission granted');
          return true;
        } else {
          debugPrint('❌ Microphone permission denied');
          return false;
        }
      }

      if (status.isPermanentlyDenied) {
        debugPrint('⚠️ Microphone permission permanently denied');
        // ✅ توجيه المستخدم إلى إعدادات الجهاز
        await openAppSettings();
        return false;
      }

      return false;
    } catch (e) {
      debugPrint('❌ Error checking microphone permission: $e');
      return false;
    }
  }

  // ============================================================
  // 5. بدء التسجيل
  // ============================================================
  Future<bool> startRecording() async {
    // ✅ التحقق من الأذونات
    final hasPermission = await checkMicrophonePermission();
    if (!hasPermission) {
      debugPrint('❌ Cannot start recording: No permission');
      return false;
    }

    // ✅ التحقق من عدم وجود تسجيل قيد التشغيل
    if (_isRecording) {
      debugPrint('⚠️ Recording already in progress');
      return false;
    }

    try {
      // ✅ إنشاء مجلد التسجيلات
      final appDir = await getApplicationDocumentsDirectory();
      final recordingsDir = Directory('${appDir.path}/recordings');
      
      if (!await recordingsDir.exists()) {
        await recordingsDir.create(recursive: true);
        debugPrint('📁 Created recordings directory: ${recordingsDir.path}');
      }

      // ✅ إنشاء اسم الملف
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = '${recordingsDir.path}/audio_$timestamp.m4a';
      _currentRecordingPath = filePath;

      // ✅ بدء التسجيل
      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
          numChannels: 1,
        ),
        path: filePath,
      );

      _isRecording = true;
      _isPaused = false;
      _recordingDuration = Duration.zero;
      _recordingStartTime = DateTime.now();

      debugPrint('🎙️ Recording started: $filePath');
      return true;

    } catch (e) {
      debugPrint('❌ Error starting recording: $e');
      _isRecording = false;
      _currentRecordingPath = null;
      return false;
    }
  }

  // ============================================================
  // 6. إيقاف التسجيل
  // ============================================================
  Future<String?> stopRecording() async {
    if (!_isRecording) {
      debugPrint('⚠️ No recording in progress');
      return null;
    }

    try {
      final path = await _recorder.stop();
      _isRecording = false;
      _isPaused = false;
      
      if (_recordingStartTime != null) {
        _recordingDuration = DateTime.now().difference(_recordingStartTime!);
        _recordingStartTime = null;
      }

      debugPrint('⏹️ Recording stopped: $path');
      debugPrint('⏱️ Duration: ${_recordingDuration.inSeconds} seconds');
      
      return path ?? _currentRecordingPath;

    } catch (e) {
      debugPrint('❌ Error stopping recording: $e');
      return null;
    }
  }

  // ============================================================
  // 7. إيقاف التسجيل مؤقتاً
  // ============================================================
  Future<bool> pauseRecording() async {
    if (!_isRecording || _isPaused) {
      debugPrint('⚠️ Cannot pause: Not recording or already paused');
      return false;
    }

    try {
      await _recorder.pause();
      _isPaused = true;
      
      if (_recordingStartTime != null) {
        _recordingDuration += DateTime.now().difference(_recordingStartTime!);
        _recordingStartTime = null;
      }
      
      debugPrint('⏸️ Recording paused');
      return true;

    } catch (e) {
      debugPrint('❌ Error pausing recording: $e');
      return false;
    }
  }

  // ============================================================
  // 8. استئناف التسجيل
  // ============================================================
  Future<bool> resumeRecording() async {
    if (!_isRecording || !_isPaused) {
      debugPrint('⚠️ Cannot resume: Not paused or not recording');
      return false;
    }

    try {
      await _recorder.resume();
      _isPaused = false;
      _recordingStartTime = DateTime.now();
      
      debugPrint('▶️ Recording resumed');
      return true;

    } catch (e) {
      debugPrint('❌ Error resuming recording: $e');
      return false;
    }
  }

  // ============================================================
  // 9. حذف التسجيل
  // ============================================================
  Future<bool> deleteRecording(String? path) async {
    if (path == null) {
      debugPrint('⚠️ No path provided for deletion');
      return false;
    }

    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
        debugPrint('🗑️ Recording deleted: $path');
        
        if (_currentRecordingPath == path) {
          _currentRecordingPath = null;
        }
        return true;
      } else {
        debugPrint('⚠️ File does not exist: $path');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Error deleting recording: $e');
      return false;
    }
  }

  // ============================================================
  // 10. الحصول على حجم الملف
  // ============================================================
  Future<int?> getFileSize(String? path) async {
    if (path == null) return null;
    
    try {
      final file = File(path);
      if (await file.exists()) {
        return await file.length();
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error getting file size: $e');
      return null;
    }
  }

  // ============================================================
  // 11. تنسيق وقت التسجيل
  // ============================================================
  String formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    
    if (minutes > 0) {
      return '$minutes:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '0:${seconds.toString().padLeft(2, '0')}';
    }
  }

  // ============================================================
  // 12. الحصول على حالة التسجيل (نصية)
  // ============================================================
  String getRecordingStatus() {
    if (_isRecording && _isPaused) return 'Paused';
    if (_isRecording) return 'Recording';
    return 'Idle';
  }

  // ============================================================
  // 13. تنظيف الموارد
  // ============================================================
  Future<void> dispose() async {
    if (_isRecording) {
      await stopRecording();
    }
    _recorder.dispose();
    debugPrint('🧹 AudioService disposed');
  }

  // ============================================================
  // 14. التحقق من وجود تسجيل
  // ============================================================
  Future<bool> hasRecording(String? path) async {
    if (path == null) return false;
    try {
      final file = File(path);
      return await file.exists();
    } catch (e) {
      return false;
    }
  }

  // ============================================================
  // 15. الحصول على جميع التسجيلات
  // ============================================================
  Future<List<File>> getAllRecordings() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final recordingsDir = Directory('${appDir.path}/recordings');
      
      if (!await recordingsDir.exists()) {
        return [];
      }
      
      final files = await recordingsDir.list().toList();
      return files
          .whereType<File>()
          .where((file) => file.path.endsWith('.m4a'))
          .toList();
    } catch (e) {
      debugPrint('❌ Error getting recordings: $e');
      return [];
    }
  }
}