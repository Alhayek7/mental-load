// ============================================================
// 📄 lib/screens/home_dashboard.dart
// ============================================================

import 'dart:convert';
import 'dart:io';
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
import '../services/transcription_service.dart';
import 'pending_recordings_screen.dart';

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

  bool _hasLoadedOnce = false;
  Map<String, dynamic>? _cachedData;
  bool _isOffline = false;

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

  // ✅ التحقق من الإنترنت
  Future<bool> _hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  // ✅ حفظ البيانات في SharedPreferences
  Future<void> _saveToCache(Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('cached_home_data', jsonEncode(data));
      _cachedData = data;
      debugPrint('💾 Home data saved to cache');
    } catch (e) {
      debugPrint('⚠️ Cache save failed: $e');
    }
  }

  // ✅ تحميل البيانات من SharedPreferences
  Future<Map<String, dynamic>?> _loadFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString('cached_home_data');
      if (cached != null) {
        final data = jsonDecode(cached) as Map<String, dynamic>;
        _cachedData = data;
        debugPrint('✅ Home data loaded from cache');
        return data;
      }
    } catch (e) {
      debugPrint('⚠️ Cache load failed: $e');
    }
    return null;
  }

  Future<void> _loadData() async {
    if (mounted) setState(() => _isLoading = true);

    try {
      // ✅ 1. عرض البيانات المخزنة فوراً إذا لم تكن محملة من قبل
      if (!_hasLoadedOnce) {
        final cachedData = await _loadFromCache();
        if (cachedData != null) {
          if (mounted) {
            setState(() {
              _userData = cachedData['userData'];
              _latestCheckin = cachedData['latestCheckin'];
              _recentCheckins =
                  cachedData['recentCheckins']?.cast<Map<String, dynamic>>() ??
                  [];
              _isLoading = false;
              _hasLoadedOnce = true;
            });
          }
        }
      }

      // ✅ 2. التحقق من الإنترنت
      final hasInternet = await _hasInternetConnection();

      // ✅ 3. إذا لا يوجد إنترنت، استخدم البيانات المخزنة فقط
      if (!hasInternet) {
        debugPrint('📴 No internet - using cached data');
        if (mounted) {
          setState(() {
            _isLoading = false;
            _isOffline = true;
          });
        }
        return;
      }

      // ✅ 4. إذا كان هناك إنترنت، قم بتحديث البيانات
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

      // ✅ 5. جلب البيانات من Supabase مع timeout
      final results =
          await Future.wait([
            _supabaseService
                .getUserData(user.id)
                .timeout(const Duration(seconds: 5)),
            _supabaseService
                .getRecentCheckins(user.id, limit: 1)
                .timeout(const Duration(seconds: 5)),
            _supabaseService
                .getRecentCheckins(user.id, limit: 3)
                .timeout(const Duration(seconds: 5)),
          ]).catchError((e) {
            debugPrint('Error loading dashboard: $e');
            return [null, <dynamic>[], <dynamic>[]];
          });

      if (mounted) {
        final userData = results[0] as Map<String, dynamic>?;

        // ✅ تحويل آمن لـ List<dynamic> إلى List<Map<String, dynamic>>
        final checkins1 = (results[1] as List<dynamic>)
            .cast<Map<String, dynamic>>();
        final checkins3 = (results[2] as List<dynamic>)
            .cast<Map<String, dynamic>>();

        final latestCheckin = checkins1.isNotEmpty ? checkins1.first : null;
        final recentCheckins = checkins3;

        // ✅ 6. حفظ البيانات في Cache
        await _saveToCache({
          'userData': userData,
          'latestCheckin': latestCheckin,
          'recentCheckins': recentCheckins,
        });

        setState(() {
          _userData = userData;
          _latestCheckin = latestCheckin;
          _recentCheckins = recentCheckins;
          _isLoading = false;
          _hasLoadedOnce = true;
          _isOffline = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading dashboard: $e');

      // ✅ 7. في حالة الخطأ، استخدم البيانات المخزنة
      if (_cachedData != null) {
        setState(() {
          _userData = _cachedData?['userData'];
          _latestCheckin = _cachedData?['latestCheckin'];
          _recentCheckins =
              _cachedData?['recentCheckins']?.cast<Map<String, dynamic>>() ??
              [];
          _isLoading = false;
          _isOffline = true;
        });
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _DashboardContent(
        userData: _userData,
        latestCheckin: _latestCheckin,
        recentCheckins: _recentCheckins,
        userName: _userName,
        greeting: _greeting,
        isGuest: _isGuest,
        isOffline: _isOffline, // ✅ تمرير حالة الإنترنت
        onRefresh: _loadData,
      ),
      const InsightsScreen(),
      const HistoryScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FF),
      body: _isLoading && !_hasLoadedOnce
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
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.insights),
            label: 'Insights',
          ),
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
  final bool isOffline; // ✅ جديد

  final VoidCallback onRefresh;

  const _DashboardContent({
    required this.userData,
    required this.latestCheckin,
    required this.recentCheckins,
    required this.userName,
    required this.greeting,
    required this.isGuest,
    required this.isOffline, // ✅ جديد

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
    if (count > 10)
      return 'You rely heavily on AI tools for complex tasks and decision-making.';
    if (count > 5)
      return 'You regularly use AI tools for daily tasks and productivity.';
    return 'Complete more check-ins to unlock deeper insights about your AI usage.';
  }

  String _getRecommendation() {
    if (!_hasCheckin)
      return 'Start a check-in to get personalized recommendations.';
    if (_latestScore >= 4)
      return 'High cognitive load detected. Take a 20-minute break, reduce AI tools to 1-2, and practice deep breathing.';
    if (_latestScore == 3)
      return 'Moderate load detected. Consider a 10-minute break and limit AI tools to 2 per session.';
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
      final time =
          '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
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
      child: Column(
        children: [
          // ✅ رسالة عدم وجود إنترنت
          if (isOffline)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFE76F51).withValues(alpha: 0.1),
                border: Border(
                  bottom: BorderSide(
                    color: const Color(0xFFE76F51).withValues(alpha: 0.2),
                  ),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.wifi_off_rounded,
                    color: Color(0xFFE76F51),
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '📴 Offline - Showing cached data',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFE76F51),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE76F51).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Cached',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFE76F51),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          // ✅ باقي المحتوى
          Expanded(
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

                    // ✅ إضافة مؤشر الملفات المعلقة (جديد)
                    _buildPendingIndicator(),

                    const SizedBox(height: 24),
                    _buildRecentActivitySection(),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ),
        ],
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFF2D6A4F,
                          ).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(
                              0xFF2D6A4F,
                            ).withValues(alpha: 0.15),
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
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFF8A8A9A,
                          ).withValues(alpha: 0.12),
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
                        MaterialPageRoute(
                          builder: (_) => const NotificationsScreen(),
                        ),
                      ),
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
  Widget _buildAIProfileCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF5E35B1).withValues(alpha: 0.08),
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 3,
                      ),
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
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                      visualDensity: VisualDensity.compact,
                    ),
                    icon: const Icon(Icons.person_outline, size: 16),
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
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF5E35B1).withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF5E35B1).withValues(alpha: 0.08),
              ),
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
    final hasCheckin = _hasCheckin;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF5E35B1).withValues(alpha: 0.12),
            const Color(0xFF7B2CBF).withValues(alpha: 0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF5E35B1).withValues(alpha: 0.15),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5E35B1).withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ العنوان
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF5E35B1).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.checklist_rounded,
                  color: Color(0xFF5E35B1),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Daily Check-in',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              const Spacer(),
              // ✅ Badge "Today" (إذا كان هناك Check-in)
              if (hasCheckin)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2D6A4F).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF2D6A4F).withValues(alpha: 0.2),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 12,
                        color: Color(0xFF2D6A4F),
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Done Today',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2D6A4F),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),

          // ✅ الوصف
          Text(
            hasCheckin
                ? 'Complete today\'s reflection for an updated analysis.'
                : 'Start your daily check-in to track your cognitive load.',
            style: TextStyle(
              fontSize: 13,
              color: const Color(0xFF6B6B7A),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),

          // ✅ إحصائيات سريعة
          Row(
            children: [
              _buildMiniStat(
                icon: Icons.timer_outlined,
                label: '2 min',
                color: const Color(0xFF5E35B1),
              ),
              const SizedBox(width: 16),
              _buildMiniStat(
                icon: Icons.analytics_outlined,
                label: 'Get insights',
                color: const Color(0xFF2D6A4F),
              ),
              const SizedBox(width: 16),
              _buildMiniStat(
                icon: Icons.psychology_outlined,
                label: 'Track progress',
                color: const Color(0xFFF4A261),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ============================================================
          // ✅ زر "Start Check-in" مع تأثير نبض مستمر
          // ============================================================
          _PulsingButton(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CheckinScreen()),
              );
            },
          ),

          const SizedBox(height: 8),

          // ✅ نص إضافي
          Center(
            child: Text(
              hasCheckin
                  ? '🔄 Update your check-in for today'
                  : '✨ Start your journey to better mental clarity',
              style: TextStyle(
                fontSize: 11,
                color: const Color(0xFF8A8A9A),
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms);
  }

  // ============================================================
  // ✅ Mini Stat Widget
  // ============================================================
  Widget _buildMiniStat({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF8A8A9A),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // Latest Analysis Card ✅ تصميم احترافي وحيوي 2026
  // ============================================================
  Widget _buildLatestAnalysisCard() {
    return Container(
      padding: const EdgeInsets.all(0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _hasCheckin
              ? [
                  _scoreColor.withValues(alpha: 0.15),
                  _scoreColor.withValues(alpha: 0.05),
                  Colors.white.withValues(alpha: 0.9),
                ]
              : [
                  const Color(0xFFE8E8EE).withValues(alpha: 0.3),
                  Colors.white.withValues(alpha: 0.9),
                ],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: _hasCheckin
              ? _scoreColor.withValues(alpha: 0.2)
              : const Color(0xFFE8E8EE).withValues(alpha: 0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: _hasCheckin
                ? _scoreColor.withValues(alpha: 0.15)
                : Colors.black.withValues(alpha: 0.04),
            blurRadius: 30,
            offset: const Offset(0, 10),
            spreadRadius: -4,
          ),
          BoxShadow(
            color: _hasCheckin
                ? _scoreColor.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.02),
            blurRadius: 16,
            offset: const Offset(0, 4),
            spreadRadius: -6,
          ),
        ],
      ),
      child: Stack(
        children: [
          // ✅ خلفية مزخرفة (حيوية)
          Positioned(
            top: -40,
            right: -40,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    _hasCheckin
                        ? _scoreColor.withValues(alpha: 0.12)
                        : const Color(0xFF5E35B1).withValues(alpha: 0.06),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -20,
            left: -20,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    _hasCheckin
                        ? _scoreColor.withValues(alpha: 0.08)
                        : const Color(0xFF5E35B1).withValues(alpha: 0.04),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // ✅ المحتوى الرئيسي
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ✅ العنوان + badge الحالة (تصميم حيوي)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        // ✅ أيقونة متحركة
                        TweenAnimationBuilder(
                          tween: Tween<double>(begin: 0.8, end: 1.0),
                          duration: const Duration(milliseconds: 800),
                          builder: (context, scale, child) {
                            return Transform.scale(
                              scale: scale,
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: _hasCheckin
                                        ? [
                                            _scoreColor.withValues(alpha: 0.15),
                                            _scoreColor.withValues(alpha: 0.05),
                                          ]
                                        : [
                                            const Color(
                                              0xFF5E35B1,
                                            ).withValues(alpha: 0.1),
                                            const Color(
                                              0xFF5E35B1,
                                            ).withValues(alpha: 0.04),
                                          ],
                                  ),
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: _hasCheckin
                                          ? _scoreColor.withValues(alpha: 0.15)
                                          : const Color(
                                              0xFF5E35B1,
                                            ).withValues(alpha: 0.08),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.analytics_rounded,
                                  color: _hasCheckin
                                      ? _scoreColor
                                      : const Color(0xFF5E35B1),
                                  size: 22,
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Latest Analysis',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1A1A2E),
                                letterSpacing: -0.4,
                              ),
                            ),
                            Text(
                              _hasCheckin
                                  ? 'Updated just now'
                                  : 'No data available',
                              style: TextStyle(
                                fontSize: 11,
                                color: _hasCheckin
                                    ? _scoreColor.withValues(alpha: 0.6)
                                    : const Color(0xFF8A8A9A),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    if (_hasCheckin)
                      // ✅ Badge متحرك
                      TweenAnimationBuilder(
                        tween: Tween<double>(begin: 0.9, end: 1.0),
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeOutBack,
                        builder: (context, scale, child) {
                          return Transform.scale(
                            scale: scale,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    _scoreColor.withValues(alpha: 0.15),
                                    _scoreColor.withValues(alpha: 0.05),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: _scoreColor.withValues(alpha: 0.25),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: _scoreColor.withValues(alpha: 0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _scoreLabel == 'Low'
                                        ? Icons.check_circle_rounded
                                        : _scoreLabel == 'Medium'
                                        ? Icons.info_rounded
                                        : Icons.warning_rounded,
                                    size: 14,
                                    color: _scoreColor,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    _scoreLabel,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: _scoreColor,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
                const SizedBox(height: 18),

                // ✅ Score + Level (تصميم حيوي)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _hasCheckin
                          ? _scoreColor.withValues(alpha: 0.1)
                          : const Color(0xFFE8E8EE).withValues(alpha: 0.5),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // ✅ Score (مع تأثير حيوي)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Score',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF8A8A9A),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  width: 5,
                                  height: 5,
                                  decoration: BoxDecoration(
                                    color: _hasCheckin
                                        ? _scoreColor
                                        : const Color(0xFFB0B0BA),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: _hasCheckin
                                            ? _scoreColor.withValues(alpha: 0.4)
                                            : Colors.transparent,
                                        blurRadius: 6,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 300),
                                  child: Text(
                                    _hasCheckin
                                        ? _latestScore.toString()
                                        : '--',
                                    key: ValueKey(_latestScore),
                                    style: TextStyle(
                                      fontSize: 38,
                                      fontWeight: FontWeight.w800,
                                      color: _hasCheckin
                                          ? _scoreColor
                                          : const Color(0xFFB0B0BA),
                                      letterSpacing: -1,
                                      height: 1,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '/ 5',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: _hasCheckin
                                        ? _scoreColor.withValues(alpha: 0.4)
                                        : const Color(0xFFB0B0BA),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // ✅ الفاصل العمودي
                      Container(
                        width: 1.5,
                        height: 55,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFFE8E8EE).withValues(alpha: 0.8),
                              const Color(0xFFE8E8EE).withValues(alpha: 0.2),
                            ],
                          ),
                        ),
                      ),

                      // ✅ Load Level (مع تأثير حيوي)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Load Level',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF8A8A9A),
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                child: Text(
                                  _hasCheckin ? _scoreLabel : 'No Data',
                                  key: ValueKey(_scoreLabel),
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                    color: _hasCheckin
                                        ? _scoreColor
                                        : const Color(0xFF8A8A9A),
                                    letterSpacing: -0.5,
                                    height: 1,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ✅ Progress bar (مع تأثير حيوي)
                if (_hasCheckin) ...[
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: _latestScore / 5,
                            backgroundColor: const Color(
                              0xFFF0EEF5,
                            ).withValues(alpha: 0.6),
                            color: _scoreColor,
                            minHeight: 8,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _scoreColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _scoreColor.withValues(alpha: 0.15),
                          ),
                        ),
                        child: Text(
                          '${((_latestScore / 5) * 100).toInt()}%',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: _scoreColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 16),

                // ✅ الوقت + إحصائيات سريعة (تصميم حيوي)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // ✅ الوقت
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F7FF),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: const Color(0xFFE8E8EE).withValues(alpha: 0.5),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 14,
                            color: const Color(0xFF8A8A9A),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _formatCheckinDate(),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF6B6B7A),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ✅ أيقونة تنبيه (حيوية)
                    if (_hasCheckin)
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _scoreColor.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _scoreColor.withValues(alpha: 0.1),
                          ),
                        ),
                        child: Icon(
                          _latestScore >= 4
                              ? Icons.notifications_active_rounded
                              : _latestScore == 3
                              ? Icons.notifications_rounded
                              : Icons.notifications_none_rounded,
                          size: 18,
                          color: _scoreColor,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 250.ms);
  }

  // ============================================================
  // Tomorrow's Outlook Card - محسّن بالكامل
  // ============================================================
  Widget _buildTomorrowOutlookCard() {
    final totalCheckins = userData?['total_checkins'] ?? 0;
    final hasEnoughData = totalCheckins >= 3;

    // ✅ إذا لم يكن هناك بيانات كافية، عرض رسالة تشجيعية
    if (!hasEnoughData) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFE8E8EE).withValues(alpha: 0.4),
              const Color(0xFFF8F7FF).withValues(alpha: 0.2),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: const Color(0xFFB0B0BA).withValues(alpha: 0.2),
            style: BorderStyle.solid,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF5E35B1).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.lock_outline,
                color: Color(0xFF5E35B1),
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '🔮 Tomorrow\'s Outlook',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Complete ${3 - totalCheckins} more check-in${3 - totalCheckins > 1 ? 's' : ''} to unlock personalized predictions.',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF6B6B7A),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: totalCheckins / 3,
                      backgroundColor: const Color(0xFFE8E8EE),
                      color: const Color(0xFF5E35B1),
                      minHeight: 4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$totalCheckins / 3 check-ins completed',
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF8A8A9A),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ).animate().fadeIn(delay: 300.ms);
    }

    // ✅ حساب التوقع
    final predictedOutlook = _latestScore >= 4
        ? 'High'
        : _latestScore == 3
        ? 'Medium'
        : 'Low';
    final outlookColor = predictedOutlook == 'High'
        ? const Color(0xFFEF4444)
        : predictedOutlook == 'Medium'
        ? const Color(0xFFF4A261)
        : const Color(0xFF2D6A4F);

    // ✅ النص المناسب للتصنيف (يظهر مرة واحدة فقط)
    final outlookLabel = predictedOutlook == 'High'
        ? '⚠️ High Load Expected'
        : predictedOutlook == 'Medium'
        ? '🔶 Moderate Load Expected'
        : '✅ Low Load Expected';

    final outlookDescription = predictedOutlook == 'High'
        ? 'Based on your recent patterns, you may experience higher mental fatigue tomorrow. Consider reducing AI tools and taking more frequent breaks.'
        : predictedOutlook == 'Medium'
        ? 'Your cognitive load is expected to remain moderate. Short breaks and mindful AI usage will help maintain balance.'
        : 'Great news! Your cognitive load is expected to remain low. Keep up your current habits and stay consistent.';

    final outlookTip = predictedOutlook == 'High'
        ? '💡 Schedule 2-3 short breaks tomorrow and limit AI tools to 2 per session.'
        : predictedOutlook == 'Medium'
        ? '💡 Take a 10-minute break every 2 hours to stay refreshed.'
        : '💡 Maintain your current routine and track your progress.';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [outlookColor.withValues(alpha: 0.08), Colors.white],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: outlookColor.withValues(alpha: 0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: outlookColor.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ الصف الأول: العنوان فقط
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: outlookColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  predictedOutlook == 'High'
                      ? Icons.warning_amber_rounded
                      : predictedOutlook == 'Medium'
                      ? Icons.info_outline
                      : Icons.check_circle_outline,
                  color: outlookColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Tomorrow\'s Outlook',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A2E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // ✅ التصنيف أسفل العنوان (مرة واحدة فقط)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: outlookColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: outlookColor.withValues(alpha: 0.2)),
            ),
            child: Text(
              outlookLabel,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: outlookColor,
              ),
            ),
          ),
          const SizedBox(height: 14),

          // ✅ الوصف الرئيسي
          Text(
            outlookDescription,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF4A4A5A),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),

          // ✅ نصيحة إضافية
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: outlookColor.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: outlookColor.withValues(alpha: 0.1)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.lightbulb_outline,
                  size: 18,
                  color: Color(0xFFF4A261),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    outlookTip,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF4A4A5A),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ✅ معلومات إضافية
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 12,
                    color: Color(0xFF8A8A9A),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$totalCheckins days',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF6B6B7A),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: totalCheckins >= 10
                      ? const Color(0xFF2D6A4F).withValues(alpha: 0.1)
                      : totalCheckins >= 5
                      ? const Color(0xFFF4A261).withValues(alpha: 0.1)
                      : const Color(0xFFE8E8EE),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(
                      totalCheckins >= 10
                          ? Icons.check_circle
                          : totalCheckins >= 5
                          ? Icons.info_outline
                          : Icons.timeline,
                      size: 10,
                      color: totalCheckins >= 10
                          ? const Color(0xFF2D6A4F)
                          : totalCheckins >= 5
                          ? const Color(0xFFF4A261)
                          : const Color(0xFF8A8A9A),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      totalCheckins >= 10
                          ? 'High'
                          : totalCheckins >= 5
                          ? 'Medium'
                          : 'Building...',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: totalCheckins >= 10
                            ? const Color(0xFF2D6A4F)
                            : totalCheckins >= 5
                            ? const Color(0xFFF4A261)
                            : const Color(0xFF8A8A9A),
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFF15803D).withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.emoji_objects,
              color: Color(0xFF15803D),
              size: 28,
            ),
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
              Text(
                'No check-ins yet',
                style: TextStyle(fontSize: 14, color: Color(0xFF8A8A9A)),
              ),
              SizedBox(height: 4),
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
                size: 22,
              ),
            ],
          ),
        ).animate().fadeIn(delay: (450 + (index + 1) * 50).ms);
      }).toList(),
    );
  }

  // ✅ في _DashboardContent، أضف هذا بعد البطاقات
