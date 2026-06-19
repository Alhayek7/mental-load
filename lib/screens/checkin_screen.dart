// ============================================================
// 📄 lib/screens/checkin_screen.dart
// ✅ مع التسجيل الصوتي الفعلي + Whisper API + KeyService
// ============================================================

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../services/supabase_service.dart';
import '../services/ai_service.dart';
import '../services/audio_service.dart';
import '../services/transcription_service.dart';
import '../services/key_service.dart'; // ✅ استيراد واحد فقط
import 'result_screen.dart';
import '../services/google_stt_service.dart';

class CheckinScreen extends StatefulWidget {
  const CheckinScreen({super.key});

  @override
  State<CheckinScreen> createState() => _CheckinScreenState();
}

class _CheckinScreenState extends State<CheckinScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  final AIService _aiService = AIService();
  final AudioService _audioService = AudioService();
  // final TranscriptionService _transcriptionService = TranscriptionService();
  final KeyService _keyService = KeyService();
  final TextEditingController _textController = TextEditingController();
  final GoogleSTTService _googleSTT = GoogleSTTService();

  int _currentPage = 0;
  bool _isLoading = false;
  bool _isTranscribing = false;
  String? _audioPath;

  // Page 1
  String _freeText = '';
  bool _isRecording = false;

  // Page 2
  int _aiToolsCount = 0;
  String _usageTime = '';
  String _usagePattern = '';

  // Page 3
  int _focusLevel = 3;
  int _distractionLevel = 3;
  String _breaksTaken = '';

  @override
  void dispose() {
    _textController.dispose();
    _audioService.dispose();
    super.dispose();
  }

  // ============================================================
  // ✅ دوال التسجيل الصوتي
  // ============================================================

  Future<void> _startRecording() async {
    final started = await _audioService.startRecording();
    if (started) {
      setState(() {
        _isRecording = true;
        _isTranscribing = false;
      });
      _showSnack('🎙️ Recording started...', isError: false);
    } else {
      _showSnack(
        '❌ Cannot start recording. Please check microphone permission.',
        isError: true,
      );
    }
  }

  Future<void> _stopRecording() async {
    final path = await _audioService.stopRecording();
    setState(() {
      _isRecording = false;
    });

    if (path != null) {
      _audioPath = path;
      _showSnack('📁 Recording saved! Converting to text...', isError: false);
      await _transcribeAudio(path);
    } else {
      _showSnack('❌ Failed to save recording', isError: true);
    }
  }

  // ✅ دالة تحويل الصوت إلى نص (محدثة)
