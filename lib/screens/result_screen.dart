// lib/screens/result_screen.dart
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
    final int confidenceScore;  // ✅ أضف هذا
  final String analysisMode;  // ✅ أضف هذا

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
    
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  
  bool _isAccurate = true;
  int _userCorrection = 3;
  bool _showCorrectionDialog = false;
  bool _isLoading = false;
  String? _followMessage;

  Future<void> _saveCorrection() async {
    final user = _supabaseService.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      final checkins = await _supabaseService.getRecentCheckins(user.id, limit: 1);
      if (checkins.isNotEmpty) {
        final checkinId = checkins.first['id'];
        await _supabaseService.updateCheckinCorrection(
          checkinId: checkinId,
          userCorrection: _userCorrection,
          userAgreement: true,
        );
        
        setState(() {
          _followMessage = '✅ Correction saved! This helps improve future predictions.';
          _isLoading = false;
        });

        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeDashboard()),
            );
          }
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _followMessage = '❌ Failed to save correction. Please try again.';
      });
    }
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

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 70,
        title: Row(
          children: [
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, color: Color(0xFF5E35B1)),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            const SizedBox(width: 8),
            const Text(
              'Cognitive Load Report',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A2E),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // التاريخ
            Text(
              '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year} at ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')} ${DateTime.now().hour >= 12 ? 'pm' : 'am'}',
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF8A8A9A),
              ),
            ),
            const SizedBox(height: 16),

// ========== Score Card ==========
Container(
  padding: const EdgeInsets.all(24),
  decoration: BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        scoreColor.withValues(alpha: 0.1),
        Colors.white,
      ],
    ),
    borderRadius: BorderRadius.circular(24),
    border: Border.all(
      color: scoreColor.withValues(alpha: 0.2),
    ),
  ),
  child: Column(
    children: [
      // التاريخ
      Text(
        '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year} at ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')} ${DateTime.now().hour >= 12 ? 'pm' : 'am'}',
        style: const TextStyle(
          fontSize: 13,
          color: Color(0xFF8A8A9A),
        ),
      ),
      const SizedBox(height: 16),
      // الرقم الكبير
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${score}.0 / 10',
            style: TextStyle(
              fontSize: 52,
              fontWeight: FontWeight.bold,
              color: scoreColor,
            ),
          ),
        ],
      ),
      const SizedBox(height: 8),
      // التصنيف (High Cognitive Load)
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: scoreColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          scoreLabel,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: scoreColor,
          ),
        ),
      ),
      const SizedBox(height: 12),
      // النص الوصفي
      Text(
        'Your cognitive load today is significantly higher than your normal baseline.',
        style: TextStyle(
          fontSize: 14,
          color: const Color(0xFF6B6B7A),
          height: 1.4,
        ),
        textAlign: TextAlign.center,
      ),
    ],
  ),
).animate().fadeIn(duration: 400.ms).scale(
  begin: const Offset(0.95, 0.95),
  end: const Offset(1.0, 1.0),
),

            const SizedBox(height: 24),

           // ========== Analysis Summary ==========
Container(
  padding: const EdgeInsets.all(20),
  decoration: BoxDecoration(
    color: const Color(0xFF5E35B1).withValues(alpha: 0.06),
    borderRadius: BorderRadius.circular(20),
    border: Border.all(
      color: const Color(0xFF5E35B1).withValues(alpha: 0.12),
    ),
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Analysis Summary',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color.fromARGB(255, 102, 19, 197),
        ),
      ),
      const SizedBox(height: 12),
      Text(
        'Based on today\'s reflection, AI usage patterns, and behavioral indicators, signs of elevated cognitive strain were detected.',
        style: const TextStyle(
          fontSize: 14,
          color: Color(0xFF4A4A5A),
          height: 1.6,
        ),
      ),
      const SizedBox(height: 8),
      Text(
        'The analysis suggests that prolonged AI usage and frequent switching between tools may be contributing to increased mental workload and reduced focus.',
        style: const TextStyle(
          fontSize: 14,
          color: Color(0xFF4A4A5A),
          height: 1.6,
        ),
      ),
    ],
  ),
).animate().fadeIn(delay: 100.ms),
            
            const SizedBox(height: 24),

            // What We Detected
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
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1A1A2E),
        ),
      ),
      const SizedBox(height: 12),
      // Analytical Fatigue - برتقالي فاتح
