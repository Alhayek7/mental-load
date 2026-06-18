// ============================================================
// 📄 lib/screens/profile_screen.dart
// ============================================================

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import '../widgets/contact_us_dialog.dart';
import '../services/supabase_service.dart';
import 'login_screen.dart';
import 'rate_app_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final SupabaseService _supabaseService = SupabaseService();

  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  bool _isLoggingOut = false;
  bool _isGuest = false;
  bool _isOnline = true;
  String _userName = 'User';
  String _userEmail = '';

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  // ============================================================
  // Load
  // ============================================================
  Future<void> _loadAll() async {
    if (mounted) setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      _isGuest = prefs.getBool('isGuest') ?? false;
      _isOnline = await InternetConnectionChecker().hasConnection;


      if (_isGuest) {
        _userName = 'Guest';
        _userEmail = 'guest@mentalload.app';
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      // جلب الاسم من SharedPreferences كـ fallback
      final stored = prefs.getString('loggedInUser') ?? '';
      if (stored.isNotEmpty) {
        _userEmail = stored;
        _userName = stored.split('@')[0];
      }

      // جلب البيانات من Supabase
      if (_isOnline) {
        final user = _supabaseService.currentUser;
        if (user != null) {
          final data = await _supabaseService
              .getUserData(user.id)
              .timeout(const Duration(seconds: 5));
          if (data != null) {
            _userData = data;
            if (data['full_name'] != null && data['full_name'].toString().isNotEmpty) {
              _userName = data['full_name'];
            }
            if (data['email'] != null && data['email'].toString().isNotEmpty) {
              _userEmail = data['email'];
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Profile load error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ============================================================
  // Microphone Permission
  // ============================================================
  Future<void> _handleMicrophonePermission() async {
    final status = await Permission.microphone.status;

    if (status.isGranted) {
      _showInfoSnackbar('✅ Microphone access is already granted.');
      return;
    }

    if (status.isPermanentlyDenied) {
      final opened = await openAppSettings();
      if (!opened && mounted) {
        _showInfoSnackbar('Please enable microphone in device settings.');
      }
      return;
    }

    final result = await Permission.microphone.request();
    if (mounted) {
      if (result.isGranted) {
        _showSuccessSnackbar('✅ Microphone permission granted!');
      } else {
        _showErrorSnackbar('Microphone permission denied.');
      }
    }
  }

// ============================================================
// Contact Us (نسخة محسّنة مع مربع حوار)
// ============================================================
void _contactUs() {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) => const ContactUsDialog(),
  );
}

// ============================================================
// Rate App - فتح صفحة التقييم
// ============================================================
Future<void> _rateApp() async {
  // ✅ فتح صفحة تقييم التطبيق
  final result = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const RateAppScreen(),
    ),
  );
  
  // ✅ بعد إغلاق صفحة التقييم، يمكن تحديث البيانات إذا لزم الأمر
  if (result == true) {
    // يمكن إضافة تحديث هنا إذا أردت
    debugPrint('✅ App rated successfully!');
  }
}

// ============================================================
// Logout - نافذة احترافية
// ============================================================
Future<void> _logout() async {
  // ✅ نافذة تسجيل الخروج المحسّنة
  final confirmed = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
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
            // ✅ أيقونة تسجيل الخروج
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE76F51).withValues(alpha: 0.08),
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFE76F51).withValues(alpha: 0.15),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.logout_rounded,
                color: Color(0xFFE76F51),
                size: 48,
              ),
            ),
            const SizedBox(height: 20),
            
            // ✅ العنوان
            const Text(
              'Logout',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 8),
            
            // ✅ الوصف
            const Text(
              'Are you sure you want to logout from your account?',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF6B6B7A),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            
            // ✅ معلومات إضافية
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F7FF),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFE8E8EE),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: Color(0xFF8A8A9A),
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'You will need to login again to access your data.',
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF8A8A9A),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            // ✅ زر Logout (في الأعلى)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoggingOut ? null : () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE76F51),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: _isLoggingOut
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.logout_rounded, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'Logout',
                            style: GoogleFonts.manrope(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 10),
            
            // ✅ زر Cancel (في الأسفل)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _isLoggingOut ? null : () => Navigator.pop(context, false),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF8A8A9A),
                  side: const BorderSide(color: Color(0xFFE8E8EE)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.manrope(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    ),
  );

  if (confirmed != true) return;

  setState(() => _isLoggingOut = true);

  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (!_isGuest) {
      await _supabaseService.signOut().timeout(const Duration(seconds: 5));
    }

    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  } catch (e) {
    if (mounted) {
      setState(() => _isLoggingOut = false);
      _showErrorSnackbar('Failed to logout. Please try again.');
    }
  }
}

