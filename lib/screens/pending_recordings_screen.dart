// lib/screens/pending_recordings_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/transcription_service.dart';
import '../services/key_service.dart';
import 'package:audioplayers/audioplayers.dart'; 

class PendingRecordingsScreen extends StatefulWidget {
  const PendingRecordingsScreen({super.key});

  @override
  State<PendingRecordingsScreen> createState() =>
      _PendingRecordingsScreenState();
}

class _PendingRecordingsScreenState extends State<PendingRecordingsScreen> {
  final TranscriptionService _transcriptionService = TranscriptionService();
  final KeyService _keyService = KeyService();
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  List<String> _pendingFiles = [];
  bool _isLoading = true;
  bool _isProcessing = false;
  Map<int, bool> _processingStatus = {};
  Map<int, bool> _isPlaying = {}; 

  @override
  void initState() {
    super.initState();
    _loadPendingFiles();
  }


@override
void dispose() {
  _audioPlayer.dispose(); // ✅ التخلص من المشغل
  super.dispose();
}

  Future<void> _loadPendingFiles() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      _pendingFiles = prefs.getStringList('pending_transcriptions') ?? [];
    } catch (e) {
      debugPrint('❌ Error loading pending files: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteFile(int index) async {
    try {
      final file = File(_pendingFiles[index]);
      if (await file.exists()) {
        await file.delete();
      }

      final prefs = await SharedPreferences.getInstance();
      _pendingFiles.removeAt(index);
      await prefs.setStringList('pending_transcriptions', _pendingFiles);

      setState(() {});
      _showSnack('🗑️ File deleted successfully', isError: false);
    } catch (e) {
      _showSnack('❌ Failed to delete file', isError: true);
    }
  }

Future<void> _processAllFiles() async {
  if (_pendingFiles.isEmpty) {
    _showSnack('📭 No pending files to process', isError: false);
    return;
  }

  final apiKey = await _keyService.getOpenAIKey();
  if (apiKey == null || apiKey.isEmpty) {
    _showSnack('⚠️ Please add OpenAI API Key in settings', isError: true);
    return;
  }

  if (!mounted) return;
  setState(() {
    _isProcessing = true;
    _processingStatus = {};
  });

  int successCount = 0;
  int failCount = 0;

  for (int i = 0; i < _pendingFiles.length; i++) {
    if (!mounted) break;
    
    final path = _pendingFiles[i];
    setState(() {
      _processingStatus[i] = true;
    });

    try {
      final text = await _transcriptionService.transcribeAudio(
        audioPath: path,
        apiKey: apiKey,
        language: 'ar',
      );

      if (mounted) {
        if (text != null && text.isNotEmpty) {
          successCount++;
          _showSnack('✅ File ${i + 1} processed', isError: false);
        } else {
          failCount++;
          _showSnack('⚠️ File ${i + 1} failed', isError: true);
        }
      }
    } catch (e) {
      failCount++;
      debugPrint('❌ Error processing file $i: $e');
    }

    if (mounted) {
      setState(() {
        _processingStatus[i] = false;
      });
    }
  }

  if (mounted) {
    await _loadPendingFiles();
    setState(() => _isProcessing = false);
    _showSnack(
      '✅ Processed: $successCount, Failed: $failCount',
      isError: failCount > 0,
    );
  }
}
  String _getFileSize(String path) {
    try {
      final file = File(path);
      if (file.existsSync()) {
        final bytes = file.lengthSync();
        if (bytes > 1024 * 1024) {
          return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
        } else if (bytes > 1024) {
          return '${(bytes / 1024).toStringAsFixed(1)} KB';
        } else {
          return '$bytes B';
        }
      }
      return 'File not found';
    } catch (e) {
      return 'Unknown';
    }
  }

  String _getFileName(String path) {
    return path.split('/').last;
  }

  void _showSnack(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? const Color(0xFFE76F51) : const Color(0xFF2D6A4F),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }
  // ✅ تشغيل/إيقاف التسجيل
Future<void> _togglePlayback(int index) async {
  final path = _pendingFiles[index];
  final file = File(path);
  
  if (!await file.exists()) {
    _showSnack('⚠️ File not found', isError: true);
    return;
  }

  // ✅ إذا كان يعمل حالياً، أوقفه
  if (_isPlaying[index] == true) {
    await _audioPlayer.stop();
    setState(() {
      _isPlaying[index] = false;
    });
    return;
  }

  // ✅ تشغيل الملف
  try {
    setState(() {
      _isPlaying[index] = true;
    });

    await _audioPlayer.play(DeviceFileSource(path));
    
    // ✅ عند انتهاء التشغيل تلقائياً
    _audioPlayer.onPlayerComplete.listen((event) {
      if (mounted) {
        setState(() {
          _isPlaying[index] = false;
        });
      }
    });
    
    _showSnack('🎧 Playing recording...', isError: false);
  } catch (e) {
    setState(() {
      _isPlaying[index] = false;
    });
    _showSnack('❌ Failed to play audio', isError: true);
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            const Icon(Icons.audio_file, color: Color(0xFF5E35B1)),
            const SizedBox(width: 10),
            Text(
              'Pending Recordings',
              style: GoogleFonts.manrope(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1A1A2E),
              ),
            ),
          ],
        ),
        actions: [
          if (_pendingFiles.isNotEmpty && !_isProcessing)
            IconButton(
              onPressed: _processAllFiles,
              icon: const Icon(Icons.play_arrow, color: Color(0xFF2D6A4F)),
              tooltip: 'Process all',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF5E35B1)),
            )
          : _pendingFiles.isEmpty
              ? _buildEmptyState()
              : Column(
                  children: [
                    _buildStatsBar(),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        physics: const BouncingScrollPhysics(),
                        itemCount: _pendingFiles.length,
                        itemBuilder: (context, index) {
                          return _buildFileItem(index);
                        },
                      ),
                    ),
                    if (_isProcessing) _buildProcessingOverlay(),
                  ],
                ),
    );
  }

