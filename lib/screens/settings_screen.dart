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
import '../widgets/logout_dialog.dart';
import '../widgets/delete_account_dialog.dart';
import 'privacy_policy_screen.dart';
import '../widgets/delete_data_dialog.dart';
import '../widgets/contact_us_dialog.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final SupabaseService _supabaseService = SupabaseService();

  // ============================================================
  // متغيرات البيانات
  // ============================================================
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  bool _isLoggingOut = false;
  String? _errorMessage;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadUserData();
  }

  // ============================================================
  // جلب بيانات المستخدم من Supabase
  // ============================================================
Future<void> _loadUserData() async {
  setState(() {
    _isLoading = true;
    _errorMessage = null;
  });

  try {
    final prefs = await SharedPreferences.getInstance();
    final isGuest = prefs.getBool('isGuest') ?? false;

    if (isGuest) {
      setState(() {
        _userData = {
          'full_name': 'Guest',
          'email': 'guest@mentalload.app',
          'total_checkins': 0,
          'is_guest': true,
        };
        _isLoading = false;
      });
      return;
    }

    final user = _supabaseService.currentUser;
    if (user != null) {
      // ... باقي الكود
    }
  } catch (e) {
    // ... معالجة الأخطاء
  }
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
  // 🎙️ طلب إذن الميكروفون (متوافق مع جميع المنصات)
  // ============================================================
  Future<void> _requestMicrophonePermission() async {
    // التحقق من المنصة
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      _showMessage('🔊 Microphone permission is not required on desktop');
      return;
    }

    try {
      final status = await Permission.microphone.request();
      if (status.isGranted) {
        _showMessage('✅ Microphone permission granted!');
      } else if (status.isDenied) {
        _showMessage('⚠️ Microphone permission denied', isError: true);
      } else if (status.isPermanentlyDenied) {
        _showMessage(
          '⚠️ Permission permanently denied. Please enable in settings.',
          isError: true,
        );
      }
    } catch (e) {
      _showMessage(
        '⚠️ Please grant microphone permission in system settings',
        isError: true,
      );
    }
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
  // 2️⃣ EXPORT DATA - تصدير البيانات بصيغة JSON
  // ============================================================
  Future<void> _exportData() async {
    setState(() => _isLoading = true);

    try {
      final user = _supabaseService.currentUser;
      if (user == null) throw Exception('User not logged in');

      final checkins = await _supabaseService.client
          .from('checkins')
          .select()
          .eq('user_id', user.id)
          .order('checkin_date', ascending: false);

      final recommendations = await _supabaseService.client
          .from('recommendations_history')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      final questionnaire = await _supabaseService.client
          .from('questionnaire_history')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

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

      _showMessage('✅ Data exported successfully!');
    } catch (e) {
      debugPrint('❌ Error exporting data: $e');
      _showMessage('Failed to export data', isError: true);
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
            _showMessage('Failed to delete data. Please try again.', isError: true);
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
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF5235C5)),
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
  // App Bar
  // ============================================================
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      actions: [
        // ✅ زر تحديث البيانات
        IconButton(
          onPressed: _isLoading ? null : _loadUserData,
          icon: Icon(
            _isLoading ? Icons.hourglass_empty : Icons.refresh,
            color: const Color(0xFF5235C5),
            size: 24,
          ),
          tooltip: 'Refresh data',
        ),
      ],
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Settings',
            style: GoogleFonts.manrope(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF5235C5),
            ),
          ),
          Text(
            'Manage your preferences and privacy settings',
            style: GoogleFonts.manrope(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF484554),
            ),
          ),
        ],
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
  // Settings List
  // ============================================================
  Widget _buildSettingsList() {
    final settings = [
      {
        'icon': Icons.person_outline,
        'title': 'Edit Profile',
        'subtitle': 'Update your name and profile information',
        'color': const Color(0xFF5235C5),
        'onTap': _editProfile,
      },
      {
        'icon': Icons.mic,
        'title': 'Microphone Permission',
        'subtitle': 'Manage access to your microphone for voice input',
        'color': const Color(0xFF5235C5),
        'onTap': _requestMicrophonePermission,
      },
      {
        'icon': Icons.download_outlined,
        'title': 'Export Data',
        'subtitle': 'Download all your data as JSON file',
        'color': const Color(0xFF2D6A4F),
        'onTap': _exportData,
      },
      {
        'icon': Icons.privacy_tip_outlined,
        'title': 'Privacy Policy',
        'subtitle': 'Read how we handle your data',
        'color': const Color(0xFF5235C5),
        'onTap': _showPrivacyPolicy,
      },
      {
        'icon': Icons.description_outlined,
        'title': 'Terms of Service',
        'subtitle': 'Read the terms and conditions',
        'color': const Color(0xFF5235C5),
        'onTap': _showTermsOfService,
      },
      {
        'icon': Icons.delete_outline,
        'title': 'Delete My Data',
        'subtitle':
            'Remove all your cognitive analysis records and stored data',
        'color': const Color(0xFFE76F51),
        'onTap': _deleteAllData,
      },
      {
        'icon': Icons.contact_support,
        'title': 'Contact Us',
        'subtitle': 'Send us your questions or feedback',
        'color': const Color(0xFF5235C5),
        'onTap': _contactUs,
      },
      {
        'icon': Icons.star_border,
        'title': 'Rate the App',
        'subtitle': 'Share your feedback and help us improve',
        'color': const Color(0xFF5235C5),
        'onTap': _rateApp,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 4),
        ...settings.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return _buildSettingsTile(
            icon: item['icon'] as IconData,
            title: item['title'] as String,
            subtitle: item['subtitle'] as String,
            color: item['color'] as Color,
            onTap: item['onTap'] as VoidCallback,
            isLast: index == settings.length - 1,
          );
        }),
      ],
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    bool isLast = false,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: const Radius.circular(16),
          bottom: Radius.circular(isLast ? 16 : 0),
        ),
        border: Border(
          bottom: isLast
              ? BorderSide.none
              : BorderSide(color: const Color(0xFFE8E8EE)),
        ),
        boxShadow: [
          if (isLast)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.manrope(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1C1B1B),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF8A8A9A),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: const Color(0xFFB0B0BA), size: 18),
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
                Icon(Icons.info_outline, color: const Color(0xFFF4A261), size: 18),
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
                        isGuest ? 'Return to login screen' : 'Sign out from your account',
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
}
