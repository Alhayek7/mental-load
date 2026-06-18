// ============================================================
// 📄 lib/screens/home_dashboard.dart
// 📌 الصفحة الرئيسية - Dashboard (نسخة محسّنة مع الحفاظ على التصميم)
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../services/supabase_service.dart';
import 'checkin_screen.dart';
import 'profile_screen.dart';
import 'insights_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';
import 'notifications_screen.dart';

// ============================================================
// 🏠 HomeDashboard
// ============================================================
class HomeDashboard extends StatefulWidget {
  const HomeDashboard({super.key});

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard> {
  final SupabaseService _supabaseService = SupabaseService();

  // ============================================================
  // المتغيرات
  // ============================================================
  bool _isLoading = true;
  Map<String, dynamic>? _userData;
  Map<String, dynamic>? _latestCheckin;
  List<Map<String, dynamic>> _recentCheckins = [];
  String _greeting = '';
  int _currentIndex = 0;

  // ============================================================
  // الصفحات (4 صفحات رئيسية)
  // ============================================================
  final List<Widget> _pages = [
    const _DashboardContent(), // 0: Home
    const InsightsScreen(), // 1: Insights (Patterns)
    const HistoryScreen(), // 2: History
    const SettingsScreen(), // 3: Settings
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
    _setGreeting();
  }

  void _setGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      _greeting = 'Good Morning';
    } else if (hour < 17) {
      _greeting = 'Good Afternoon';
    } else {
      _greeting = 'Good Evening';
    }
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final user = _supabaseService.currentUser;
      if (user == null) return;

      final userData = await _supabaseService.getUserData(user.id);
      if (userData != null) {
        _userData = userData;
      }

      final checkins = await _supabaseService.getRecentCheckins(
        user.id,
        limit: 1,
      );
      if (checkins.isNotEmpty) {
        _latestCheckin = checkins.first;
      }

      final recent = await _supabaseService.getRecentCheckins(
        user.id,
        limit: 3,
      );
      _recentCheckins = recent;
    } catch (e) {
      debugPrint('Error loading dashboard: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _getScoreLabel(int score) {
    if (score <= 2) return 'Low';
    if (score == 3) return 'Medium';
    return 'High';
  }

  Color _getScoreColor(int score) {
    if (score <= 2) return const Color(0xFF2D6A4F);
    if (score == 3) return const Color(0xFFF4A261);
    return const Color(0xFFE76F51);
  }

  String _getAIProfile() {
    final toolsCount = _userData?['total_checkins'] ?? 0;
    if (toolsCount > 5) return 'Intensive AI User';
    if (toolsCount > 2) return 'Regular AI User';
    return 'Casual AI User';
  }

  String _getRecommendation() {
    final latestScore = _latestCheckin?['cognitive_load_score'] ?? 0;
    if (latestScore >= 4) {
      return 'High cognitive load detected. Take a 20-minute break, reduce AI tools to 1-2, and practice deep breathing.';
    } else if (latestScore == 3) {
      return 'Moderate cognitive load detected. Consider taking a 10-minute break and reducing AI tools to 2 per session.';
    } else {
      return 'You\'re doing great! Keep up your current habits. Try to maintain this balance.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FF),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF5E35B1)),
            )
          : IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  // ============================================================
  // شريط التنقل السفلي
  // ============================================================
  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: const Color(0xFF5E35B1),
        unselectedItemColor: const Color(0xFF8A8A9A),
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.insights),
            label: 'Insights',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'settings'),
        ],
      ),
    );
  }
}

// ============================================================
// 📄 _DashboardContent - محتوى الصفحة الرئيسية (التصميم الكامل)
// ============================================================
class _DashboardContent extends StatefulWidget {
  const _DashboardContent();

