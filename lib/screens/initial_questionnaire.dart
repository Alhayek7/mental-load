// lib/screens/initial_questionnaire.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';
import 'home_dashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/sync_service.dart';

class InitialQuestionnaire extends StatefulWidget {
  const InitialQuestionnaire({super.key});

  @override
  State<InitialQuestionnaire> createState() => _InitialQuestionnaireState();
}

class _InitialQuestionnaireState extends State<InitialQuestionnaire> {
  final SupabaseService _supabaseService = SupabaseService();
  final PageController _pageController = PageController();

  int _currentPage = 0;
  bool _isLoading = false;

  // إجابات المستخدم
  List<String> _selectedTools = [];
  String _dailyUsage = '';
  bool? _reliesOnAI;
  int _focusDifficulty = 3;
  String _fatigueTime = '';
  String _peakFatigueTime = '';

  // قائمة الصفحات

@override
void initState() {
  super.initState();
  debugPrint('🔍 Initial Questionnaire started');
  debugPrint('🔍 Selected tools: $_selectedTools');
}

List<Widget> get _pages => [
  _buildWelcomePage(),
  _buildQuestionPage(
    pageIndex: 1,
    title: 'Which AI tools do you use regularly?',
    subtitle: '(Select all that apply)',
    imagePath: 'assets/images/2_WEMAN.png',
    type: 'multi_select',
    options: ['ChatGPT', 'Gemini', 'Claude', 'Microsoft Copilot', 'Perplexity', 'Other'],
  ),
  _buildQuestionPage(
    pageIndex: 2,
    title: 'How much time do you spend using AI tools each day?',
    subtitle: 'Select the range that best fits your daily usage',
    imagePath: 'assets/images/Group.png',
    type: 'single_select',
    options: ['Less than 1 hour', '1 - 2 hours', '2 - 4 hours', '4 - 6 hours', '6 - 8 hours', 'More than 8 hours'],
  ),
  _buildQuestionPage(
    pageIndex: 3,
    title: 'Do you rely on AI tools when making important decisions?',
    subtitle: 'Select one option',
    imagePath: 'assets/images/undraw_investing_uzcu 1.png',
    type: 'yes_no',
  ),
  _buildQuestionPage(
    pageIndex: 4,
    title: 'How difficult is it for you to stay focused while using AI tools?',
    subtitle: 'Rate from 1 to 5',
    imagePath: 'assets/images/undraw_investing_uzcu 1.png',
    type: 'scale',
    min: 1,
    max: 5,
    labels: ['Rarely', 'Sometimes', 'Often', 'Very Often', 'Very Difficult'],
  ),
  _buildQuestionPage(
    pageIndex: 5,
    title: 'How often do you feel mentally fatigued after long AI sessions?',
    subtitle: 'Select the time of day',
    imagePath: 'assets/images/undraw_investing_uzcu 1.png',
    type: 'single_select',
    options: ['Morning', 'Afternoon', 'Evening', 'Late Night'],
  ),
  _buildQuestionPage(
    pageIndex: 6,
    title: 'When do you usually experience the highest level of mental fatigue?',
    subtitle: 'Select the time of day',
    imagePath: 'assets/images/undraw_investing_uzcu 1.png',
    type: 'single_select',
    options: ['Morning', 'Afternoon', 'Evening', 'Late Night'],
  ),
];