Widget _buildStatsBar() {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border(
        bottom: BorderSide(color: const Color(0xFFE8E8EE)),
      ),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '${_pendingFiles.length} files',
          style: GoogleFonts.manrope(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A1A2E),
          ),
        ),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF4A261).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _getTotalSize(), // ✅ إزالة ${}
                style: GoogleFonts.manrope(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFFF4A261),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF5235C5).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Awaiting Wi-Fi',
                style: GoogleFonts.manrope(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF5235C5),
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

Widget _buildFileItem(int index) {
  final path = _pendingFiles[index];
  final isProcessing = _processingStatus[index] == true;
  final isPlaying = _isPlaying[index] == true;
  final fileExists = File(path).existsSync();

  return Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: fileExists ? const Color(0xFFE8E8EE) : const Color(0xFFE76F51),
        width: fileExists ? 1 : 2,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.02),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Row(
      children: [
        // ✅ زر التشغيل/الإيقاف
        GestureDetector(
          onTap: fileExists ? () => _togglePlayback(index) : null,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: fileExists
                  ? (isPlaying
                      ? const Color(0xFFE76F51).withValues(alpha: 0.15)
                      : const Color(0xFF5235C5).withValues(alpha: 0.08))
                  : const Color(0xFFE76F51).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isPlaying ? Icons.stop : Icons.play_arrow,
              color: fileExists
                  ? (isPlaying
                      ? const Color(0xFFE76F51)
                      : const Color(0xFF5235C5))
                  : const Color(0xFFE76F51),
              size: 28,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getFileName(path),
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1A1A2E),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
Row(
  mainAxisSize: MainAxisSize.min, // ✅ منع التمدد الزائد
  children: [
    Text(
      _getFileSize(path),
      style: GoogleFonts.manrope(
        fontSize: 12,
        color: const Color(0xFF8A8A9A),
      ),
    ),
    const SizedBox(width: 8),
    Container(
      width: 4,
      height: 4,
      decoration: const BoxDecoration(
        color: Color(0xFFD1D1D8),
        shape: BoxShape.circle,
      ),
    ),
    const SizedBox(width: 8),
    Flexible( // ✅ منع التجاوز
      child: Text(
        fileExists ? '📁 Available' : '⚠️ Missing',
        style: GoogleFonts.manrope(
          fontSize: 12,
          color: fileExists
              ? const Color(0xFF2D6A4F)
              : const Color(0xFFE76F51),
        ),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
    ),
    if (isPlaying) ...[
      const SizedBox(width: 8),
      Container(
        width: 6,
        height: 6,
        decoration: const BoxDecoration(
          color: Color(0xFFE76F51),
          shape: BoxShape.circle,
        ),
      ),
      const SizedBox(width: 6),
      Flexible( // ✅ منع التجاوز
        child: Text(
          '🔴 Playing',
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFFE76F51),
            fontWeight: FontWeight.w600,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ),
    ],
  ],
),
            ],
          ),
        ),
        if (isProcessing)
          const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Color(0xFF5235C5),
            ),
          )
        else
          Row(
            children: [
              IconButton(
                onPressed: () => _processSingleFile(index),
                icon: const Icon(Icons.auto_awesome, color: Color(0xFF5235C5)),
                tooltip: 'Process this file',
              ),
              IconButton(
                onPressed: () => _showDeleteDialog(index),
                icon: const Icon(Icons.delete, color: Color(0xFFE76F51)),
                tooltip: 'Delete this file',
              ),
            ],
          ),
      ],
    ),
  );
}