// ============================================================
// Delete Account - نافذة احترافية
// ============================================================
Future<void> _deleteAccount() async {
  if (_isGuest) {
    _showErrorSnackbar('Guest accounts cannot be deleted.');
    return;
  }

  bool _confirmed = false;
  bool _isDeleting = false;

  final confirmed = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
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
                // ✅ أيقونة تحذير قوية
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE76F51).withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFE76F51).withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.delete_forever_rounded,
                    color: Color(0xFFE76F51),
                    size: 48,
                  ),
                ),
                const SizedBox(height: 20),

                // ✅ العنوان
                const Text(
                  'Delete Account',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFE76F51),
                  ),
                ),
                const SizedBox(height: 8),

                // ✅ الوصف
                const Text(
                  'This action cannot be undone. All your data will be permanently deleted.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B6B7A),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // ✅ قائمة التحذيرات
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF5F5),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFE76F51).withValues(alpha: 0.15),
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildWarningItem(
                        icon: Icons.person_off_outlined,
                        text: 'Account will be permanently deleted',
                        color: const Color(0xFFE76F51),
                      ),
                      const SizedBox(height: 8),
                      _buildWarningItem(
                        icon: Icons.data_usage_outlined,
                        text: 'All check-ins and data will be removed',
                        color: const Color(0xFFE76F51),
                      ),
                      const SizedBox(height: 8),
                      _buildWarningItem(
                        icon: Icons.delete_sweep_outlined,
                        text: 'History and recommendations lost forever',
                        color: const Color(0xFFE76F51),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ✅ زر التأكيد
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _confirmed = !_confirmed;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _confirmed
                          ? const Color(0xFFE76F51).withValues(alpha: 0.05)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _confirmed
                            ? const Color(0xFFE76F51)
                            : const Color(0xFFE8E8EE),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: _confirmed
                                ? const Color(0xFFE76F51)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: _confirmed
                                  ? const Color(0xFFE76F51)
                                  : const Color(0xFFB0B0BA),
                              width: 2,
                            ),
                          ),
                          child: _confirmed
                              ? const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 16,
                                )
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'I understand that this action is permanent and cannot be undone',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: _confirmed ? FontWeight.w600 : FontWeight.w400,
                              color: _confirmed
                                  ? const Color(0xFF1A1A2E)
                                  : const Color(0xFF8A8A9A),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // ✅ زر Delete Account (يعمل فقط عند التأكيد)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _confirmed && !_isDeleting
                        ? () async {
                            setState(() => _isDeleting = true);
                            final result = await _performDeleteAccount();
                            if (mounted) {
                              Navigator.pop(context, result);
                            }
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _confirmed && !_isDeleting
                          ? const Color(0xFFE76F51)
                          : const Color(0xFFD1D1D8),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: _isDeleting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.delete_forever_rounded, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                _confirmed ? 'Delete Account' : 'Confirm to Delete',
                                style: GoogleFonts.manrope(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 10),

                // ✅ زر Cancel
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _isDeleting ? null : () => Navigator.pop(context, false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF8A8A9A),
                      side: const BorderSide(color: Color(0xFFE8E8EE)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.manrope(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    ),
  );

  if (confirmed != true) return;

  setState(() => _isLoggingOut = true);

  try {
    await _supabaseService.deleteAccount();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  } catch (e) {
    if (mounted) {
      setState(() => _isLoggingOut = false);
      _showErrorSnackbar('Failed to delete account. Please try again.');
    }
  }
}