// Analytical Fatigue - صف واحد مع الصورة والنص بجانب بعض
Container(
  padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: const Color.fromARGB(178, 240, 42, 59).withValues(alpha: 0.08),
    borderRadius: BorderRadius.circular(16),
    border: Border.all(
      color: const Color(0xFFF4A261).withValues(alpha: 0.15),
    ),
  ),
  child: Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // الصورة على اليسار
      Image.asset(
        'assets/images/focus_icon.png',
        width: 100,
        height: 100,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF4A261).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.analytics,
              color: Color(0xFFF4A261),
              size: 24,
            ),
          );
        },
      ),
      const SizedBox(width: 12),
      // النص على اليمين
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Analytical Fatigue',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Frequent switching between multiple AI tools appears to be increasing mental effort and reducing processing efficiency.',
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF6B6B7A),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    ],
  ),
),
      const SizedBox(height: 12),
      // Reduced Focus - أحمر فاتح
// Reduced Focus
Container(
  padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: const Color.fromARGB(255, 240, 139, 114).withValues(alpha: 0.08),
    borderRadius: BorderRadius.circular(16),
    border: Border.all(
      color: const Color(0xFFE76F51).withValues(alpha: 0.15),
    ),
  ),
  child: Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      // الصورة على اليسار
      Image.asset(
        'assets/images/Frame.png',
        width: 100,
        height: 100,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: const Color(0xFFE76F51).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.remove_red_eye,
              color: Color(0xFFE76F51),
              size: 40,
            ),
          );
        },
      ),
      const SizedBox(width: 12),
      // النص على اليمين
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Reduced Focus',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Extended AI sessions may be affecting your ability to maintain consistent concentration throughout the day.',
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF6B6B7A),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    ],
  ),
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
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1A1A2E),
        ),
      ),
      const SizedBox(height: 16),
      // صفين وعمودين (Grid 2x2)
      GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        children: [
          // العامل 1
          _buildFactorCard(
            imagePath: 'assets/images/factor1_icon.png',  // ⚠️ استبدل باسم صورتك
            title: 'Frequent Tool Switching',
            description: 'High switching between different AI tools during the same work session.',
            color: const Color(0xFF5E35B1),
          ),
          // العامل 2
          _buildFactorCard(
            imagePath: 'assets/images/factor2_icon.png',  // ⚠️ استبدل باسم صورتك
            title: 'Long Usage Duration',
            description: 'Extended periods of AI usage without sufficient recovery time.',
            color: const Color(0xFFF4A261),
          ),
          // العامل 3
          _buildFactorCard(
            imagePath: 'assets/images/33.png',  // ⚠️ استبدل باسم صورتك
            title: 'Limited Recovery Breaks',
            description: 'Not enough breaks were taken to allow mental recovery.',
            color: const Color(0xFFE76F51),
          ),
          // العامل 4
          _buildFactorCard(
            imagePath: 'assets/images/factor4_icon.png',  // ⚠️ استبدل باسم صورتك
            title: 'High Context Switching',
            description: 'Frequent transitions between tasks, topics, and AI conversations.',
            color: const Color(0xFF2D6A4F),
          ),
        ],
      ),
    ],
  ),
).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: 24),

            // Personalized Recommendation
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF5E35B1).withValues(alpha: 0.1),
                    Colors.white,
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFF5E35B1).withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Personalized Recommendation',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5E35B1),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(
                        Icons.timer_outlined,
                        color: Color(0xFF5E35B1),
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Take a 10-Minute Break',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF5E35B1),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Step away from all AI tools for at least 10 minutes',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B6B7A),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF5E35B1).withValues(alpha: 0.1),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: Color(0xFF5E35B1),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'This recovery period can help reduce mental fatigue, restore attention, and improve decision-making quality.',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF6B6B7A),
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 150.ms),

            const SizedBox(height: 20),

            // Why This Recommendation?
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
                      const Icon(
                        Icons.question_mark,
                        color: Color(0xFF15803D),
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Why This Recommendation?',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF15803D),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your analysis indicates signs of cognitive overload caused by prolonged AI usage and frequent tool switching.',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF2C2C3A),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Taking a short break now may help prevent further mental strain and improve overall focus.',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF2C2C3A),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 200.ms),

            const SizedBox(height: 24),

            // Dashboard Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const HomeDashboard()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5E35B1),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  '📊 Go to Dashboard',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ).animate().fadeIn(delay: 250.ms),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }



Widget _buildFactorCard({
  required String imagePath,
  required String title,
  required String description,
  required Color color,
}) {
  return Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.05),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: color.withValues(alpha: 0.1),
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // ✅ دائرة بنفسجية شفافة خلف الصورة
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: const Color(0xFF5E35B1).withValues(alpha: 0.08),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Image.asset(
              imagePath,
              width: 44,
              height: 44,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.circle,
                    color: color,
                    size: 24,
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A2E),
            height: 1.2,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF6B6B7A),
            height: 1.3,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}
}