  @override
  State<_DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<_DashboardContent> {
  // سيتم ربط البيانات لاحقاً
  final Map<String, dynamic>? _userData = null;
  final Map<String, dynamic>? _latestCheckin = null;
  final List<Map<String, dynamic>> _recentCheckins = [];
  String _greeting = 'Good Morning';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ========== Header ==========
            _buildHeader('User'),

            const SizedBox(height: 20),

            // ========== Stats Row ==========
            _buildStatsRow(false, 0, 'No Data', const Color(0xFFB0B0BA)),

            const SizedBox(height: 20),

            // ========== Your AI Profile Card ==========
            _buildAIProfileCard('User'),

            const SizedBox(height: 16),

            // ========== Daily Check-in Card ==========
            _buildDailyCheckinCard(false),

            const SizedBox(height: 16),

            // ========== Latest Analysis Card ==========
            _buildLatestAnalysisCard(
              false,
              0,
              'No Data',
              const Color(0xFFB0B0BA),
            ),

            const SizedBox(height: 16),

            // ========== Tomorrow's Outlook Card ==========
            _buildTomorrowOutlookCard(),

            const SizedBox(height: 16),

            // ========== Today's Recommendation Card ==========
            _buildRecommendationCard(),

            const SizedBox(height: 24),

            // ========== Recent Activity ==========
            _buildRecentActivitySection(),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // Header
  // ============================================================
Widget _buildHeader(String userName) {
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // ✅ الجزء الأيسر: الترحيب والاسم
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // ✅ الصف الأول: الاسم مع أيقونة التحقق
              Row(
                children: [
                  Text(
                    '👋',  // ✅ أيقونة ترحيب
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      userName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A2E),
                        letterSpacing: -0.3,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2D6A4F).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0xFF2D6A4F).withValues(alpha: 0.15),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.verified,
                          color: Color(0xFF2D6A4F),
                          size: 12,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Verified',
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2D6A4F),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              // ✅ الصف الثاني: الحالة
              const Text(
                'How are you feeling today?',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF8A8A9A),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        
        // ✅ الجزء الأيمن: الأيقونات
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 🔔 Notifications
            Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NotificationsScreen(),
                        ),
                      );
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 38,
                      minHeight: 38,
                    ),
                    icon: const Icon(
                      Icons.notifications_outlined,
                      color: Color(0xFF5E35B1),
                      size: 20,
                    ),
                  ),
                ),
                Positioned(
                  right: 3,
                  top: 3,
                  child: Container(
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE76F51),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 6),
            
            // 👤 Avatar
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                );
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF5E35B1), Color(0xFF7B2CBF)],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF5E35B1).withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  ).animate().fadeIn(duration: 400.ms);
}

  // ============================================================
  // Stats Row
  // ============================================================
  Widget _buildStatsRow(
    bool hasCheckin,
    int latestScore,
    String scoreLabel,
    Color scoreColor,
  ) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.checklist,
            label: 'Check-ins',
            value: _userData?['total_checkins']?.toString() ?? '0',
            color: const Color(0xFF5E35B1),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.speed,
            label: 'Current Load',
            value: hasCheckin ? latestScore.toString() : '--',
            suffix: hasCheckin ? '/5' : '',
            color: hasCheckin ? scoreColor : const Color(0xFFB0B0BA),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.trending_up,
            label: 'Status',
            value: hasCheckin ? scoreLabel : 'No Data',
            color: hasCheckin ? scoreColor : const Color(0xFFB0B0BA),
            isText: true,
          ),
        ),
      ],
    ).animate().fadeIn(delay: 100.ms);
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    String suffix = '',
    required Color color,
    bool isText = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8E8EE)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 22, color: color),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: Color(0xFF8A8A9A),
            ),
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: isText ? 14 : 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              if (suffix.isNotEmpty)
                Text(
                  suffix,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // AI Profile Card
  // ============================================================
Widget _buildAIProfileCard(String userName) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.9),
          const Color(0xFFF8F7FF).withValues(alpha: 0.6),
        ],
      ),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: const Color(0xFF5E35B1).withValues(alpha: 0.08),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // ✅ الجزء الأيسر: المعلومات
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // ✅ الصف الأول: العنوان + التصنيف
              Wrap(
                spacing: 8,
                runSpacing: 4,
                alignment: WrapAlignment.start,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  const Text(
                    'AI Profile',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF5E35B1),
                          const Color(0xFF7B2CBF),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getAIProfile(),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // ✅ الوصف
              Text(
                _getProfileDescription(),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF6B6B7A),
                  height: 1.5,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              // ✅ زر View Profile
              SizedBox(
                height: 34,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProfileScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5E35B1),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 0,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                    visualDensity: VisualDensity.compact,
                  ),
                  icon: const Icon(
                    Icons.person_outline,
                    size: 16,
                  ),
                  label: const Text(
                    'View Profile',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        // ✅ الجزء الأيمن: صورة AI Profile
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF5E35B1).withValues(alpha: 0.08),
                const Color(0xFF7B2CBF).withValues(alpha: 0.04),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF5E35B1).withValues(alpha: 0.08),
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              'assets/images/ai_profile.png',  // ✅ استخدم اسم الصورة الخاصة بك
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                // ✅ في حال عدم وجود الصورة، عرض الأيقونة كبديل
                return const Icon(
                  Icons.psychology,
                  size: 40,
                  color: Color(0xFF5E35B1),
                );
              },
            ),
          ),
        ),
      ],
    ),
  ).animate().fadeIn(delay: 150.ms);
}