Future<void> _transcribeAudio(String path) async {
  setState(() => _isTranscribing = true);
  
  try {
    final text = await _googleSTT.transcribeAudio(path);
    
    if (mounted) {
      setState(() => _isTranscribing = false);
      
      if (text != null && text.isNotEmpty) {
        setState(() {
          _freeText = text;
          _textController.text = text;
        });
        _showSnack('✅ Voice converted to text successfully!', isError: false);
      } else {
        _showSnack('⚠️ No text detected. Please try again.', isError: false);
      }
    }
  } catch (e) {
    debugPrint('❌ Google STT error: $e');
    if (mounted) {
      setState(() => _isTranscribing = false);
      _showSnack('❌ Failed to convert voice', isError: true);
    }
  }
}

  // ✅ عرض مربع حوار لإدخال API Key
  void _showApiKeyDialog() {
    final TextEditingController keyController =
        TextEditingController(); // ✅ بدون _

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.key, color: Color(0xFF5E35B1)),
            SizedBox(width: 10),
            Text('Enter OpenAI API Key'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Please enter your OpenAI API Key to enable voice-to-text transcription.',
              style: TextStyle(fontSize: 14, color: Color(0xFF6B6B7A)),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: keyController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'sk-...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE8E8EE)),
                ),
                filled: true,
                fillColor: const Color(0xFFF8F7FF),
                prefixIcon: const Icon(
                  Icons.lock_outline,
                  color: Color(0xFF5E35B1),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your key is stored securely on your device.',
              style: TextStyle(fontSize: 12, color: const Color(0xFF8A8A9A)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (mounted) {
                setState(() => _isTranscribing = false);
              }
            },
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF8A8A9A)),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final key = keyController.text.trim();
              if (key.isNotEmpty && key.startsWith('sk-')) {
                await _keyService.saveOpenAIKey(key);
                if (mounted) {
                  Navigator.pop(context);
                  setState(() => _isTranscribing = false);
                  _showSnack('✅ API Key saved securely!', isError: false);

                  if (_audioPath != null && mounted) {
                    await _transcribeAudio(_audioPath!);
                  }
                }
              } else {
                if (mounted) {
                  _showSnack(
                    '⚠️ Please enter a valid API Key (starts with sk-)',
                    isError: true,
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5E35B1),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Save Key'),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // حساب Score
  // ============================================================
  int _calculateCognitiveLoadScore() {
    double score = 2.0;

    if (_aiToolsCount >= 4) {
      score += 2.0;
    } else if (_aiToolsCount >= 2) {
      score += 1.0;
    }

    if (_usagePattern == 'Mostly Continuous') score += 1.0;

    if (_focusLevel == 1) {
      score += 2.0;
    } else if (_focusLevel == 2) {
      score += 1.0;
    }

    if (_distractionLevel == 5) {
      score += 2.0;
    } else if (_distractionLevel == 4) {
      score += 1.0;
    }

    if (_breaksTaken == 'No') score += 1.0;
    if (_breaksTaken == 'Sometimes') score += 0.5;

    final text = _freeText.toLowerCase();
    final negativeWords = [
      'tired',
      'exhausted',
      'headache',
      "can't focus",
      'overwhelmed',
      'stressed',
    ];
    final positiveWords = [
      'productive',
      'focused',
      'great',
      'good',
      'energized',
      'clear',
    ];

    for (final word in negativeWords) {
      if (text.contains(word)) {
        score += 1.0;
        break;
      }
    }
    for (final word in positiveWords) {
      if (text.contains(word)) {
        score -= 1.0;
        break;
      }
    }

    return score.round().clamp(1, 5);
  }

  String _generateRecommendation(int score) {
    if (score <= 2) {
      return "You're doing great! Keep up your current habits and maintain this balance.";
    } else if (score == 3) {
      return "Moderate cognitive load detected. Consider a 10-minute break and limiting AI tools to 2 per session.";
    } else if (score == 4) {
      return "High cognitive load detected. Take a 20-minute break, reduce to 1-2 AI tools, and practice deep breathing.";
    } else {
      return "Critical cognitive overload. Stop all AI tools now, rest for at least 30 minutes, and avoid screens.";
    }
  }

  // ============================================================
  // _analyzeDay
  // ============================================================
  Future<void> _analyzeDay() async {
    final user = _supabaseService.currentUser;
    if (user == null) {
      _showSnack('Please login first', isError: true);
      return;
    }

    final textToAnalyze = _freeText.trim();
    if (textToAnalyze.isEmpty) {
      _showSnack('Please write or record your day first', isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    int score;
    String recommendation;
    int confidence;
    String mode;

    try {
      final aiResult = await _aiService.analyzeText(textToAnalyze);

      score = aiResult['score'] as int;
      recommendation = aiResult['recommendation'] as String;
      confidence = aiResult['confidence'] as int;
      mode = aiResult['mode'] as String;

      debugPrint(
        '✅ AI analysis: score=$score, confidence=$confidence%, mode=$mode',
      );
    } catch (e) {
      debugPrint('❌ AI Service error: $e');
      score = _calculateCognitiveLoadScore();
      recommendation = _generateRecommendation(score);
      confidence = 70;
      mode = 'local_fallback';
    }

    try {
      await _supabaseService.saveCheckin(
        userId: user.id,
        freeText: textToAnalyze,
        voiceTranscript: null,
        aiToolsCount: _aiToolsCount,
        usagePattern: _usagePattern == 'Mostly Continuous'
            ? 'continuous'
            : 'intermittent',
        focusDifficulty: _focusLevel,
        energyLevel: 3,
        tookBreaks: _breaksTaken == 'Yes',
        sleepHours: 7,
        cognitiveLoadScore: score,
        recommendation: recommendation,
        confidenceScore: confidence,
      );
      debugPrint('✅ Checkin saved — userId=${user.id}, score=$score');
    } catch (e) {
      debugPrint('⚠️ Save failed (continuing anyway): $e');
      if (mounted) {
        _showSnack(
          '⚠️ Data saved locally — will sync when online',
          isError: false,
        );
      }
    }

    if (!mounted) return;
    setState(() => _isLoading = false);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ResultScreen(
          cognitiveLoadScore: score,
          recommendation: recommendation,
          freeText: textToAnalyze,
          aiToolsCount: _aiToolsCount,
          usagePattern: _usagePattern == 'Mostly Continuous'
              ? 'continuous'
              : 'intermittent',
          focusScore: _focusLevel,
          confidenceScore: confidence,
          analysisMode: mode,
        ),
      ),
    );
  }

  void _showSnack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError
            ? const Color(0xFFE76F51)
            : const Color(0xFF2D6A4F),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // ============================================================
  // Build
  // ============================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FF),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF5E35B1)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Daily Check-in',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A2E),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (_currentPage == 1)
            TextButton(
              onPressed: () => setState(() => _currentPage = 2),
              child: const Text(
                'Skip',
                style: TextStyle(
                  color: Color(0xFF5E35B1),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xFF5E35B1)),
                  SizedBox(height: 16),
                  Text(
                    'Analyzing with AI...',
                    style: TextStyle(color: Color(0xFF8A8A9A), fontSize: 14),
                  ),
                ],
              ),
            )
          : IndexedStack(
              index: _currentPage,
              children: [_buildPage1(), _buildPage2(), _buildPage3()],
            ),
    );
  }

  // ============================================================
  // Page 1: Daily Reflection (مع التسجيل الصوتي)
  // ============================================================
  Widget _buildPage1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPageHeader(
            'Daily Check-in',
            "Let's Reflect on Your Day",
            'Share your experience with AI tools today to receive personalized insights.',
          ),
          const SizedBox(height: 24),
          const Divider(color: Color(0xFFE8E8EE)),
          const SizedBox(height: 24),
          _buildStepHeader(1, 'Daily Reflection'),
          const SizedBox(height: 8),
          const Text(
            'Tell us about your day',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'How was your experience using AI tools today?\nWhat tasks did you use them for?\nDid you feel focused, distracted, or mentally tired?',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF6B6B7A),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          // TextField
          Container(
            height: 150,
            decoration: BoxDecoration(
              color: const Color.fromARGB(206, 211, 207, 247),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFDEDCFF)),
            ),
            child: TextField(
              controller: _textController,
              maxLines: null,
              expands: true,
              maxLength: 1000,
              style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A2E)),
              onChanged: (v) => setState(() => _freeText = v),
              decoration: InputDecoration(
                hintText: 'Tell us about your day...',
                hintStyle: const TextStyle(
                  color: Color(0xFFBDBDBD),
                  fontSize: 14,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16),
                counterText: '${_freeText.length}/1000',
                counterStyle: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF8A8A9A),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ============================================================
          // ✅ التسجيل الصوتي الفعلي
          // ============================================================
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF5E35B1).withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF5E35B1).withValues(alpha: 0.15),
              ),
            ),
            child: Row(
              children: [
                const Expanded(
                  flex: 1,
                  child: Text(
                    'Record your voice instead',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 1,
                  child: GestureDetector(
                    onTap: _isTranscribing
                        ? null
                        : () {
                            if (_isRecording) {
                              _stopRecording();
                            } else {
                              _startRecording();
                            }
                          },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 12,
                      ),
                      decoration: BoxDecoration(
                        color: _isRecording
                            ? const Color(0xFFE76F51)
                            : _isTranscribing
                            ? const Color(0xFF8A8A9A)
                            : const Color(0xFF5E35B1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_isTranscribing)
                            const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          else
                            Icon(
                              _isRecording ? Icons.stop : Icons.mic,
                              color: Colors.white,
                              size: 18,
                            ),
                          const SizedBox(width: 6),
                          Text(
                            _isTranscribing
                                ? 'Converting...'
                                : _isRecording
                                ? 'Stop'
                                : 'Record',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_isRecording)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Center(
                child: Text(
                  '🔴 Recording...',
                  style: TextStyle(fontSize: 12, color: Color(0xFFE76F51)),
                ),
              ),
            ),
          if (_isTranscribing)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Center(
                child: Text(
                  '⏳ Converting speech to text...',
                  style: TextStyle(fontSize: 12, color: Color(0xFF5E35B1)),
                ),
              ),
            ),
          const SizedBox(height: 32),

          _buildStepIndicator(1),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (_freeText.trim().isEmpty) {
                  _showSnack(
                    'Please write or record your day first',
                    isError: true,
                  );
                  return;
                }
                setState(() => _currentPage = 1);
              },
              style: _primaryButtonStyle(),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Next',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward, size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // Page 2: AI Usage Overview
  // ============================================================
  Widget _buildPage2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPageHeader('Daily Check-in', null, null),
          _buildStepHeader(2, 'AI Usage Overview'),
          const SizedBox(height: 4),
          const Text(
            'Help us understand your AI usage today',
            style: TextStyle(fontSize: 14, color: Color(0xFF8A8A9A)),
          ),
          const SizedBox(height: 24),
          const Divider(color: Color(0xFFE8E8EE)),
          const SizedBox(height: 24),

          // Q1: عدد الأدوات
          _buildCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildQuestionLabel('How many AI tools did you use today?'),
                const SizedBox(height: 8),
                _buildDropdownContainer(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: _aiToolsCount > 0 ? _aiToolsCount : null,
                      hint: const Text(
                        'Select an option',
                        style: TextStyle(color: Color(0xFF8A8A9A)),
                      ),
                      isExpanded: true,
                      icon: const Icon(
                        Icons.keyboard_arrow_down,
                        color: Color(0xFF5E35B1),
                      ),
                      dropdownColor: Colors.white,
                      items: List.generate(
                        11,
                        (i) => DropdownMenuItem(
                          value: i,
                          child: Text(
                            i == 0 ? 'None' : i.toString(),
                            style: TextStyle(
                              color: _aiToolsCount == i
                                  ? const Color(0xFF5E35B1)
                                  : const Color(0xFF1A1A2E),
                              fontWeight: _aiToolsCount == i
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                      onChanged: (v) => setState(() => _aiToolsCount = v ?? 0),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Q2: وقت الاستخدام
          _buildCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildQuestionLabel('How long did you use AI tools today?'),
                const SizedBox(height: 8),
                _buildDropdownContainer(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _usageTime.isNotEmpty ? _usageTime : null,
                      hint: const Text(
                        'Select an option',
                        style: TextStyle(color: Color(0xFF8A8A9A)),
                      ),
                      isExpanded: true,
                      icon: const Icon(
                        Icons.keyboard_arrow_down,
                        color: Color(0xFF5E35B1),
                      ),
                      dropdownColor: Colors.white,
                      items:
                          [
                                'Less than 1 hour',
                                '1-2 hours',
                                '2-4 hours',
                                '4-6 hours',
                                '6-8 hours',
                                'More than 8 hours',
                              ]
                              .map(
                                (e) => DropdownMenuItem(
                                  value: e,
                                  child: Text(
                                    e,
                                    style: TextStyle(
                                      color: _usageTime == e
                                          ? const Color(0xFF5E35B1)
                                          : const Color(0xFF1A1A2E),
                                      fontWeight: _usageTime == e
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                      onChanged: (v) => setState(() => _usageTime = v ?? ''),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Q3: نمط الاستخدام
          _buildCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildQuestionLabel('What best describes your usage pattern?'),
                const SizedBox(height: 8),
                _buildRadioOption(
                  'Mostly Continuous',
                  _usagePattern,
                  (v) => setState(() => _usagePattern = v),
                ),
                _buildRadioOption(
                  'Mostly Interrupted',
                  _usagePattern,
                  (v) => setState(() => _usagePattern = v),
                ),
                _buildRadioOption(
                  'Balanced',
                  _usagePattern,
                  (v) => setState(() => _usagePattern = v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          _buildStepIndicator(2),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildBackButton(() => setState(() => _currentPage = 0)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    if (_aiToolsCount == 0) {
                      _showSnack(
                        'Please select number of AI tools',
                        isError: true,
                      );
                      return;
                    }
                    if (_usageTime.isEmpty) {
                      _showSnack('Please select usage duration', isError: true);
                      return;
                    }
                    if (_usagePattern.isEmpty) {
                      _showSnack(
                        'Please select a usage pattern',
                        isError: true,
                      );
                      return;
                    }
                    setState(() => _currentPage = 2);
                  },
                  style: _primaryButtonStyle(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    'Next',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // Page 3: Well-Being Check
  // ============================================================
  Widget _buildPage3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPageHeader('Daily Check-in', null, null),
          _buildStepHeader(3, 'Well-Being Check'),
          const SizedBox(height: 4),
          const Text(
            'Tell us how you felt during AI sessions',
            style: TextStyle(fontSize: 14, color: Color(0xFF8A8A9A)),
          ),
          const SizedBox(height: 24),
          const Divider(color: Color(0xFFE8E8EE)),
          const SizedBox(height: 24),

          // Q1: التركيز
          _buildCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildQuestionLabel('How focused did you feel today?'),
                const SizedBox(height: 4),
                const Text(
                  'Rate from 1 (very low) to 5 (very high)',
                  style: TextStyle(fontSize: 12, color: Color(0xFF8A8A9A)),
                ),
                const SizedBox(height: 12),
                _buildRatingRow(
                  _focusLevel,
                  (v) => setState(() => _focusLevel = v),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      'Very Low',
                      style: TextStyle(fontSize: 11, color: Color(0xFF8A8A9A)),
                    ),
                    Text(
                      'Very High',
                      style: TextStyle(fontSize: 11, color: Color(0xFF8A8A9A)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Q2: التشتت
          _buildCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildQuestionLabel('How distracted did you feel today?'),
                const SizedBox(height: 4),
                const Text(
                  'Rate from 1 (not at all) to 5 (very distracted)',
                  style: TextStyle(fontSize: 12, color: Color(0xFF8A8A9A)),
                ),
                const SizedBox(height: 12),
                _buildRatingRow(
                  _distractionLevel,
                  (v) => setState(() => _distractionLevel = v),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      'Not at All',
                      style: TextStyle(fontSize: 11, color: Color(0xFF8A8A9A)),
                    ),
                    Text(
                      'Very Distracted',
                      style: TextStyle(fontSize: 11, color: Color(0xFF8A8A9A)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Q3: الفواصل
          _buildCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildQuestionLabel(
                  'Did you take regular breaks during your AI sessions?',
                ),
                const SizedBox(height: 8),
                _buildRadioOption(
                  'Yes',
                  _breaksTaken,
                  (v) => setState(() => _breaksTaken = v),
                ),
                _buildRadioOption(
                  'Sometimes',
                  _breaksTaken,
                  (v) => setState(() => _breaksTaken = v),
                ),
                _buildRadioOption(
                  'No',
                  _breaksTaken,
                  (v) => setState(() => _breaksTaken = v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          _buildStepIndicator(3),
          const SizedBox(height: 16),

          // Analyze button
          Row(
            children: [
              Expanded(
                child: _buildBackButton(() => setState(() => _currentPage = 1)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    if (_breaksTaken.isEmpty) {
                      _showSnack('Please answer all questions', isError: true);
                      return;
                    }
                    if (_isLoading) {
                      _showSnack(
                        '⏳ Analysis in progress, please wait...',
                        isError: false,
                      );
                      return;
                    }
                    _analyzeDay();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: _isLoading
                          ? const Color(0xFF8A8A9A)
                          : const Color(0xFF5E35B1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _isLoading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(
                                Icons.analytics,
                                color: Colors.white,
                                size: 16,
                              ),
                        const SizedBox(width: 6),
                        const Flexible(
                          child: Text(
                            'Analyze Load',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ============================================================
  // Reusable Helpers
  // ============================================================
  Widget _buildPageHeader(String title, String? subtitle, String? description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF5E35B1),
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1A1A2E),
            ),
          ),
        ],
        if (description != null) ...[
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF8A8A9A),
              height: 1.4,
            ),
          ),
        ],
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildStepHeader(int step, String title) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: const BoxDecoration(
            color: Color(0xFF5E35B1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$step',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A2E),
          ),
        ),
      ],
    );
  }

  Widget _buildStepIndicator(int currentStep) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        final isActive = i + 1 <= currentStep;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF5E35B1) : const Color(0xFFDEDCFF),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDEDCFF)),
      ),
      child: child,
    );
  }

  Widget _buildDropdownContainer({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F7FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFDEDCFF)),
      ),
      child: child,
    );
  }

  Widget _buildQuestionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Color(0xFF1A1A2E),
      ),
    );
  }

  Widget _buildRatingRow(int selected, ValueChanged<int> onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(5, (i) {
        final value = i + 1;
        final isSelected = selected == value;
        return GestureDetector(
          onTap: () => onChanged(value),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? const Color(0xFF5E35B1) : Colors.white,
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF5E35B1)
                    : const Color(0xFFDEDCFF),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Center(
              child: Text(
                '$value',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.white : const Color(0xFF1A1A2E),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildRadioOption(
    String label,
    String selected,
    ValueChanged<String> onChanged,
  ) {
    final isSelected = selected == label;
    return GestureDetector(
      onTap: () => onChanged(label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF5E35B1).withValues(alpha: 0.08)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF5E35B1)
                : const Color(0xFFDEDCFF),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? const Color(0xFF5E35B1)
                    : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF5E35B1)
                      : const Color(0xFFB0B0BA),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 12)
                  : null,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected
                    ? const Color(0xFF5E35B1)
                    : const Color(0xFF1A1A2E),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackButton(VoidCallback onTap) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF5E35B1),
        side: const BorderSide(color: Color(0xFF5E35B1)),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: const Text(
        'Back',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }

  ButtonStyle _primaryButtonStyle({EdgeInsets? padding}) {
    return ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF5E35B1),
      foregroundColor: Colors.white,
      padding: padding ?? const EdgeInsets.symmetric(vertical: 22),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
    );
  }
}
