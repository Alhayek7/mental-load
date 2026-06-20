// ============================================================
// 📄 lib/screens/settings_screen.dart
// 📌 صفحة الإعدادات - Settings Screen (مع ميزات إضافية)
// ============================================================

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
// import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';
import 'login_screen.dart';
import '../services/supabase_service.dart';
import 'edit_profile_dialog.dart';
import 'rate_app_screen.dart';
import 'terms_screen.dart';
// import '../widgets/logout_dialog.dart';
import '../widgets/delete_account_dialog.dart';
import 'privacy_policy_screen.dart';
import '../widgets/delete_data_dialog.dart';
import '../widgets/contact_us_dialog.dart';
import 'about_screen.dart';
import 'pending_recordings_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  final SupabaseService _supabaseService = SupabaseService();

  // ============================================================
  // متغيرات البيانات (محسّنة مع Cache)
  // ============================================================
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  bool _isLoggingOut = false;
  String? _errorMessage;

  // ✅ Cache للبيانات لتسريع التحميل
  Map<String, dynamic>? _cachedUserData;
  bool _hasLoadedOnce = false;

  // ✅ متغيرات الميكروفون (جديدة)
  PermissionStatus _microphoneStatus = PermissionStatus.denied;
  bool _isTestingMicrophone = false;
  late AnimationController _micAnimationController;
  late Animation<double> _micPulseAnimation;

  @override
  void initState() {
    super.initState();
    _loadCachedData();
    _loadUserData();
    _checkMicrophoneStatus();

    // ✅ Animation للميكروفون
    _micAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _micPulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _micAnimationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _micAnimationController.dispose();
    super.dispose();
  }

  // ============================================================
  // ✅ 1. تحميل البيانات المخزنة (فوري)
  // ============================================================
  Future<void> _loadCachedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString('cached_user_data');
      if (cached != null) {
        final data = jsonDecode(cached) as Map<String, dynamic>;
        setState(() {
          _userData = data;
          _isLoading = false;
          _hasLoadedOnce = true;
        });
        debugPrint('✅ Settings loaded from cache');
      }
    } catch (e) {
      debugPrint('⚠️ Cache load failed: $e');
    }
  }

  // ============================================================
  // ✅ 2. جلب بيانات المستخدم (محسّن مع Cache)
  // ============================================================
  Future<void> _loadUserData() async {
    // ✅ إذا كانت البيانات موجودة ولا تحتاج تحديث، توقف
    if (_hasLoadedOnce && _cachedUserData != null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final isGuest = prefs.getBool('isGuest') ?? false;

      if (isGuest) {
        final guestData = {
          'full_name': 'Guest',
          'email': 'guest@mentalload.app',
          'total_checkins': 0,
          'avg_cognitive_score': 0.0,
          'last_checkin': null,
          'is_guest': true,
        };
        await _saveToCache(guestData);
        if (mounted) {
          setState(() {
            _userData = guestData;
            _isLoading = false;
            _hasLoadedOnce = true;
          });
        }
        return;
      }

      final user = _supabaseService.currentUser;
      if (user == null) {
        setState(() {
          _errorMessage = 'Please login to view settings';
          _isLoading = false;
        });
        return;
      }

      // ✅ جلب البيانات مع Timeout
      final userData = await _supabaseService
          .getUserData(user.id)
          .timeout(
            const Duration(seconds: 3),
            onTimeout: () => _cachedUserData ?? {},
          );

      if (userData != null && userData.isNotEmpty) {
        await _saveToCache(userData);
        if (mounted) {
          setState(() {
            _userData = userData;
            _isLoading = false;
            _hasLoadedOnce = true;
          });
        }
      }
    } catch (e) {
      debugPrint('❌ Error loading data: $e');
      // ✅ استخدام البيانات المخزنة في حال الفشل
      if (_cachedUserData != null) {
        setState(() {
          _userData = _cachedUserData;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load settings';
          _isLoading = false;
        });
      }
    }
  }

  // ============================================================
  // ✅ 3. حفظ البيانات في Cache
  // ============================================================
  Future<void> _saveToCache(Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('cached_user_data', jsonEncode(data));
      _cachedUserData = data;
    } catch (e) {
      debugPrint('⚠️ Cache save failed: $e');
    }
  }

  // ============================================================
  // ✅ 4. تحديث يدوي (Pull to Refresh)
  // ============================================================
  Future<void> _refreshData() async {
    setState(() => _isLoading = true);
    await _loadUserData();
    await _checkMicrophoneStatus();
    if (mounted) setState(() => _isLoading = false);
  }

  // ============================================================
  // عرض رسالة
  // ============================================================
  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? const Color(0xFFE76F51)
            : const Color(0xFF2D6A4F),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // ============================================================
  // 📧 التواصل معنا
  // ============================================================
  void _contactUs() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => const ContactUsDialog(),
    );
  }

  // ============================================================
  // ⭐ تقييم التطبيق (استخدام الصفحة الداخلية)
  // ============================================================
  void _rateApp() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RateAppScreen()),
    );
  }

  // ============================================================
  // 1️⃣ EDIT PROFILE - تعديل الملف الشخصي
  // ============================================================
  Future<void> _editProfile() async {
    await showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (context) => EditProfileDialog(
        currentName: _userData?['full_name'] ?? '',
        currentEmail: _userData?['email'] ?? '',
        onSave: (newName) {
          _updateProfile(newName);
        },
      ),
    );
  }

  Future<void> _updateProfile(String newName) async {
    setState(() => _isLoading = true);

    try {
      final user = _supabaseService.currentUser;
      if (user == null) throw Exception('User not logged in');

      await _supabaseService.client
          .from('users')
          .update({'full_name': newName})
          .eq('id', user.id);

      await _supabaseService.client.auth.updateUser(
        UserAttributes(data: {'full_name': newName}),
      );

      await _loadUserData();
      _showMessage('✅ Profile updated successfully!');
    } catch (e) {
      debugPrint('❌ Error updating profile: $e');
      setState(() => _isLoading = false);
      _showMessage('Failed to update profile', isError: true);
    }
  }

  // ============================================================
  // 2️⃣ EXPORT DATA - تصدير البيانات بصيغة JSON (محسّنة)
  // ============================================================
  Future<void> _exportData() async {
    final isGuest = _userData?['is_guest'] ?? false;

    if (isGuest) {
      _showTopSnackBar('⚠️ Guest data cannot be exported', isError: true);
      return;
    }

    // ✅ التحقق من الإنترنت أولاً
    final hasInternet = await _hasInternetConnection();
    if (!hasInternet) {
      _showTopSnackBar(
        '📴 No internet connection. Please connect and try again.',
        isError: true,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = _supabaseService.currentUser;
      if (user == null) throw Exception('User not logged in');

      // ✅ محاولة جلب البيانات مع Timeout
      final checkins = await _supabaseService.client
          .from('checkins')
          .select()
          .eq('user_id', user.id)
          .order('checkin_date', ascending: false)
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () {
              throw Exception('Connection timeout');
            },
          );

      final recommendations = await _supabaseService.client
          .from('recommendations_history')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false)
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () {
              throw Exception('Connection timeout');
            },
          );

      final questionnaire = await _supabaseService.client
          .from('questionnaire_history')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false)
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () {
              throw Exception('Connection timeout');
            },
          );

      final exportData = {
        'export_date': DateTime.now().toIso8601String(),
        'user': {
          'id': user.id,
          'email': user.email,
          'full_name': _userData?['full_name'],
          'total_checkins': _userData?['total_checkins'],
          'avg_cognitive_score': _userData?['avg_cognitive_score'],
        },
        'checkins': checkins,
        'recommendations': recommendations,
        'questionnaire_history': questionnaire,
      };

      final jsonString = const JsonEncoder.withIndent('  ').convert(exportData);

      final directory = await getApplicationDocumentsDirectory();
      final fileName =
          'clearload_export_${DateTime.now().millisecondsSinceEpoch}.json';
      final file = File('${directory.path}/$fileName');
      await file.writeAsString(jsonString);

      await Share.shareXFiles([
        XFile(file.path),
      ], text: '📊 Here is my ClearLoad data export.');

      _showTopSnackBar('✅ Data exported successfully!', isError: false);
    } catch (e) {
      debugPrint('❌ Error exporting data: $e');

      if (e.toString().contains('Connection timeout') ||
          e.toString().contains('Failed host lookup')) {
        _showTopSnackBar(
          '📴 Connection timeout. Please check your internet.',
          isError: true,
        );
      } else {
        _showTopSnackBar(
          '❌ Failed to export data: ${e.toString().replaceAll('Exception: ', '')}',
          isError: true,
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ============================================================
  // 3️⃣ PRIVACY POLICY - سياسة الخصوصية
  // ============================================================
  void _showPrivacyPolicy() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PrivacyPolicyScreen()),
    );
  }

  Widget _buildPolicySection({required String title, required String content}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.manrope(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF5235C5),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          content,
          style: GoogleFonts.manrope(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF484554),
            height: 1.5,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // 4️⃣ TERMS OF SERVICE - شروط الخدمة
  // ============================================================
  void _showTermsOfService() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TermsScreen()),
    );
  }

  Widget _buildTermsSection({required String title, required String content}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.manrope(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          content,
          style: GoogleFonts.manrope(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF484554),
            height: 1.5,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // ✅ التحقق من الاتصال بالإنترنت
  // ============================================================
  Future<bool> _hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  // ============================================================
  // تسجيل الخروج (يدعم Guest و المستخدمين المسجلين)
  // ============================================================
  Future<void> _logout() async {
    // ✅ التحقق من حالة Guest
    final bool isGuest = _userData?['is_guest'] ?? false;

    // ✅ استخدام showDialog مباشرة بدلاً من LogoutDialog
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          isGuest ? 'Exit Guest Mode?' : 'Logout?',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          isGuest
              ? 'You will lose any unsaved data. Are you sure you want to exit?'
              : 'Are you sure you want to logout from your account?',
          style: const TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (mounted) {
                Navigator.pop(context, true);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE76F51),
              foregroundColor: Colors.white,
            ),
            child: Text(isGuest ? 'Exit' : 'Logout'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoggingOut = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      if (!isGuest) {
        await _supabaseService.signOut();
      }

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoggingOut = false);
        _showMessage('Failed to logout. Please try again.', isError: true);
      }
    }
  }

  // ============================================================
  // حذف الحساب
  // ============================================================
  Future<void> _deleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => DeleteAccountDialog(
        isLoading: _isLoggingOut,
        onConfirm: () async {
          setState(() => _isLoggingOut = true);

          try {
            await _supabaseService.deleteAccount();

            if (mounted) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            }
          } catch (e) {
            setState(() => _isLoggingOut = false);
            _showMessage(
              'Failed to delete account. Please try again.',
              isError: true,
            );
          }
        },
      ),
    );
  }

  // ============================================================
  // حذف البيانات (Delete My Data)
  // ============================================================
  Future<void> _deleteAllData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => DeleteDataDialog(
        isLoading: _isLoading,
        onConfirm: () async {
          setState(() => _isLoading = true);

          try {
            final user = _supabaseService.currentUser;
            if (user == null) throw Exception('User not logged in');

            await _supabaseService.client
                .from('checkins')
                .delete()
                .eq('user_id', user.id);

            await _supabaseService.client
                .from('recommendations_history')
                .delete()
                .eq('user_id', user.id);

            await _supabaseService.client
                .from('questionnaire_history')
                .delete()
                .eq('user_id', user.id);

            await _supabaseService.client
                .from('users')
                .update({
                  'total_checkins': 0,
                  'avg_cognitive_score': null,
                  'last_checkin': null,
                })
                .eq('id', user.id);

            await _loadUserData();

            if (mounted) {
              Navigator.pop(context);
              _showMessage('All your data has been deleted successfully.');
            }
          } catch (e) {
            debugPrint('❌ Error deleting data: $e');
            if (mounted) {
              setState(() => _isLoading = false);
              _showMessage(
                'Failed to delete data. Please try again.',
                isError: true,
              );
            }
          }
        },
      ),
    );
  }

  // ============================================================
  // البناء الرئيسي
  // ============================================================
  @override
  Widget build(BuildContext context) {
    final fullName = _userData?['full_name'] ?? 'User';
    final email = _userData?['email'] ?? 'user@example.com';
    final totalCheckins = _userData?['total_checkins'] ?? 0;
    final avgScore = _userData?['avg_cognitive_score'] ?? 0.0;

    return Scaffold(
      backgroundColor: const Color(0xFFFCF9F8),
      appBar: _buildAppBar(),
      body: _isLoading && !_hasLoadedOnce
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xFF5235C5)),
                  SizedBox(height: 16),
                  Text(
                    'Loading settings...',
                    style: TextStyle(color: Color(0xFF8A8A9A), fontSize: 14),
                  ),
                ],
              ),
            )
          : _errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: const Color(0xFFE76F51),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _errorMessage!,
                    style: GoogleFonts.manrope(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFFE76F51),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadUserData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5235C5),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildUserProfile(fullName, email, totalCheckins, avgScore),
                  const SizedBox(height: 24),
                  _buildStatsCard(totalCheckins, avgScore),
                  const SizedBox(height: 24),
                  _buildSettingsList(),
                  const SizedBox(height: 24),
                  _buildDangerZone(),
                  const SizedBox(height: 24),
                  _buildAppVersion(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  // ============================================================
  // ✅ App Bar (تصميم احترافي مثل History)
  // ============================================================
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      toolbarHeight: 100,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF5235C5).withValues(alpha: 0.08),
              const Color(0xFF1A5F7A).withValues(alpha: 0.04),
            ],
          ),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
          border: Border(
            bottom: BorderSide(
              color: const Color(0xFF5235C5).withValues(alpha: 0.06),
              width: 1,
            ),
          ),
        ),
      ),
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: Row(
          children: [
            // ✅ أيقونة
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF5235C5), Color(0xFF7B2CBF)],
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF5235C5).withValues(alpha: 0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.settings_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),

            // ✅ النصوص
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Settings',
                    style: GoogleFonts.manrope(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1A1A2E),
                      letterSpacing: -0.3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    children: [
                      Container(
                        width: 4,
                        height: 4,
                        decoration: const BoxDecoration(
                          color: Color(0xFF5235C5),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'Manage your preferences',
                          style: GoogleFonts.manrope(
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF6B6B7A),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ✅ زر التحديث
            // ✅ زر التحديث
            IconButton(
              onPressed: _isLoading
                  ? null
                  : _refreshData, // ✅ استخدام _refreshData
              icon: Icon(
                _isLoading ? Icons.hourglass_empty : Icons.refresh_rounded,
                color: const Color(0xFF5235C5),
                size: 20,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              tooltip: 'Refresh data',
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // User Profile Card
  // ============================================================
  Widget _buildUserProfile(
    String fullName,
    String email,
    int totalCheckins,
    double avgScore,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF5235C5).withValues(alpha: 0.08),
            const Color(0xFF1A5F7A).withValues(alpha: 0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF5235C5).withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF5235C5), Color(0xFF7B2CBF)],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF5235C5).withValues(alpha: 0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                fullName.isNotEmpty ? fullName[0].toUpperCase() : 'U',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fullName,
                  style: GoogleFonts.manrope(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1C1B1B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  email,
                  style: GoogleFonts.manrope(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF484554),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF5235C5).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$totalCheckins Check-ins',
                        style: GoogleFonts.manrope(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF5235C5),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2D6A4F).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Avg: ${avgScore > 0 ? avgScore.toStringAsFixed(1) : '--'}/5',
                        style: GoogleFonts.manrope(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF2D6A4F),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // Stats Card
  // ============================================================
  Widget _buildStatsCard(int totalCheckins, double avgScore) {
    // ✅ تنسيق تاريخ آخر Check-in
    String lastCheckin = '--';
    if (_userData?['last_checkin'] != null) {
      try {
        final date = DateTime.parse(_userData!['last_checkin'].toString());
        lastCheckin = '${date.day}/${date.month}/${date.year}';
      } catch (_) {
        lastCheckin =
            _userData?['last_checkin']?.toString().split('T').first ?? '--';
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          _buildStatItem(
            icon: Icons.checklist,
            label: 'Total',
            value: totalCheckins.toString(),
            color: const Color(0xFF5235C5),
          ),
          Container(width: 1, height: 40, color: const Color(0xFFE8E8EE)),
          _buildStatItem(
            icon: Icons.analytics,
            label: 'Average',
            value: avgScore > 0 ? avgScore.toStringAsFixed(1) : '--',
            color: const Color(0xFF2D6A4F),
          ),
          Container(width: 1, height: 40, color: const Color(0xFFE8E8EE)),
          _buildStatItem(
            icon: Icons.calendar_today,
            label: 'Last',
            value: lastCheckin,
            color: const Color(0xFFF4A261),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.manrope(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF8A8A9A),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.manrope(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // Settings List - تصميم احترافي 2026
  // ============================================================
  Widget _buildSettingsList() {
    // ✅ تعريف الأقسام
    final List<Map<String, dynamic>> settings = [];

    // ============================================================
    // 📌 القسم 1: الصوت والميكروفون (يظهر فقط على الموبايل)
    // ============================================================
    if (!Platform.isWindows && !Platform.isLinux && !Platform.isMacOS) {
      settings.addAll([
        {
          'icon': Icons.record_voice_over_rounded,
          'title': 'Voice Features',
          'subtitle': _getMicrophoneStatusText(),
          'color': _getMicrophoneStatusColor(),
          'isVoiceSection': true,
          'onTap': _requestMicrophonePermission,
        },
        {
          'icon': Icons.mic_none_rounded,
          'title': 'Test Microphone',
          'subtitle': 'Check if your microphone is working properly',
          'color': const Color(0xFF5235C5),
          'isVoiceSection': false,
          'onTap': _testMicrophone,
        },
        {
          'icon': Icons.mic_off,
          'title': 'Disable Microphone',
          'subtitle': 'Revoke microphone permission',
          'color': const Color(0xFFE76F51),
          'isVoiceSection': false,
          'onTap': _revokeMicrophonePermission,
        },
        {
          'icon': Icons.audio_file,
          'title': 'Pending Recordings',
          'subtitle': _getPendingCountText(),
          'color': const Color(0xFFF4A261),
          'isVoiceSection': false,
          'onTap': _showPendingRecordings,
        },
      ]);
    }

    // ============================================================
    // 📌 القسم 2: الملف الشخصي
    // ============================================================
    settings.addAll([
      {
        'icon': Icons.person_outline_rounded,
        'title': 'Edit Profile',
        'subtitle': 'Update your name and profile information',
        'color': const Color(0xFF5235C5),
        'isVoiceSection': false,
        'onTap': _editProfile,
      },
    ]);

    // ============================================================
    // 📌 القسم 3: البيانات
    // ============================================================
    settings.addAll([
      {
        'icon': Icons.download_outlined,
        'title': 'Export Data',
        'subtitle': 'Download all your data as JSON file',
        'color': const Color(0xFF2D6A4F),
        'isVoiceSection': false,
        'onTap': _exportData,
      },
      {
        'icon': Icons.delete_outline,
        'title': 'Delete My Data',
        'subtitle': 'Remove all your cognitive analysis records',
        'color': const Color(0xFFE76F51),
        'isVoiceSection': false,
        'onTap': _deleteAllData,
      },
    ]);

    // ============================================================
    // 📌 القسم 4: الخصوصية والقانون
    // ============================================================
    settings.addAll([
      {
        'icon': Icons.privacy_tip_outlined,
        'title': 'Privacy Policy',
        'subtitle': 'Read how we handle your data',
        'color': const Color(0xFF5235C5),
        'isVoiceSection': false,
        'onTap': _showPrivacyPolicy,
      },
      {
        'icon': Icons.description_outlined,
        'title': 'Terms of Service',
        'subtitle': 'Read the terms and conditions',
        'color': const Color(0xFF5235C5),
        'isVoiceSection': false,
        'onTap': _showTermsOfService,
      },
    ]);

    // ============================================================
    // 📌 القسم 5: التواصل والدعم
    // ============================================================
    settings.addAll([
      {
        'icon': Icons.contact_support_rounded,
        'title': 'Contact Us',
        'subtitle': 'Send us your questions or feedback',
        'color': const Color(0xFF5235C5),
        'isVoiceSection': false,
        'onTap': _contactUs,
      },
      {
        'icon': Icons.star_rounded,
        'title': 'Rate the App',
        'subtitle': 'Share your feedback and help us improve',
        'color': const Color(0xFFF4A261),
        'isVoiceSection': false,
        'onTap': _rateApp,
      },
      {
        'icon': Icons.info_outline_rounded,
        'title': 'About',
        'subtitle': 'Learn more about Mental Load App',
        'color': const Color(0xFF5235C5),
        'isVoiceSection': false,
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AboutScreen()),
          );
        },
      },
    ]);

    // ============================================================
    // ✅ البناء
    // ============================================================
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE8E8EE), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ عنوان القسم
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 18,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFF5235C5), Color(0xFF7B2CBF)],
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Settings',
                  style: GoogleFonts.manrope(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1A2E),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F7FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${settings.length} items',
                    style: GoogleFonts.manrope(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF8A8A9A),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: Color(0xFFF0EEF5)),

          // ✅ عناصر الإعدادات
          ...settings.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isLast = index == settings.length - 1;
            final isVoiceSection = item['isVoiceSection'] as bool? ?? false;

            return _buildSettingsTile(
              icon: item['icon'] as IconData,
              title: item['title'] as String,
              subtitle: item['subtitle'] as String,
              color: item['color'] as Color,
              onTap: item['onTap'] as VoidCallback,
              isLast: isLast,
              isVoiceSection: isVoiceSection,
            );
          }),
        ],
      ),
    );
  }