Future<void> _processSingleFile(int index) async {
  final apiKey = await _keyService.getOpenAIKey();
  if (apiKey == null || apiKey.isEmpty) {
    _showSnack('⚠️ Please add OpenAI API Key in settings', isError: true);
    return;
  }

  setState(() {
    _processingStatus[index] = true;
  });

  try {
    final text = await _transcriptionService.transcribeAudio(
      audioPath: _pendingFiles[index],
      apiKey: apiKey,
      language: 'ar',
    );

    if (mounted) {
      if (text != null && text.isNotEmpty) {
        _showSnack('✅ Transcription successful!', isError: false);
        await _loadPendingFiles(); // ✅ تحديث القائمة
      } else {
        _showSnack('⚠️ Transcription failed', isError: true);
        setState(() {
          _processingStatus[index] = false;
        });
      }
    }
  } catch (e) {
    if (mounted) {
      _showSnack('❌ Error: ${e.toString()}', isError: true);
      setState(() {
        _processingStatus[index] = false;
      });
    }
  }
}

void _showDeleteDialog(int index) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder( // ✅ إزالة const
        borderRadius: BorderRadius.circular(20),
      ),
      title: const Text('Delete Recording?'),
      content: const Text('This action cannot be undone. Are you sure?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            _deleteFile(index);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE76F51),
            foregroundColor: Colors.white,
          ),
          child: const Text('Delete'),
        ),
      ],
    ),
  );
}

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF5235C5).withValues(alpha: 0.06),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.audio_file,
              size: 64,
              color: Color(0xFF5235C5),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Pending Recordings',
            style: GoogleFonts.manrope(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'All your recordings have been processed.',
            style: GoogleFonts.manrope(
              fontSize: 14,
              color: const Color(0xFF6B6B7A),
            ),
          ),
        ],
      ),
    );
  }

String _getTotalSize() {
  int totalBytes = 0;
  for (final path in _pendingFiles) {
    try {
      final file = File(path);
      if (file.existsSync()) {
        totalBytes += file.lengthSync();
      }
    } catch (_) {
      // ✅ تجاهل الأخطاء عند حساب الحجم الإجمالي
    }
  }
  if (totalBytes > 1024 * 1024) {
    return '${(totalBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  } else if (totalBytes > 1024) {
    return '${(totalBytes / 1024).toStringAsFixed(1)} KB';
  }
  return '$totalBytes B';
}

Widget _buildProcessingOverlay() {
  return Container(
    color: Colors.black.withValues(alpha: 0.3),
    child: const Center(
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder( // ✅ إزالة const
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                color: Color(0xFF5235C5),
              ),
              SizedBox(height: 16),
              Text(
                'Processing files...',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A2E),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
}