String _getAIProfile() {
  final toolsCount = _userData?['total_checkins'] ?? 0;
  if (toolsCount > 5) return 'Intensive AI User';
  if (toolsCount > 2) return 'Regular AI User';
  return 'Casual AI User';
}

String _getProfileDescription() {
  final totalCheckins = _userData?['total_checkins'] ?? 0;
  if (totalCheckins > 10) {
    return 'You\'re an intensive AI user. You rely heavily on AI tools for complex tasks and decision-making.';
  } else if (totalCheckins > 5) {
    return 'You regularly use AI tools for daily tasks and productivity enhancements.';
  } else {
    return 'You occasionally use AI tools. Complete more check-ins to see deeper insights.';
  }
}
  // ============================================================
  // Daily Check-in Card
  // ============================================================
  Widget _buildDailyCheckinCard(bool hasCheckin) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF5E35B1).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF5E35B1).withValues(alpha: 0.15),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5E35B1).withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Daily Check-in',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5E35B1),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  hasCheckin
                      ? 'Complete today\'s reflection to receive an updated cognitive load analysis.'
                      : 'Start your first check-in today!',
                  style: TextStyle(
                    fontSize: 12,
                    color: const Color(0xFF5E35B1).withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CheckinScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5E35B1),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Start Daily Check-in',
                        style: TextStyle(fontSize: 13),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.arrow_forward, size: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFF5E35B1).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.checklist,
              color: Color(0xFF5E35B1),
              size: 32,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms);
  }

  // ============================================================
  // Latest Analysis Card
  // ============================================================
  Widget _buildLatestAnalysisCard(
    bool hasCheckin,
    int latestScore,
    String scoreLabel,
    Color scoreColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9E6),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFFFF3D6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Latest Analysis',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFFD97706),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Your most recent cognitive load assessment.',
            style: TextStyle(fontSize: 13, color: Color(0xFF6B6B7A)),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFFF3D6)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text(
                      'Score: ',
                      style: TextStyle(fontSize: 13, color: Color(0xFF8A8A9A)),
                    ),
                    Text(
                      hasCheckin ? '$latestScore / 5' : '-- / 5',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: hasCheckin
                            ? scoreColor
                            : const Color(0xFFB0B0BA),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Text(
                      'Load Level: ',
                      style: TextStyle(fontSize: 13, color: Color(0xFF8A8A9A)),
                    ),
                    Text(
                      hasCheckin ? scoreLabel : 'No Data',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: hasCheckin
                            ? scoreColor
                            : const Color(0xFF8A8A9A),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.access_time, size: 14, color: Color(0xFF8A8A9A)),
              const SizedBox(width: 4),
              Text(
                hasCheckin
                    ? 'Completed: Today, 10:30 AM'
                    : 'No check-in recorded yet',
                style: const TextStyle(fontSize: 12, color: Color(0xFF6B6B7A)),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 250.ms);
  }

  // ============================================================
  // Tomorrow's Outlook Card
  // ============================================================
  Widget _buildTomorrowOutlookCard() {
    final latestScore = _latestCheckin?['cognitive_load_score'] ?? 0;
    final predictedOutlook = latestScore >= 4
        ? 'High'
        : latestScore == 3
        ? 'Medium'
        : 'Low';
    final outlookColor = predictedOutlook == 'High'
        ? const Color(0xFFEF4444)
        : predictedOutlook == 'Medium'
        ? const Color(0xFFF4A261)
        : const Color(0xFF2D6A4F);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE4E6),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFFFD6D8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tomorrow\'s Outlook',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFEF4444),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFFD6D8)),
                ),
                child: Text(
                  'Predicted: $predictedOutlook',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: outlookColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            predictedOutlook == 'High'
                ? '⚠️ You may experience higher mental fatigue tomorrow. Based on your recent AI usage patterns, your cognitive load is expected to increase.'
                : predictedOutlook == 'Medium'
                ? 'Your cognitive load is expected to remain moderate. Consider taking breaks to maintain balance.'
                : 'Great news! Your cognitive load is expected to remain low. Keep up the good habits.',
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF6B6B7A),
              height: 1.4,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms);
  }

  // ============================================================
  // Recommendation Card
  // ============================================================
  Widget _buildRecommendationCard() {
    final hasCheckin = _latestCheckin != null;
    final recommendation = _getRecommendation();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF0FDF4), Color(0xFFE6F9ED)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF15803D).withValues(alpha: 0.15),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF15803D).withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.lightbulb,
                      color: Color(0xFF15803D),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Today\'s Recommendation',
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
                  hasCheckin
                      ? recommendation
                      : 'Start a check-in to get personalized recommendations.',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF2C2C3A),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFF15803D).withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.emoji_objects,
              color: Color(0xFF15803D),
              size: 32,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 350.ms);
  }

  String _getRecommendation() {
    final latestScore = _latestCheckin?['cognitive_load_score'] ?? 0;
    if (latestScore >= 4) {
      return 'High cognitive load detected. Take a 20-minute break, reduce AI tools to 1-2, and practice deep breathing.';
    } else if (latestScore == 3) {
      return 'Moderate cognitive load detected. Consider taking a 10-minute break and reducing AI tools to 2 per session.';
    } else {
      return 'You\'re doing great! Keep up your current habits. Try to maintain this balance.';
    }
  }

  // ============================================================
  // Recent Activity Section
  // ============================================================
  Widget _buildRecentActivitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Activity',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A2E),
          ),
        ).animate().fadeIn(delay: 400.ms),
        const SizedBox(height: 12),
        _buildRecentActivity(),
      ],
    );
  }

  Widget _buildRecentActivity() {
    if (_recentCheckins.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE8E8EE)),
        ),
        child: const Center(
          child: Column(
            children: [
              Icon(Icons.inbox, size: 48, color: Color(0xFFD1D1D8)),
              SizedBox(height: 8),
              Text(
                'No check-ins yet',
                style: TextStyle(fontSize: 14, color: Color(0xFF8A8A9A)),
              ),
              Text(
                'Start your first check-in today!',
                style: TextStyle(fontSize: 12, color: Color(0xFFB0B0BA)),
              ),
            ],
          ),
        ),
      ).animate().fadeIn(delay: 450.ms);
    }

    return Column(
      children: _recentCheckins.asMap().entries.map((entry) {
        final index = entry.key;
        final checkin = entry.value;
        final score = checkin['cognitive_load_score'] ?? 0;
        final date = DateTime.parse(checkin['checkin_date']);
        final scoreLabel = _getScoreLabel(score);
        final scoreColor = _getScoreColor(score);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE8E8EE)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: scoreColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  scoreLabel,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: scoreColor,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$scoreLabel - $score/5',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                    Text(
                      '${date.day}/${date.month}/${date.year}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF8A8A9A),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                score <= 2
                    ? Icons.check_circle
                    : score == 3
                    ? Icons.info_outline
                    : Icons.warning_amber_rounded,
                color: scoreColor,
              ),
            ],
          ),
        ).animate().fadeIn(delay: (450 + (index + 1) * 50).ms);
      }).toList(),
    );
  }

  String _getScoreLabel(int score) {
    if (score <= 2) return 'Low';
    if (score == 3) return 'Medium';
    return 'High';
  }

  Color _getScoreColor(int score) {
    if (score <= 2) return const Color(0xFF2D6A4F);
    if (score == 3) return const Color(0xFFF4A261);
    return const Color(0xFFE76F51);
  }
}
