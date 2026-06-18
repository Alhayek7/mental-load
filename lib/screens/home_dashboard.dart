// ============================================================
// 📄 lib/screens/home_dashboard.dart
// ============================================================

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  bool _isLoading = true;
  Map<String, dynamic>? _userData;
  Map<String, dynamic>? _latestCheckin;
  List<Map<String, dynamic>> _recentCheckins = [];
  String _greeting = '';
  String _userName = 'User';
  int _currentIndex = 0;
  bool _isGuest = false;

  @override
  void initState() {
    super.initState();
    _setGreeting();
    _loadData();
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
    if (mounted) setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      _isGuest = prefs.getBool('isGuest') ?? false;

      if (_isGuest) {
        _userName = 'Guest';
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      final user = _supabaseService.currentUser;
      if (user == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      // جلب اسم المستخدم من SharedPreferences
      final storedUser = prefs.getString('loggedInUser') ?? '';
      if (storedUser.isNotEmpty) {
        final parts = storedUser.split('@');
        _userName = parts[0].isNotEmpty ? parts[0] : 'User';
      }

      // جلب البيانات من Supabase مع timeout
      final results = await Future.wait([
        _supabaseService.getUserData(user.id).timeout(const Duration(seconds: 5)),
        _supabaseService.getRecentCheckins(user.id, limit: 1).timeout(const Duration(seconds: 5)),
        _supabaseService.getRecentCheckins(user.id, limit: 3).timeout(const Duration(seconds: 5)),
      ]).catchError((e) {
        debugPrint('Error loading dashboard: $e');
        return [null, <Map<String, dynamic>>[], <Map<String, dynamic>>[]];
      });

      if (mounted) {
        setState(() {
          _userData = results[0] as Map<String, dynamic>?;
          final checkins1 = results[1] as List<Map<String, dynamic>>;
          final checkins3 = results[2] as List<Map<String, dynamic>>;
          _latestCheckin = checkins1.isNotEmpty ? checkins1.first : null;
          _recentCheckins = checkins3;
        });
      }
    } catch (e) {
      debugPrint('Error loading dashboard: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ البيانات تُمرَّر مباشرة لـ _DashboardContent
    final pages = [
      _DashboardContent(
        userData: _userData,
        latestCheckin: _latestCheckin,
        recentCheckins: _recentCheckins,
        userName: _userName,
        greeting: _greeting,
        isGuest: _isGuest,
        onRefresh: _loadData,
      ),
      const InsightsScreen(),
      const HistoryScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FF),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF5E35B1)),
            )
          : IndexedStack(index: _currentIndex, children: pages),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

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
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.insights), label: 'Insights'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Settings'),
        ],
      ),
    );
  }
}

// ============================================================
// 📄 _DashboardContent - يستقبل البيانات من HomeDashboard
// ============================================================
class _DashboardContent extends StatelessWidget {
  final Map<String, dynamic>? userData;
  final Map<String, dynamic>? latestCheckin;
  final List<Map<String, dynamic>> recentCheckins;
  final String userName;
  final String greeting;
  final bool isGuest;
  final VoidCallback onRefresh;

  const _DashboardContent({
    required this.userData,
    required this.latestCheckin,
    required this.recentCheckins,
    required this.userName,
    required this.greeting,
    required this.isGuest,
    required this.onRefresh,
  });