// ============================================================
// Warning Item Helper
// ============================================================
Widget _buildWarningItem({
  required IconData icon,
  required String text,
  required Color color,
}) {
  return Row(
    children: [
      Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, color: color, size: 16),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: Text(
          text,
          style: GoogleFonts.manrope(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF1A1A2E),
          ),
        ),
      ),
    ],
  );
}

// ============================================================
// Perform Delete Account
// ============================================================
Future<bool> _performDeleteAccount() async {
  try {
    await _supabaseService.deleteAccount();
    return true;
  } catch (e) {
    return false;
  }
}

// ============================================================
// Delete Data - نافذة احترافية (مع زر تأكيد يعمل)
// ============================================================
Future<void> _deleteData() async {
  if (_isGuest) {
    _showErrorSnackbar('No data to delete for guest accounts.');
    return;
  }

  bool _confirmed = false;  // ✅ متغير التأكيد

  final confirmed = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
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
                // ✅ أيقونة التحذير
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE76F51).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFE76F51).withValues(alpha: 0.2),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.delete_outline_rounded,
                    color: Color(0xFFE76F51),
                    size: 48,
                  ),
                ),
                const SizedBox(height: 20),
                
                // ✅ العنوان
                const Text(
                  'Delete All Data',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 8),
                
                // ✅ الوصف
                const Text(
                  'This will permanently delete all your cognitive analysis records, check-in history, and recommendations.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B6B7A),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                
                // ✅ قائمة البيانات التي سيتم حذفها
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F7FF),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFE76F51).withValues(alpha: 0.1),
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildDeleteItem(
                        icon: Icons.analytics_outlined,
                        text: 'Cognitive Load Scores',
                        color: const Color(0xFF5E35B1),
                      ),
                      const SizedBox(height: 8),
                      _buildDeleteItem(
                        icon: Icons.history_outlined,
                        text: 'Check-in History',
                        color: const Color(0xFF1A5F7A),
                      ),
                      const SizedBox(height: 8),
                      _buildDeleteItem(
                        icon: Icons.recommend_outlined,
                        text: 'Recommendations',
                        color: const Color(0xFF2D6A4F),
                      ),
                      const SizedBox(height: 8),
                      _buildDeleteItem(
                        icon: Icons.person_outline,
                        text: 'Profile Information',
                        color: const Color(0xFFF4A261),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                
                // ✅ زر التأكيد (يعمل الآن)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _confirmed = !_confirmed;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _confirmed
                          ? const Color(0xFFE76F51).withValues(alpha: 0.05)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _confirmed
                            ? const Color(0xFFE76F51)
                            : const Color(0xFFE8E8EE),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: _confirmed
                                ? const Color(0xFFE76F51)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: _confirmed
                                  ? const Color(0xFFE76F51)
                                  : const Color(0xFFB0B0BA),
                              width: 2,
                            ),
                          ),
                          child: _confirmed
                              ? const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 16,
                                )
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'I understand that this action is permanent and cannot be undone',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: _confirmed ? FontWeight.w600 : FontWeight.w400,
                              color: _confirmed
                                  ? const Color(0xFF1A1A2E)
                                  : const Color(0xFF8A8A9A),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                
                // ✅ زر Delete (يعمل فقط عند التأكيد)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _confirmed ? () => Navigator.pop(context, true) : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _confirmed
                          ? const Color(0xFFE76F51)
                          : const Color(0xFFD1D1D8),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.delete_outline_rounded, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          _confirmed ? 'Delete All Data' : 'Confirm to Delete',
                          style: GoogleFonts.manrope(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                
                // ✅ زر Cancel
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF8A8A9A),
                      side: const BorderSide(color: Color(0xFFE8E8EE)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.manrope(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    ),
  );

  if (confirmed != true) return;

  try {
    final user = _supabaseService.currentUser;
    if (user != null) {
      await _supabaseService.client
          .from('checkins')
          .delete()
          .eq('user_id', user.id);
      await _supabaseService.client
          .from('questionnaire_history')
          .delete()
          .eq('user_id', user.id);
    }

    if (mounted) {
      _showSuccessSnackbar('✅ All data deleted successfully.');
      _loadAll();
    }
  } catch (e) {
    if (mounted) _showErrorSnackbar('Failed to delete data.');
  }
}