  bool get _canProceed {
    switch (_currentPage) {
      case 0:
        return true;
      case 1:
        return _selectedTools.isNotEmpty;
      case 2:
        return _dailyUsage.isNotEmpty;
      case 3:
        return _reliesOnAI != null;
      case 4:
        return true;
      case 5:
        return _fatigueTime.isNotEmpty;
      case 6:
        return _peakFatigueTime.isNotEmpty;
      default:
        return false;
    }
  }

Future<void> _saveAnswers() async {
  setState(() => _isLoading = true);

  final prefs = await SharedPreferences.getInstance();
  final isGuest = prefs.getBool('isGuest') ?? false;

  // قيم افتراضية في حالة Skip
  final tools = _selectedTools.isEmpty ? ['Other'] : _selectedTools;
  final usage = _dailyUsage.isEmpty ? 'Less than 1 hour' : _dailyUsage;
  final relies = _reliesOnAI ?? false;
  final fatigue = _fatigueTime.isEmpty ? 'Evening' : _fatigueTime;
  final peakFatigue = _peakFatigueTime.isEmpty ? 'Evening' : _peakFatigueTime;
  final score = _calculateScore();

  final data = {
    'selected_tools': tools,
    'daily_usage': usage,
    'relies_on_ai': relies,
    'focus_difficulty': _focusDifficulty,
    'mental_fatigue': fatigue,
    'fatigue_time': peakFatigue,
    'cognitive_load_score': score,
    'created_at': DateTime.now().toIso8601String(),
  };

  if (isGuest) {
    // Guest - حفظ محلي فقط
    await prefs.setBool('hasCompletedQuestionnaire', true);
    debugPrint('✅ Guest - saved locally');
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeDashboard()),
      );
    }
    return;
  }

  final user = _supabaseService.currentUser;
  if (user == null) {
    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please login first'),
      backgroundColor: Color(0xFFE76F51)),
    );
    return;
  }

  try {
    // ✅ حاول Supabase أولاً
    data['user_id'] = user.id;
    await _supabaseService.client
        .from('questionnaire_history')
        .insert(data);

    await _supabaseService.client.from('users').upsert({
      'id': user.id,
      'questionnaire_completed': true,
    });

    debugPrint('✅ Saved to Supabase');
  } catch (e) {
    // ❌ فشل الإنترنت - احفظ محلياً
    await SyncService.savePending(data);
    debugPrint('📴 No internet - saved locally for later sync');
  }

  await prefs.setBool('hasCompletedQuestionnaire', true);

  if (mounted) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomeDashboard()),
    );
  }
}

  int _calculateScore() {
    int score = 2;
    if (_selectedTools.length >= 4)
      score += 2;
    else if (_selectedTools.length >= 2)
      score += 1;
    if (_dailyUsage.contains('6') || _dailyUsage.contains('8'))
      score += 2;
    else if (_dailyUsage.contains('4'))
      score += 1;
    score += _focusDifficulty ~/ 2;
    return score.clamp(1, 5);
  }

  @override
  Widget build(BuildContext context) {
    final totalPages = _pages.length;
    final progress = (_currentPage + 1) / totalPages;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FF),
      appBar: AppBar(
        title: const Text(
          'Initial Assessment',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A2E),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _currentPage > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF5E35B1)),
                onPressed: () => _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                ),
              )
            : null,
actions: [
  if (_currentPage > 0)
    TextButton(
      onPressed: () => _saveAnswers(),
      child: const Text(
        'Skip',
        style: TextStyle(fontSize: 14, color: Color(0xFF8A8A9A)),
      ),
    ),
],
      ),
      body: Column(
        children: [
          // شريط التقدم
          if (_currentPage > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_currentPage} / ${totalPages - 1}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF5E35B1),
                        ),
                      ),
                      Text(
                        '${(progress * 100).toInt()}%',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF8A8A9A),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: const Color(0xFFE8E8EE),
                      color: const Color(0xFF5E35B1),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            ),

          // المحتوى
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() => _currentPage = index);
              },
              children: _pages,
            ),
          ),

          // الأزرار السفلية
          _buildBottomButtons(totalPages),
        ],
      ),
    );
  }

  Widget _buildBottomButtons(int totalPages) {
    if (_currentPage == 0) {
      return Container(
        padding: const EdgeInsets.all(24),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              _pageController.nextPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5E35B1),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              'Get Started',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentPage > 1)
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF5E35B1),
                  side: const BorderSide(color: Color(0xFFDEDCFF)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Back'),
              ),
            ),
          if (_currentPage > 1) const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: _canProceed
                  ? () {
                      if (_currentPage < totalPages - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        _saveAnswers();
                      }
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5E35B1),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      _currentPage < totalPages - 1 ? 'Next' : 'Complete',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // ========== صفحات الأسئلة ==========
  Widget _buildWelcomePage() {
    return SingleChildScrollView(
      // ✅ أضف SingleChildScrollView
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // الصورة
          Container(
            width: 180, // ✅ صغر حجم الصورة قليلاً
            height: 180,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.25),
                  Colors.white.withValues(alpha: 0.10),
                ],
              ),
              borderRadius: BorderRadius.circular(40),
              border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(36),
              child: Image.asset(
                'assets/images/undraw_investing_uzcu 1.png',
                width: 160,
                height: 160,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.psychology,
                    size: 70,
                    color: Color(0xFF5E35B1),
                  );
                },
              ),
            ),
          ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),

          const SizedBox(height: 24), // ✅ قلل المسافة

          const Text(
            'Help Us Understand You',
            style: TextStyle(
              fontSize: 24, // ✅ صغر حجم الخط
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A2E),
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 100.ms),

          const SizedBox(height: 12),

          const Text(
            'Before we begin, we\'d like to learn a little about your AI usage habits.\n\nYour answers will help us personalize insights, recommendations, and cognitive load predictions based on your unique usage patterns.\n\nThis assessment takes less than a minute.',
            style: TextStyle(
              fontSize: 14, // ✅ صغر حجم الخط
              color: Color(0xFF6B6B7A),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 200.ms),
        ],
      ),
    );
  }

  Widget _buildQuestionPage({
    required int pageIndex,
    required String title,
    required String subtitle,
    required String imagePath,
    required String type,
    List<String> options = const [],
    int min = 1,
    int max = 5,
    List<String> labels = const [],
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ✅ الصورة (مصغرة)
          Center(
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: 0.25),
                    Colors.white.withValues(alpha: 0.10),
                  ],
                ),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.asset(
                  imagePath,
                  width: 80,
                  height: 80,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.image_not_supported,
                      size: 40,
                      color: Color(0xFF5E35B1),
                    );
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // ✅ العنوان (مصغر)
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 4),

          // ✅ الوصف (مصغر)
          Text(
            subtitle,
            style: const TextStyle(fontSize: 12, color: Color(0xFF8A8A9A)),
          ),
          const SizedBox(height: 12),

          // ✅ المحتوى (بدون Expanded)
          _buildQuestionContent(type, options, min, max, labels),

          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildQuestionContent(
    String type,
    List<String> options,
    int min,
    int max,
    List<String> labels,
  ) {
    switch (type) {
      case 'multi_select':
        return _buildMultiSelect(options);
      case 'single_select':
        return _buildSingleSelect(options);
      case 'yes_no':
        return _buildYesNo();
      case 'scale':
        return _buildScale(min, max, labels);
      default:
        return const SizedBox();
    }
  }

