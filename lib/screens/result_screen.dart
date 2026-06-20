// ============================================================
// 📄 lib/screens/result_screen.dart
// 📌 صفحة عرض النتائج - النسخة النهائية الاحترافية
// ✅ عرض تحليل تفصيلي + توصيات متعددة + إحصائيات
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/supabase_service.dart';
import 'home_dashboard.dart';

class ResultScreen extends StatefulWidget {
  final int cognitiveLoadScore;
  final String recommendation;
  final String freeText;
  final int aiToolsCount;
  final String usagePattern;
  final int focusScore;
  final int confidenceScore;
  final String analysisMode;
  final Map<String, dynamic>? details; // ✅ إضافة التفاصيل

  const ResultScreen({
    super.key,
    required this.cognitiveLoadScore,
    required this.recommendation,
    required this.freeText,
    required this.aiToolsCount,
    required this.usagePattern,
    required this.focusScore,
    this.confidenceScore = 85,
    this.analysisMode = 'local',
    this.details,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  bool _isExpanded = false;

  // ✅ توصيات إضافية بناءً على النتيجة
  List<String> get _additionalRecommendations {
    final score = widget.cognitiveLoadScore;
    final recommendations = <String>[];

    if (score >= 4) {
      recommendations.addAll([
        '🛑 Stop all AI tool usage for 20 minutes',
        '🧘 Practice deep breathing (5-5-5 technique)',
        '🚶 Take a short walk to clear your mind',
        '💧 Hydrate with a glass of water',
      ]);
    } else if (score == 3) {
      recommendations.addAll([
        '⏰ Take a 10-minute break from screens',
        '📉 Reduce AI tools to 2 per session',
        '🎧 Listen to calming music',
      ]);
    } else {
      recommendations.addAll([
        '🌟 Continue your productive habits',
        '💪 Maintain regular breaks',
        '📊 Track your cognitive load consistently',
      ]);
    }

    // ✅ توصيات إضافية حسب العوامل
    if (widget.focusScore >= 4) {
      recommendations.add('🎯 Use the Pomodoro technique: 25 min work, 5 min break');
    }

    if (widget.aiToolsCount >= 4) {
      recommendations.add('🔧 Limit AI tools to 2-3 per session');
    }

    if (widget.usagePattern == 'continuous') {
      recommendations.add('⏳ Switch to intermittent usage: 45 min work, 15 min break');
    }

    return recommendations;
  }

  @override
  Widget build(BuildContext context) {
    final score = widget.cognitiveLoadScore;
    final scoreColor = score <= 2
        ? const Color(0xFF2D6A4F)
        : score == 3
        ? const Color(0xFFF4A261)
        : const Color(0xFFE76F51);
    final scoreLabel = score <= 2
        ? 'Low Cognitive Load'
        : score == 3
        ? 'Moderate Cognitive Load'
        : 'High Cognitive Load';

    // ✅ تحليل تفصيلي من AIService
    final details = widget.details ?? {};
    final factors = (details['factors'] as List<String>?) ?? [];
    final wordCount = details['word_count'] ?? widget.freeText.split(' ').length;
    final sentiment = details['sentiment'] ?? 'Neutral';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 70,
        title: Row(
          children: [
            IconButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeDashboard()),
                  (route) => false,
                );
              },
              icon: const Icon(Icons.arrow_back, color: Color(0xFF5E35B1)),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            const SizedBox(width: 8),
            const Text(
              'Cognitive Load Report',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E)),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ التاريخ
            Text(
              '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year} at ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')} ${DateTime.now().hour >= 12 ? 'pm' : 'am'}',
              style: const TextStyle(fontSize: 13, color: Color(0xFF8A8A9A)),
            ),
            const SizedBox(height: 16),

            // ========== Score Card ==========
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [scoreColor.withValues(alpha: 0.1), Colors.white],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: scoreColor.withValues(alpha: 0.2)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${score}.0 / 5',
                        style: TextStyle(
                          fontSize: 52,
                          fontWeight: FontWeight.bold,
                          color: scoreColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: scoreColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      scoreLabel,
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: scoreColor),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _getScoreDescription(score),
                    style: TextStyle(fontSize: 14, color: const Color(0xFF6B6B7A), height: 1.4),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  // ✅ مصدر التحليل
                  _buildAnalysisSource(),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms).scale(
              begin: const Offset(0.95, 0.95),
              end: const Offset(1.0, 1.0),
            ),

            const SizedBox(height: 24),

            // ========== Detailed Analysis (جديد) ==========
            if (factors.isNotEmpty || wordCount > 0)
              _buildDetailedAnalysis(factors, wordCount, sentiment),

            const SizedBox(height: 24),

            // ========== Analysis Summary ==========
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF5E35B1).withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF5E35B1).withValues(alpha: 0.12)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Analysis Summary',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF5E35B1)),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _getSummaryText(score),
                    style: const TextStyle(fontSize: 14, color: Color(0xFF4A4A5A), height: 1.6),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getDetailedSummary(score),
                    style: const TextStyle(fontSize: 14, color: Color(0xFF4A4A5A), height: 1.6),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 100.ms),

            const SizedBox(height: 24),

            // ========== What We Detected ==========
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE8E8EE)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'What We Detected',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E)),
                  ),
                  const SizedBox(height: 12),
                  _buildDetectionItem(
                    imagePath: 'assets/images/focus_icon.png',
                    title: 'Analytical Fatigue',
                    description: 'Frequent switching between multiple AI tools appears to be increasing mental effort and reducing processing efficiency.',
                    color: const Color(0xFFF4A261),
                  ),
                  const SizedBox(height: 12),
                  _buildDetectionItem(
                    imagePath: 'assets/images/Frame.png',
                    title: 'Reduced Focus',
                    description: 'Extended AI sessions may be affecting your ability to maintain consistent concentration throughout the day.',
                    color: const Color(0xFFE76F51),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 150.ms),

            const SizedBox(height: 24),

            // ========== Main Contributing Factors ==========
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE8E8EE)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Main Contributing Factors',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E)),
                  ),
                  const SizedBox(height: 16),
                  Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildFactorCard(
                              imagePath: 'assets/images/factor1_icon.png',
                              title: 'Tool Switching',
                              description: 'High switching between different AI tools.',
                              color: const Color(0xFF5E35B1),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildFactorCard(
                              imagePath: 'assets/images/factor2_icon.png',
                              title: 'Long Usage',
                              description: 'Extended AI usage without recovery.',
                              color: const Color(0xFFF4A261),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildFactorCard(
                              imagePath: 'assets/images/33.png',
                              title: 'Limited Breaks',
                              description: 'Not enough breaks for mental recovery.',
                              color: const Color(0xFFE76F51),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildFactorCard(
                              imagePath: 'assets/images/factor4_icon.png',
                              title: 'Context Switching',
                              description: 'Frequent transitions between tasks.',
                              color: const Color(0xFF2D6A4F),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 200.ms),

            const SizedBox(height: 24),

            // ========== Personalized Recommendations ==========
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [const Color(0xFF5E35B1).withValues(alpha: 0.1), Colors.white],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF5E35B1).withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Personalized Recommendations',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF5E35B1)),
                  ),
                  const SizedBox(height: 12),
                  // ✅ التوصية الرئيسية
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF5E35B1).withValues(alpha: 0.1)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.lightbulb, color: Color(0xFF5E35B1), size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            widget.recommendation,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // ✅ توصيات إضافية
                  ..._additionalRecommendations.take(4).map((rec) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, size: 16, color: Color(0xFF2D6A4F)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              rec,
                              style: const TextStyle(fontSize: 13, color: Color(0xFF2C2C3A)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )),
                  if (_additionalRecommendations.length > 4)
                    TextButton(
                      onPressed: () => setState(() => _isExpanded = !_isExpanded),
                      child: Text(_isExpanded ? 'Show less' : 'Show more'),
                    ),
                ],
              ),
            ).animate().fadeIn(delay: 150.ms),

            const SizedBox(height: 20),

            // ========== Why This Recommendation? ==========
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFDCFCE7)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.question_mark, color: Color(0xFF15803D), size: 20),
                      const SizedBox(width: 12),
                      const Text(
                        'Why These Recommendations?',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF15803D)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getWhyText(score),
                    style: const TextStyle(fontSize: 13, color: Color(0xFF2C2C3A), height: 1.4),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getWhyAction(score),
                    style: const TextStyle(fontSize: 13, color: Color(0xFF2C2C3A), height: 1.4),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 200.ms),

            const SizedBox(height: 24),

            // ========== Dashboard Button ==========
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const HomeDashboard()),
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5E35B1),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Text(
                  '📊 Go to Dashboard',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ).animate().fadeIn(delay: 250.ms),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ✅ دوال مساعدة للنصوص الوصفية
  // ============================================================
  String _getScoreDescription(int score) {
    if (score <= 2) {
      return 'Your cognitive load today is healthy and balanced. Keep up the good habits!';
    } else if (score == 3) {
      return 'Your cognitive load today is moderate. Consider taking short breaks to maintain balance.';
    } else if (score == 4) {
      return 'Your cognitive load today is elevated. It\'s important to take action to reduce mental strain.';
    } else {
      return 'Your cognitive load today is critically high. Please take immediate steps to rest and recover.';
    }
  }

  String _getSummaryText(int score) {
    if (score <= 2) {
      return 'Based on today\'s reflection, you are managing your cognitive load effectively. Your habits are well balanced.';
    } else if (score == 3) {
      return 'Based on today\'s reflection, your cognitive load is moderate. Some signs of mental strain were detected.';
    } else {
      return 'Based on today\'s reflection, signs of elevated cognitive strain were detected.';
    }
  }

  String _getDetailedSummary(int score) {
    if (score <= 2) {
      return 'The analysis suggests that you are maintaining a healthy balance. Continue your current habits.';
    } else if (score == 3) {
      return 'The analysis suggests that your current AI usage pattern is manageable but could be optimized with regular breaks.';
    } else {
      return 'The analysis suggests that prolonged AI usage and frequent switching between tools may be contributing to increased mental workload and reduced focus.';
    }
  }

  String _getWhyText(int score) {
    if (score <= 2) {
      return 'You are managing your cognitive load effectively. These recommendations help maintain your current balance.';
    } else if (score == 3) {
      return 'Your analysis indicates signs of moderate cognitive load. These recommendations can help optimize your mental performance.';
    } else {
      return 'Your analysis indicates signs of cognitive overload caused by prolonged AI usage and frequent tool switching.';
    }
  }

  String _getWhyAction(int score) {
    if (score <= 2) {
      return 'Continue tracking your cognitive load to maintain this healthy balance.';
    } else if (score == 3) {
      return 'Implementing these recommendations now may help prevent escalation to high cognitive load.';
    } else {
      return 'Taking action now may help prevent further mental strain and improve overall focus.';
    }
  }

  // ============================================================
  // ✅ Analysis Source Widget
  // ============================================================
  Widget _buildAnalysisSource() {
    final isAI = widget.analysisMode == 'ai_model';
    final isOffline = widget.analysisMode == 'offline' ||
        widget.analysisMode == 'offline_fallback' ||
        widget.analysisMode == 'local_fallback';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isAI
            ? const Color(0xFF2D6A4F).withValues(alpha: 0.1)
            : const Color(0xFFF4A261).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isAI
              ? const Color(0xFF2D6A4F).withValues(alpha: 0.2)
              : const Color(0xFFF4A261).withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isAI ? Icons.check_circle : Icons.warning_amber_rounded,
            size: 14,
            color: isAI ? const Color(0xFF2D6A4F) : const Color(0xFFF4A261),
          ),
          const SizedBox(width: 6),
          Text(
            isAI
                ? '✅ Analyzed by AI'
                : isOffline
                ? '⚠️ Analyzed locally (offline mode)'
                : 'ℹ️ Analyzed with fallback',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: isAI ? const Color(0xFF2D6A4F) : const Color(0xFFF4A261),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ✅ Detailed Analysis Widget (جديد)
  // ============================================================
  Widget _buildDetailedAnalysis(List<String> factors, int wordCount, String sentiment) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8E8EE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🔍 Detailed Analysis',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E)),
          ),
          const SizedBox(height: 12),
          // ✅ العوامل المكتشفة
          if (factors.isNotEmpty) ...[
            const Text('Factors Detected:', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            ...factors.map((factor) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: const Color(0xFF5E35B1)),
                  const SizedBox(width: 8),
                  Expanded(child: Text(factor)),
                ],
              ),
            )),
            const SizedBox(height: 12),
          ],
          // ✅ إحصائيات النص
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F7FF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatChip('Words', wordCount.toString()),
                _buildStatChip('Sentiment', sentiment),
                _buildStatChip('Mode', widget.analysisMode),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF8A8A9A))),
          const SizedBox(width: 4),
          Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  // ============================================================
  // ✅ Detection Item
  // ============================================================
  Widget _buildDetectionItem({
    required String imagePath,
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.12)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            imagePath,
            width: 60,
            height: 60,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.analytics, color: color, size: 24),
              );
            },
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 4,
                      height: 20,
                      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      title,
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.only(left: 14),
                  child: Text(
                    description,
                    style: const TextStyle(fontSize: 13, color: Color(0xFF6B6B7A), height: 1.4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ✅ Factor Card
  // ============================================================
  Widget _buildFactorCard({
    required String imagePath,
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Image.asset(
                imagePath,
                width: 30,
                height: 30,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(Icons.circle, color: color, size: 24);
                },
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1A2E),
              height: 1.2,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              fontSize: 10,
              color: Color(0xFF6B6B7A),
              height: 1.3,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}