// ============================================================
// Delete Item Helper
// ============================================================
Widget _buildDeleteItem({
  required IconData icon,
  required String text,
  required Color color,
}) {
  return Row(
    children: [
      Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 16),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Text(
          text,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF1A1A2E),
          ),
        ),
      ),
      Icon(
        Icons.delete_outline,
        color: const Color(0xFFE76F51).withValues(alpha: 0.5),
        size: 16,
      ),
    ],
  );
}

  // ============================================================
  // Helpers
  // ============================================================
  Future<bool?> _showConfirmDialog({
    required String title,
    required String message,
    required String confirmText,
    bool isDestructive = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDestructive ? const Color(0xFFE76F51) : const Color(0xFF1A1A2E),
          ),
        ),
        content: Text(
          message,
          style: const TextStyle(fontSize: 14, color: Color(0xFF6B6B7A), height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF8A8A9A))),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDestructive ? const Color(0xFFE76F51) : const Color(0xFF5E35B1),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  void _showSuccessSnackbar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: const Color(0xFF2D6A4F),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  void _showErrorSnackbar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: const Color(0xFFE76F51),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  void _showInfoSnackbar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: const Color(0xFF5E35B1),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  // ============================================================
  // Build
  // ============================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FF),
      appBar: _buildAppBar(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF5E35B1)))
          : RefreshIndicator(
              onRefresh: _loadAll,
              color: const Color(0xFF5E35B1),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Offline banner
                    if (!_isOnline) _buildOfflineBanner(),
                    if (!_isOnline) const SizedBox(height: 12),

                    // Guest banner
                    if (_isGuest) _buildGuestBanner(),
                    if (_isGuest) const SizedBox(height: 12),

                    _buildUserProfileCard(),
                    const SizedBox(height: 20),
                    _buildStatsRow(),
                    const SizedBox(height: 20),
                    _buildSettingsSection(),
                    const SizedBox(height: 20),
                    if (!_isGuest) _buildDangerZone(),
                    if (!_isGuest) const SizedBox(height: 20),
                    _buildAppVersion(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }

  // ============================================================
  // AppBar
  // ============================================================
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF5E35B1), size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Profile',
            style: GoogleFonts.manrope(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF5E35B1),
            ),
          ),
          Text(
            'Manage your preferences & privacy',
            style: GoogleFonts.manrope(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF8A8A9A),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // Offline Banner
  // ============================================================
  Widget _buildOfflineBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF4A261).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF4A261).withValues(alpha: 0.3)),
      ),
      child: const Row(
        children: [
          Icon(Icons.wifi_off, color: Color(0xFFF4A261), size: 18),
          SizedBox(width: 8),
          Flexible(
            child: Text(
              'You\'re offline. Showing cached data.',
              style: TextStyle(fontSize: 12, color: Color(0xFFF4A261), fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // Guest Banner
  // ============================================================
  Widget _buildGuestBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF5E35B1), Color(0xFF7B2CBF)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.person_outline, color: Colors.white, size: 24),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'You\'re browsing as Guest',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),
                ),
                SizedBox(height: 2),
                Text(
                  'Create an account to save your data and access all features.',
                  style: TextStyle(fontSize: 11, color: Colors.white70),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
            ),
            style: TextButton.styleFrom(
              backgroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text(
              'Sign Up',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF5E35B1)),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // User Profile Card
  // ============================================================
// ============================================================
// User Profile Card (محسّن لمنع التجاوز)
// ============================================================
Widget _buildUserProfileCard() {
  final totalCheckins = _userData?['total_checkins'] ?? 0;
  final joinedAt = _userData?['created_at'];
  String joinedText = '';
  if (joinedAt != null) {
    try {
      final date = DateTime.parse(joinedAt.toString());
      joinedText = 'Joined ${date.day}/${date.month}/${date.year}';
    } catch (_) {}
  }

  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFF5E35B1).withValues(alpha: 0.08),
          const Color(0xFF7B2CBF).withValues(alpha: 0.04),
        ],
      ),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: const Color(0xFF5E35B1).withValues(alpha: 0.12)),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // ✅ Avatar (مصغر)
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF5E35B1), Color(0xFF7B2CBF)],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF5E35B1).withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: Text(
              _userName.isNotEmpty ? _userName[0].toUpperCase() : 'U',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // ✅ Info (مع Expanded لمنع التجاوز)
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      _userName,
                      style: GoogleFonts.manrope(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1A1A2E),
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  const SizedBox(width: 4),
                  if (!_isGuest)
                    const Icon(Icons.verified, color: Color(0xFF2D6A4F), size: 14),
                ],
              ),
              const SizedBox(height: 2),
              Flexible(
                child: Text(
                  _userEmail,
                  style: GoogleFonts.manrope(
                    fontSize: 11,
                    color: const Color(0xFF8A8A9A),
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              const SizedBox(height: 4),
              // ✅ Chips (مضغوطة)
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: [
                  if (!_isGuest)
                    _buildMiniChip(
                      label: '$totalCheckins Check-ins',
                      color: const Color(0xFF5E35B1),
                    ),
                  _buildMiniChip(
                    label: _isGuest ? 'Guest' : 'Member',
                    color: _isGuest ? const Color(0xFF8A8A9A) : const Color(0xFF2D6A4F),
                  ),
                  if (joinedText.isNotEmpty)
                    _buildMiniChip(
                      label: joinedText,
                      color: const Color(0xFFB0B0BA),
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

  Widget _buildMiniChip({required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }

  // ============================================================
  // Stats Row
  // ============================================================
// ============================================================
// Stats Row (محسّن لمنع التجاوز)
// ============================================================
Widget _buildStatsRow() {
  final totalCheckins = _userData?['total_checkins'] ?? 0;
  final avgScore = _userData?['avg_score'] ?? 0.0;
  final streak = _userData?['streak'] ?? 0;

  return Row(
    children: [
      Expanded(child: _buildStatCard(
        icon: Icons.checklist_rounded,
        label: 'Check-ins',
        value: '$totalCheckins',
        color: const Color(0xFF5E35B1),
      )),
      const SizedBox(width: 8),
      Expanded(child: _buildStatCard(
        icon: Icons.speed_rounded,
        label: 'Avg Score',
        value: avgScore is double ? avgScore.toStringAsFixed(1) : '$avgScore',
        color: const Color(0xFFF4A261),
      )),
      const SizedBox(width: 8),
      Expanded(child: _buildStatCard(
        icon: Icons.local_fire_department_rounded,
        label: 'Streak',
        value: '${streak}d',
        color: const Color(0xFFE76F51),
      )),
    ],
  );
}

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8E8EE)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF8A8A9A)), textAlign: TextAlign.center),
        ],
      ),
    );
  }