Widget _buildMultiSelect(List<String> options) {
  return Wrap(
    spacing: 10,
    runSpacing: 10,
    children: options.map((option) {
      return ChoiceChip(
        label: Text(option),
        selected: _selectedTools.contains(option),
        onSelected: (selected) {
          setState(() {
            if (selected) {
              if (!_selectedTools.contains(option)) {
                _selectedTools.add(option);
              }
            } else {
              _selectedTools.remove(option);
            }
          });
        },
        selectedColor: const Color(0xFF5E35B1),
        backgroundColor: Colors.white,
        labelStyle: TextStyle(
          color: _selectedTools.contains(option) ? Colors.white : Colors.black,
        ),
        side: BorderSide(
          color: _selectedTools.contains(option) ? const Color(0xFF5E35B1) : Colors.grey.shade300,
          width: 1.5,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      );
    }).toList(),
  );
}

  Widget _buildSingleSelect(List<String> options) {
    debugPrint('🔍 Selected tools: $_selectedTools');
    return Column(
      children: options.map((option) {
        final isSelected =
            _dailyUsage == option ||
            _fatigueTime == option ||
            _peakFatigueTime == option;
        return GestureDetector(
          onTap: () {
            setState(() {
              if (_currentPage == 2) {
                _dailyUsage = option;
              } else if (_currentPage == 5) {
                _fatigueTime = option;
              } else if (_currentPage == 6) {
                _peakFatigueTime = option;
              }
            });
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF5E35B1).withValues(alpha: 0.08)
                  : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF5E35B1)
                    : const Color(0xFFE8E8EE),
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
                const SizedBox(width: 14),
                Text(
                  option,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                    color: isSelected
                        ? const Color(0xFF5E35B1)
                        : const Color(0xFF1A1A2E),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildYesNo() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _reliesOnAI = true),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: _reliesOnAI == true
                    ? const Color(0xFF5E35B1).withValues(alpha: 0.08)
                    : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _reliesOnAI == true
                      ? const Color(0xFF5E35B1)
                      : const Color(0xFFE8E8EE),
                  width: _reliesOnAI == true ? 2 : 1,
                ),
              ),
              child: Center(
                child: Text(
                  'Yes',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: _reliesOnAI == true
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: _reliesOnAI == true
                        ? const Color(0xFF5E35B1)
                        : const Color(0xFF1A1A2E),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _reliesOnAI = false),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: _reliesOnAI == false
                    ? const Color(0xFF5E35B1).withValues(alpha: 0.08)
                    : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _reliesOnAI == false
                      ? const Color(0xFF5E35B1)
                      : const Color(0xFFE8E8EE),
                  width: _reliesOnAI == false ? 2 : 1,
                ),
              ),
              child: Center(
                child: Text(
                  'No',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: _reliesOnAI == false
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: _reliesOnAI == false
                        ? const Color(0xFF5E35B1)
                        : const Color(0xFF1A1A2E),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScale(int min, int max, List<String> labels) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(max - min + 1, (index) {
            final value = min + index;
            return GestureDetector(
              onTap: () => setState(() => _focusDifficulty = value),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _focusDifficulty == value
                      ? const Color(0xFF5E35B1)
                      : Colors.white,
                  border: Border.all(
                    color: _focusDifficulty == value
                        ? const Color(0xFF5E35B1)
                        : const Color(0xFFE8E8EE),
                    width: _focusDifficulty == value ? 2 : 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    value.toString(),
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: _focusDifficulty == value
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: _focusDifficulty == value
                          ? Colors.white
                          : const Color(0xFF1A1A2E),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              labels[0],
              style: const TextStyle(fontSize: 12, color: Color(0xFF8A8A9A)),
            ),
            Text(
              labels[labels.length - 1],
              style: const TextStyle(fontSize: 12, color: Color(0xFF8A8A9A)),
            ),
          ],
        ),
      ],
    );
  }
}