// ============================================================
// ✅ مؤشر الملفات المعلقة
// ============================================================
Widget _buildPendingIndicator() {
  return FutureBuilder<int>(
    future: TranscriptionService().getPendingCount(),
    builder: (context, snapshot) {
      final count = snapshot.data ?? 0;
      if (count == 0) return const SizedBox();
      
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFFF4A261).withValues(alpha: 0.1),
              Colors.white,
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFF4A261).withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF4A261).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.pending,
                color: Color(0xFFF4A261),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$count recording${count > 1 ? 's' : ''} pending',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  Text(
                    'Connect to Wi-Fi to process',
                    style: TextStyle(
                      fontSize: 12,
                      color: const Color(0xFF8A8A9A),
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PendingRecordingsScreen(),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF5235C5), Color(0xFF7B2CBF)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'View',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
}

// ============================================================
// ✅ زر مع تأثير نبض مستمر (Pulse Animation) - Widget منفصل
// ============================================================
class _PulsingButton extends StatefulWidget {
  final VoidCallback onTap;

  const _PulsingButton({required this.onTap});

  @override
  State<_PulsingButton> createState() => _PulsingButtonState();
}

class _PulsingButtonState extends State<_PulsingButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF5E35B1), Color(0xFF7B2CBF)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF5E35B1).withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '✨ Start Check-in',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
                      Text(
                        '⏱️ Takes only 2 minutes',
                        style: TextStyle(fontSize: 11, color: Colors.white70),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