// ============================================================
// Settings Section - مع زر حذف البيانات المحسّن
// ============================================================
Widget _buildSettingsSection() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Settings',
        style: GoogleFonts.manrope(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF1A1A2E),
        ),
      ),
      const SizedBox(height: 12),
      _buildSettingsTile(
        icon: Icons.mic_rounded,
        title: 'Microphone Permission',
        subtitle: 'Required for voice check-in feature.',
        color: const Color(0xFF5E35B1),
        onTap: _handleMicrophonePermission,
        trailingWidget: FutureBuilder<PermissionStatus>(
          future: Permission.microphone.status,
          builder: (context, snap) {
            final granted = snap.data?.isGranted ?? false;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: granted
                    ? const Color(0xFF2D6A4F).withValues(alpha: 0.1)
                    : const Color(0xFFE76F51).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                granted ? 'Granted' : 'Denied',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: granted ? const Color(0xFF2D6A4F) : const Color(0xFFE76F51),
                ),
              ),
            );
          },
        ),
      ),
      _buildSettingsTile(
        icon: Icons.mail_outline_rounded,
        title: 'Contact Us',
        subtitle: 'Send feedback or report an issue.',
        color: const Color(0xFF1A5F7A),
        onTap: _contactUs,
      ),
      _buildSettingsTile(
        icon: Icons.star_outline_rounded,
        title: 'Rate the App',
        subtitle: 'Enjoyed Mental Load? Leave us a review!',
        color: const Color(0xFFF4A261),
        onTap: _rateApp,
      ),
      if (!_isGuest)
        _buildSettingsTile(
          icon: Icons.delete_outline_rounded,
          title: 'Delete My Data',
          subtitle: 'Remove all your analysis records.',
          color: const Color(0xFFE76F51),
          onTap: _deleteData,
        ),
    ],
  );
}