  // ============================================================
  // Helpers
  // ============================================================
  bool get _hasCheckin => latestCheckin != null;
  int get _latestScore => latestCheckin?['cognitive_load_score'] ?? 0;
  String get _scoreLabel => _getScoreLabel(_latestScore);
  Color get _scoreColor => _getScoreColor(_latestScore);

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
    final count = userData?['total_checkins'] ?? 0;
    if (count > 5) return 'Intensive AI User';
    if (count > 2) return 'Regular AI User';
    return 'Casual AI User';
  }

  String _getProfileDescription() {
    final count = userData?['total_checkins'] ?? 0;
    if (count > 10) return 'You rely heavily on AI tools for complex tasks and decision-making.';
    if (count > 5) return 'You regularly use AI tools for daily tasks and productivity.';
    return 'Complete more check-ins to unlock deeper insights about your AI usage.';
  }

  String _getRecommendation() {
    if (!_hasCheckin) return 'Start a check-in to get personalized recommendations.';
    if (_latestScore >= 4) return 'High cognitive load detected. Take a 20-minute break, reduce AI tools to 1-2, and practice deep breathing.';
    if (_latestScore == 3) return 'Moderate load detected. Consider a 10-minute break and limit AI tools to 2 per session.';
    return 'You\'re doing great! Keep up your current habits and maintain this balance.';
  }

  String _formatCheckinDate() {
    if (!_hasCheckin) return 'No check-in recorded yet';
    final raw = latestCheckin?['checkin_date'];
    if (raw == null) return 'Unknown date';
    try {
      final date = DateTime.parse(raw.toString());
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final checkinDay = DateTime(date.year, date.month, date.day);
      final diff = today.difference(checkinDay).inDays;
      final time = '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
      if (diff == 0) return 'Today at $time';
      if (diff == 1) return 'Yesterday at $time';
      return '${date.day}/${date.month}/${date.year} at $time';
    } catch (_) {
      return raw.toString();
    }
  }

  // ============================================================
  // Build
  // ============================================================
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async => onRefresh(),
        color: const Color(0xFF5E35B1),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 20),
              _buildStatsRow(),
              const SizedBox(height: 20),
              _buildAIProfileCard(context),
              const SizedBox(height: 16),
              _buildDailyCheckinCard(context),
              const SizedBox(height: 16),
              _buildLatestAnalysisCard(),
              const SizedBox(height: 16),
              _buildTomorrowOutlookCard(),
              const SizedBox(height: 16),
              _buildRecommendationCard(),
              const SizedBox(height: 24),
              _buildRecentActivitySection(),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // Header
  // ============================================================
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Text('👋', style: TextStyle(fontSize: 18)),
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
                    if (!isGuest)
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
                            Icon(Icons.verified, color: Color(0xFF2D6A4F), size: 12),
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
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF8A8A9A).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'Guest',
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF8A8A9A),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  greeting,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF8A8A9A),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
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
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 38, minHeight: 38),
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
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                ),
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
  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.checklist,
            label: 'Check-ins',
            value: userData?['total_checkins']?.toString() ?? '0',
            color: const Color(0xFF5E35B1),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.speed,
            label: 'Current Load',
            value: _hasCheckin ? _latestScore.toString() : '--',
            suffix: _hasCheckin ? '/5' : '',
            color: _hasCheckin ? _scoreColor : const Color(0xFFB0B0BA),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.trending_up,
            label: 'Status',
            value: _hasCheckin ? _scoreLabel : 'No Data',
            color: _hasCheckin ? _scoreColor : const Color(0xFFB0B0BA),
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
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color),
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
  Widget _buildAIProfileCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF5E35B1).withValues(alpha: 0.08)),
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
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
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF5E35B1), Color(0xFF7B2CBF)],
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
                Text(
                  _getProfileDescription(),
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B6B7A),
                    height: 1.5,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 34,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ProfileScreen()),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5E35B1),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                      visualDensity: VisualDensity.compact,
                    ),
                    icon: const Icon(Icons.person_outline, size: 16),
                    label: const Text('View Profile', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF5E35B1).withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF5E35B1).withValues(alpha: 0.08)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                'assets/images/ai_profile.png',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.psychology,
                  size: 40,
                  color: Color(0xFF5E35B1),
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 150.ms);
  }

  // ============================================================
  // Daily Check-in Card
  // ============================================================
  Widget _buildDailyCheckinCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF5E35B1).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF5E35B1).withValues(alpha: 0.15)),
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
                  _hasCheckin
                      ? 'Complete today\'s reflection for an updated analysis.'
                      : 'Start your first check-in today!',
                  style: TextStyle(
                    fontSize: 12,
                    color: const Color(0xFF5E35B1).withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CheckinScreen()),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5E35B1),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Start Check-in', style: TextStyle(fontSize: 13)),
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
            child: const Icon(Icons.checklist, color: Color(0xFF5E35B1), size: 32),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms);
  }

  // ============================================================
  // Latest Analysis Card ✅ ديناميكي كامل
  // ============================================================
  Widget _buildLatestAnalysisCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9E6),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFFFF3D6)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD97706).withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // العنوان + badge الحالة
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Latest Analysis',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFD97706),
                ),
              ),
              if (_hasCheckin)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _scoreColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _scoreColor.withValues(alpha: 0.2)),
                  ),
                  child: Text(
                    _scoreLabel,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: _scoreColor,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Your most recent cognitive load assessment.',
            style: TextStyle(fontSize: 13, color: Color(0xFF6B6B7A)),
          ),
          const SizedBox(height: 14),

          // Score + Level
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFFFF3D6)),
            ),
            child: Row(
              children: [
                // Score
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Score',
                        style: TextStyle(fontSize: 11, color: Color(0xFF8A8A9A)),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            _hasCheckin ? _latestScore.toString() : '--',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: _hasCheckin ? _scoreColor : const Color(0xFFB0B0BA),
                            ),
                          ),
                          Text(
                            ' / 5',
                            style: TextStyle(
                              fontSize: 14,
                              color: _hasCheckin ? _scoreColor.withValues(alpha: 0.6) : const Color(0xFFB0B0BA),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(width: 1, height: 40, color: const Color(0xFFE8E8EE)),
                // Load Level
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Load Level',
                          style: TextStyle(fontSize: 11, color: Color(0xFF8A8A9A)),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _hasCheckin ? _scoreLabel : 'No Data',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _hasCheckin ? _scoreColor : const Color(0xFF8A8A9A),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Progress bar
          if (_hasCheckin) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: _latestScore / 5,
                backgroundColor: const Color(0xFFE8E8EE),
                color: _scoreColor,
                minHeight: 6,
              ),
            ),
          ],

          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.access_time, size: 14, color: Color(0xFF8A8A9A)),
              const SizedBox(width: 4),
              Text(
                _formatCheckinDate(),
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
    final predictedOutlook = _latestScore >= 4 ? 'High' : _latestScore == 3 ? 'Medium' : 'Low';
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
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFEF4444)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFFD6D8)),
                ),
                child: Text(
                  'Predicted: $predictedOutlook',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: outlookColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            predictedOutlook == 'High'
                ? '⚠️ You may experience higher mental fatigue tomorrow. Based on your recent AI usage patterns, your cognitive load is expected to increase.'
                : predictedOutlook == 'Medium'
                    ? '🔶 Your cognitive load is expected to remain moderate. Consider taking breaks to maintain balance.'
                    : '✅ Great news! Your cognitive load is expected to remain low. Keep up the good habits.',
            style: const TextStyle(fontSize: 13, color: Color(0xFF6B6B7A), height: 1.4),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms);
  }

  // ============================================================
  // Recommendation Card
  // ============================================================
  Widget _buildRecommendationCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF0FDF4), Color(0xFFE6F9ED)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF15803D).withValues(alpha: 0.15)),
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
                const Row(
                  children: [
                    Icon(Icons.lightbulb, color: Color(0xFF15803D), size: 20),
                    SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Today\'s Recommendation',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF15803D),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _getRecommendation(),
                  style: const TextStyle(fontSize: 13, color: Color(0xFF2C2C3A), height: 1.5),
                ),
              ],
            ),
          ),
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFF15803D).withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.emoji_objects, color: Color(0xFF15803D), size: 28),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 350.ms);
  }

  // ============================================================
  // Recent Activity
  // ============================================================
  Widget _buildRecentActivitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Activity',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E)),
        ).animate().fadeIn(delay: 400.ms),
        const SizedBox(height: 12),
        _buildRecentActivity(),
      ],
    );
  }

  Widget _buildRecentActivity() {
    if (recentCheckins.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
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
              Text('No check-ins yet', style: TextStyle(fontSize: 14, color: Color(0xFF8A8A9A))),
              SizedBox(height: 4),
              Text('Start your first check-in today!', style: TextStyle(fontSize: 12, color: Color(0xFFB0B0BA))),
            ],
          ),
        ),
      ).animate().fadeIn(delay: 450.ms);
    }

    return Column(
      children: recentCheckins.asMap().entries.map((entry) {
        final index = entry.key;
        final checkin = entry.value;
        final score = checkin['cognitive_load_score'] ?? 0;
        final scoreLabel = _getScoreLabel(score);
        final scoreColor = _getScoreColor(score);

        String dateStr = '';
        try {
          final raw = checkin['checkin_date'];
          if (raw != null) {
            final date = DateTime.parse(raw.toString());
            dateStr = '${date.day}/${date.month}/${date.year}';
          }
        } catch (_) {}

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
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: scoreColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    score.toString(),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: scoreColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$scoreLabel Load — $score/5',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                    if (dateStr.isNotEmpty)
                      Text(
                        dateStr,
                        style: const TextStyle(fontSize: 12, color: Color(0xFF8A8A9A)),
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
                size: 22,
              ),
            ],
          ),
        ).animate().fadeIn(delay: (450 + (index + 1) * 50).ms);
      }).toList(),
    );
  }
}