String _getPendingCountText() {
  // ✅ سيتم تحديثها لاحقاً
  return 'Check pending audio files';
}

Future<void> _showPendingRecordings() async {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const PendingRecordingsScreen(),
    ),
  );
}

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    bool isLast = false,
    bool isVoiceSection = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isVoiceSection
            ? color.withValues(alpha: 0.04)
            : Colors.transparent,
        border: Border(
          bottom: isLast
              ? BorderSide.none
              : BorderSide(color: const Color(0xFFF0EEF5), width: 1),
        ),
        borderRadius: isLast
            ? const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              )
            : null,
      ),
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Row(
          children: [
            // ✅ أيقونة مع خلفية
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isVoiceSection
                      ? [
                          color.withValues(alpha: 0.15),
                          color.withValues(alpha: 0.05),
                        ]
                      : [
                          color.withValues(alpha: 0.1),
                          color.withValues(alpha: 0.05),
                        ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: color.withValues(alpha: isVoiceSection ? 0.2 : 0.1),
                  width: isVoiceSection ? 1.5 : 1,
                ),
              ),
              child: Icon(icon, color: color, size: isVoiceSection ? 22 : 20),
            ),
            const SizedBox(width: 14),

            // ✅ النصوص (مع Expanded لمنع التجاوز)
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          style: GoogleFonts.manrope(
                            fontSize: isVoiceSection ? 15 : 14,
                            fontWeight: isVoiceSection
                                ? FontWeight.w700
                                : FontWeight.w600,
                            color: const Color(0xFF1A1A2E),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isVoiceSection)
                        Container(
                          margin: const EdgeInsets.only(left: 6),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                color.withValues(alpha: 0.15),
                                color.withValues(alpha: 0.05),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: color.withValues(alpha: 0.15),
                            ),
                          ),
                          child: Text(
                            _getMicrophoneStatusText(),
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.w700,
                              color: color,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isVoiceSection
                        ? 'Enable voice input for check-ins'
                        : subtitle,
                    style: GoogleFonts.manrope(
                      fontSize: isVoiceSection ? 11 : 12,
                      fontWeight: FontWeight.w400,
                      color: isVoiceSection
                          ? const Color(0xFF6B6B7A)
                          : const Color(0xFF8A8A9A),
                    ),
                    maxLines: isVoiceSection ? 1 : 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // ✅ سهم فقط (بدون حالة - لأن الحالة أصبحت في الأعلى)
            Icon(Icons.chevron_right, color: const Color(0xFFD1D1D8), size: 20),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // Danger Zone - مع دعم Guest Mode
  // ============================================================
  Widget _buildDangerZone() {
    // ✅ التحقق من حالة Guest
    final bool isGuest = _userData?['is_guest'] ?? false;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE76F51).withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE76F51).withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: const Color(0xFFE76F51),
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                isGuest ? 'Guest Account' : 'Danger Zone',
                style: GoogleFonts.manrope(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFE76F51),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ✅ إذا كان Guest، عرض رسالة تحذيرية
          if (isGuest)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF4A261).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFFF4A261).withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: const Color(0xFFF4A261),
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'You are browsing as Guest. Data will not be saved.',
                      style: GoogleFonts.manrope(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFFF4A261),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // ✅ زر Logout (يظهر للجميع)
          GestureDetector(
            onTap: _logout,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFE76F51).withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE76F51).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.logout,
                      color: Color(0xFFE76F51),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isGuest ? 'Exit Guest Mode' : 'Logout',
                          style: GoogleFonts.manrope(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFE76F51),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isGuest
                              ? 'Return to login screen'
                              : 'Sign out from your account',
                          style: GoogleFonts.manrope(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF8A8A9A),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_isLoggingOut)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFFE76F51),
                      ),
                    )
                  else
                    Icon(
                      Icons.chevron_right,
                      color: const Color(0xFFE76F51),
                      size: 18,
                    ),
                ],
              ),
            ),
          ),

          // ✅ إذا كان Guest، لا يظهر زر "Delete Account"
          if (!isGuest) ...[
            const SizedBox(height: 10),
            GestureDetector(
              onTap: _deleteAccount,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFE76F51).withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE76F51).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.delete_forever,
                        color: Color(0xFFE76F51),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Delete Account',
                            style: GoogleFonts.manrope(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFFE76F51),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Permanently delete your account and all associated data.',
                            style: GoogleFonts.manrope(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF8A8A9A),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: const Color(0xFFE76F51),
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ============================================================
  // App Version
  // ============================================================
  Widget _buildAppVersion() {
    return Center(
      child: Column(
        children: [
          Text(
            'App Version',
            style: GoogleFonts.manrope(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF8A8A9A),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE8E8EE)),
            ),
            child: Text(
              '1.0.0',
              style: GoogleFonts.manrope(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF5235C5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ✅ عرض رسالة منبثقة في الأعلى (الحل النهائي)
  // ============================================================
  void _showTopSnackBar(String message, {bool isError = true}) {
    final overlay = Overlay.of(context);

    // ✅ تعريف overlayEntry كـ late واستخدامها بعد التعريف
    late final OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 40,
        left: 16,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: TweenAnimationBuilder(
            tween: Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero),
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
            builder: (context, offset, child) {
              return Transform.translate(
                offset: offset as Offset,
                child: child,
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: isError
                    ? const Color(0xFFE76F51)
                    : const Color(0xFF2D6A4F),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    isError
                        ? Icons.wifi_off_rounded
                        : Icons.check_circle_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      message,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      try {
                        overlayEntry.remove();
                      } catch (_) {}
                    },
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    // ✅ إزالة تلقائية بعد 5 ثواني
    Future.delayed(const Duration(seconds: 5), () {
      try {
        overlayEntry.remove();
      } catch (_) {}
    });
  }

  // ============================================================
  // 🎙️ دوال الميكروفون المحسّنة (تصميم 2026)
  // ============================================================

  // ✅ التحقق من حالة الميكروفون
  Future<void> _checkMicrophoneStatus() async {
    final status = await Permission.microphone.status;
    setState(() {
      _microphoneStatus = status;
    });
  }

  // ✅ الحصول على نص حالة الميكروفون
  String _getMicrophoneStatusText() {
    if (_microphoneStatus.isGranted) {
      return '✅ Enabled';
    } else if (_microphoneStatus.isDenied) {
      return '⚠️ Denied';
    } else if (_microphoneStatus.isPermanentlyDenied) {
      return '🔒 Permanently Denied';
    } else {
      return '⏳ Not Requested';
    }
  }

  // ✅ الحصول على لون حالة الميكروفون
  Color _getMicrophoneStatusColor() {
    if (_microphoneStatus.isGranted) {
      return const Color(0xFF2D6A4F);
    } else if (_microphoneStatus.isDenied) {
      return const Color(0xFFF4A261);
    } else if (_microphoneStatus.isPermanentlyDenied) {
      return const Color(0xFFE76F51);
    } else {
      return const Color(0xFF8A8A9A);
    }
  }

  // ✅ طلب إذن الميكروفون (محسّن)
  Future<void> _requestMicrophonePermission() async {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      _showTopSnackBar('🔊 Microphone not required on desktop', isError: false);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final status = await Permission.microphone.request();
      setState(() {
        _microphoneStatus = status;
        _isLoading = false;
      });

      if (status.isGranted) {
        _showTopSnackBar('✅ Microphone enabled successfully!', isError: false);
      } else if (status.isDenied) {
        _showTopSnackBar('⚠️ Microphone permission denied', isError: true);
      } else if (status.isPermanentlyDenied) {
        _showTopSnackBar(
          '🔒 Permission permanently denied. Please enable in system settings.',
          isError: true,
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showTopSnackBar('⚠️ Failed to request permission', isError: true);
    }
  }

  // ✅ اختبار الميكروفون (مهم للهاكاثون)
  Future<void> _testMicrophone() async {
    final status = await Permission.microphone.status;

    if (!status.isGranted) {
      _showTopSnackBar(
        '⚠️ Please grant microphone permission first',
        isError: true,
      );
      return;
    }

    setState(() => _isTestingMicrophone = true);

    // ✅ عرض نافذة اختبار الميكروفون
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, const Color(0xFFF8F7FF)],
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 30,
                offset: const Offset(0, 10),
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ✅ أيقونة متحركة
              AnimatedBuilder(
                animation: _micPulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _micPulseAnimation.value,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF5235C5), Color(0xFF7B2CBF)],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFF5235C5,
                            ).withValues(alpha: 0.3),
                            blurRadius: 30,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.mic,
                        color: Colors.white,
                        size: 48,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),

              // ✅ العنوان
              Text(
                '🎤 Testing Microphone',
                style: GoogleFonts.manrope(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1A1A2E),
                ),
              ),
              const SizedBox(height: 8),

              // ✅ الوصف
              Text(
                'Speak something... We\'re listening 👂',
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF6B6B7A),
                ),
              ),
              const SizedBox(height: 20),

              // ✅ مؤشر الصوت
              Container(
                height: 60,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F7FF),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFF5235C5).withValues(alpha: 0.15),
                  ),
                ),
                child: Row(
                  children: List.generate(20, (index) {
                    return Expanded(
                      child: Container(
                        height: 20 + (index % 5) * 8,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              const Color(0xFF5235C5).withValues(alpha: 0.2),
                              const Color(0xFF5235C5).withValues(alpha: 0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 20),

              // ✅ زر الإيقاف (محسّن)
              SizedBox(
                width: double.infinity,
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          _stopRecordingTimer();
                          Navigator.pop(context);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF8A8A9A),
                          side: const BorderSide(color: Color(0xFFE8E8EE)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () {
                          _stopRecordingTimer();
                          setState(() => _isTestingMicrophone = false);
                          Navigator.pop(context);
                          _showTopSnackBar(
                            '✅ Microphone test completed!',
                            isError: false,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE76F51),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 4,
                          shadowColor: const Color(
                            0xFFE76F51,
                          ).withValues(alpha: 0.3),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.stop_rounded, size: 18),
                            SizedBox(width: 8),
                            Text(
                              'Stop Test',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // ⏱️ إيقاف مؤقت التسجيل
  // ============================================================
  void _stopRecordingTimer() {
    // في حال كنت تستخدم Timer، قم بإيقافه هنا
    // حالياً لا يوجد Timer، لكن الدالة موجودة للتوسع المستقبلي
    debugPrint('⏱️ Recording timer stopped');
  }

  // ============================================================
  // 🎙️ إلغاء إذن الميكروفون
  // ============================================================
  Future<void> _revokeMicrophonePermission() async {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      _showTopSnackBar(
        '🔊 Microphone not available on desktop',
        isError: false,
      );
      return;
    }

    try {
      await openAppSettings();
      _showTopSnackBar(
        '📱 Please disable microphone permission in system settings',
        isError: false,
      );
    } catch (e) {
      _showTopSnackBar('⚠️ Failed to open settings', isError: true);
    }
  }
}