Widget _buildSettingsTile({
  required IconData icon,
  required String title,
  required String subtitle,
  required Color color,
  required VoidCallback onTap,
  Widget? trailingWidget,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.only(bottom: 10),
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
      child: Row(
        children: [
          // ✅ أيقونة
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          // ✅ النصوص (مع Expanded لمنع التجاوز)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A2E),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.manrope(
                    fontSize: 11,
                    color: const Color(0xFF8A8A9A),
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // ✅ Trailing Widget (مضغوط)
          if (trailingWidget != null)
            trailingWidget
          else
            const Icon(
              Icons.chevron_right,
              color: Color(0xFFB0B0BA),
              size: 18,
            ),
        ],
      ),
    ),
  );
}
  // ============================================================
  // Danger Zone
  // ============================================================

Widget _buildDangerZone() {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFFE76F51).withValues(alpha: 0.05),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: const Color(0xFFE76F51).withValues(alpha: 0.15),
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ✅ عنوان Danger Zone
        const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Color(0xFFE76F51), size: 20),
            SizedBox(width: 8),
            Text(
              'Danger Zone',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFFE76F51),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // ✅ زر Logout (في الأعلى)
        _buildDangerTile(
          icon: Icons.logout_rounded,
          title: 'Logout',
          subtitle: 'Sign out from your account.',
          onTap: _logout,
          isLoading: _isLoggingOut,
        ),
        const SizedBox(height: 10),
        // ✅ زر Delete Account (في الأسفل)
        _buildDangerTile(
          icon: Icons.delete_forever_rounded,
          title: 'Delete Account',
          subtitle: 'Permanently delete your account and all data.',
          onTap: _deleteAccount,
        ),
      ],
    ),
  );
}

Widget _buildDangerTile({
  required IconData icon,
  required String title,
  required String subtitle,
  required VoidCallback onTap,
  bool isLoading = false,
}) {
  return GestureDetector(
    onTap: isLoading ? null : onTap,
    child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFE76F51).withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        children: [
          // ✅ أيقونة
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFE76F51).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFFE76F51), size: 18),
          ),
          const SizedBox(width: 12),
          // ✅ النصوص (مع Expanded لمنع التجاوز)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFE76F51),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.manrope(
                    fontSize: 11,
                    color: const Color(0xFF8A8A9A),
                  ),
                ),
              ],
            ),
          ),
          // ✅ تحميل أو سهم
          isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFFE76F51),
                  ),
                )
              : const Icon(
                  Icons.chevron_right,
                  color: Color(0xFFE76F51),
                  size: 20,
                ),
        ],
      ),
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
          Text('Mental Load', style: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF5E35B1))),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE8E8EE)),
            ),
            child: Text(
              'Version 1.0.0',
              style: GoogleFonts.manrope(fontSize: 13, fontWeight: FontWeight.w500, color: const Color(0xFF8A8A9A)),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Built with ❤️ by Team GOAI',
            style: GoogleFonts.manrope(fontSize: 11, color: const Color(0xFFB0B0BA)),
          ),
        ],
      ),
    );
  }
}
