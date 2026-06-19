// ============================================================
// 📄 lib/screens/privacy_consent_screen.dart
// 📌 شاشة الموافقة على الخصوصية (تعمل مع/بدون إنترنت)
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'initial_questionnaire.dart';
import '../services/supabase_service.dart';
import 'terms_screen.dart';
import 'privacy_policy_screen.dart';

class PrivacyConsentScreen extends StatefulWidget {
  const PrivacyConsentScreen({super.key});

  @override
  State<PrivacyConsentScreen> createState() => _PrivacyConsentScreenState();
}

class _PrivacyConsentScreenState extends State<PrivacyConsentScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  
  bool _agreeToTerms = false;
  bool _agreeToDataCollection = false;
  bool _agreeToResearch = false;
  bool _agreeToNotifications = false;
  bool _isLoading = false;
  String _errorMessage = '';
  bool _isOnline = true;

  final List<Map<String, dynamic>> _privacyItems = [
    {
      'icon': Icons.analytics_outlined,
      'title': 'Data Collection',
      'description': 'We collect your check-in responses to analyze your cognitive load patterns and provide personalized recommendations to improve your productivity and mental clarity.',
      'color': const Color(0xFF5E35B1),
    },
    {
      'icon': Icons.storage_outlined,
      'title': 'Data Storage',
      'description': 'Your data is encrypted and stored securely using industry-standard encryption (AES-256). We use Supabase (PostgreSQL) with Row Level Security to ensure your data is protected.',
      'color': const Color(0xFF1A5F7A),
    },
    {
      'icon': Icons.mic_outlined,
      'title': 'Microphone Access',
      'description': 'When using voice input features, we request microphone access only for speech-to-text conversion. Audio recordings are processed in real-time and never stored permanently.',
      'color': const Color(0xFF2D6A4F),
    },
    {
      'icon': Icons.shield_outlined,
      'title': 'No Third-Party Sharing',
      'description': 'Your personal data will never be sold or shared with third parties. Your privacy is our top priority. All data remains confidential and is used only to improve your experience.',
      'color': const Color(0xFFE76F51),
    },
    {
      'icon': Icons.delete_outline,
      'title': 'Right to be Forgotten',
      'description': 'You can request deletion of all your data at any time via Settings. You have full control over your information and can export or delete your data whenever you want.',
      'color': const Color(0xFFF4A261),
    },
    {
      'icon': Icons.psychology_outlined,
      'title': 'AI Transparency',
      'description': 'Our AI uses BERT and Gemini models to analyze your responses. You can always see why a recommendation was made and correct it if inaccurate.',
      'color': const Color(0xFF5235C5),
    },
  ];

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
  }

  // ============================================================
  // ✅ التحقق من حالة الإنترنت
  // ============================================================
  Future<void> _checkConnectivity() async {
    final result = await Connectivity().checkConnectivity();
    setState(() {
      _isOnline = result != ConnectivityResult.none;
    });
  }

  // ============================================================
  // ✅ حفظ موافقة المستخدم (يعمل مع/بدون إنترنت)
  // ============================================================
  Future<void> _saveConsent() async {
    final user = _supabaseService.client.auth.currentUser;
    
    await _checkConnectivity();

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    // ✅ حفظ البيانات محلياً (دائماً)
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasAcceptedPrivacy', true);
    await prefs.setBool('agreedToTerms', _agreeToTerms);
    await prefs.setBool('agreedToDataCollection', _agreeToDataCollection);
    await prefs.setBool('agreedToResearch', _agreeToResearch);
    await prefs.setBool('agreedToNotifications', _agreeToNotifications);
    await prefs.setString('privacyConsentDate', DateTime.now().toIso8601String());

    debugPrint('✅ Privacy consent saved locally');

    // ✅ إذا كان هناك إنترنت ومستخدم، نحاول حفظ في Supabase
    if (_isOnline && user != null) {
      try {
        await _supabaseService.client.from('users').upsert({
          'id': user.id,
          'email': user.email ?? '',
          'full_name': user.userMetadata?['full_name'] ?? user.email?.split('@').first ?? 'User',
          'parent_consent': _agreeToTerms,
          'data_collection_consent': _agreeToDataCollection,
          'research_consent': _agreeToResearch,
          'notifications_consent': _agreeToNotifications,
          'privacy_consent_date': DateTime.now().toIso8601String(),
        });
        
        debugPrint('✅ Privacy consent saved to Supabase');
        await _removeFromPendingQueue();
        
      } catch (e) {
        debugPrint('⚠️ Failed to save to Supabase: $e');
        await _addToPendingQueue();
        _showMessage('⚠️ Saved locally. Will sync when online.', isError: false);
      }
    } else if (!_isOnline) {
      await _addToPendingQueue();
      _showMessage('📡 No internet. Saved locally. Will sync when online.', isError: false);
    }

    if (mounted) {
      setState(() => _isLoading = false);
      debugPrint('➡️ Navigating to Initial Questionnaire');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const InitialQuestionnaire()),
      );
    }
  }

  // ============================================================
  // ✅ إضافة إلى قائمة الانتظار
  // ============================================================
  Future<void> _addToPendingQueue() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final pending = prefs.getStringList('pending_privacy_consent') ?? [];
      
      final consentData = {
        'agreeToTerms': _agreeToTerms,
        'agreeToDataCollection': _agreeToDataCollection,
        'agreeToResearch': _agreeToResearch,
        'agreeToNotifications': _agreeToNotifications,
        'timestamp': DateTime.now().toIso8601String(),
      };
      
      pending.add(consentData.toString());
      await prefs.setStringList('pending_privacy_consent', pending);
      debugPrint('📁 Added to pending queue');
    } catch (e) {
      debugPrint('❌ Failed to add to pending queue: $e');
    }
  }

  // ============================================================
  // ✅ إزالة من قائمة الانتظار
  // ============================================================
  Future<void> _removeFromPendingQueue() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('pending_privacy_consent');
      debugPrint('🗑️ Removed from pending queue');
    } catch (e) {
      debugPrint('❌ Failed to remove from pending queue: $e');
    }
  }

  // ============================================================
  // ✅ عرض رسالة
  // ============================================================
  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? const Color(0xFFE76F51) : const Color(0xFF2D6A4F),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  bool get _allConsentsRequired => 
      _agreeToTerms && _agreeToDataCollection && _agreeToResearch;

  // ============================================================
  // BUILD
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
          'Privacy & Consent',
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
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                Icon(
                  _isOnline ? Icons.wifi : Icons.wifi_off,
                  color: _isOnline ? const Color(0xFF2D6A4F) : const Color(0xFFE76F51),
                  size: 20,
                ),
                const SizedBox(width: 4),
                Text(
                  _isOnline ? 'Online' : 'Offline',
                  style: TextStyle(
                    fontSize: 11,
                    color: _isOnline ? const Color(0xFF2D6A4F) : const Color(0xFFE76F51),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 24),
                    const Text(
                      'Please read the following carefully:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A2E),
                      ),
                    ).animate().fadeIn(duration: 500.ms, delay: 100.ms).moveY(begin: 20, end: 0),
                    const SizedBox(height: 16),
                    ..._privacyItems.asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;
                      return _buildPrivacyItem(item).animate().fadeIn(
                        duration: 400.ms,
                        delay: (150 + index * 50).ms,
                      ).moveY(begin: 15, end: 0);
                    }),
                    const SizedBox(height: 24),
                    _buildMedicalDisclaimer(),
                    const SizedBox(height: 32),
                    _buildConsentCheckbox(
                      value: _agreeToTerms,
                      onChanged: (value) {
                        setState(() {
                          _agreeToTerms = value ?? false;
                        });
                      },
                      text: 'I have read and agree to the',
                      linkText: 'Terms of Service',
                      onLinkTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const TermsScreen()),
                        );
                      },
                      required: true,
                    ).animate().fadeIn(duration: 400.ms, delay: 600.ms),
                    const SizedBox(height: 12),
                    _buildConsentCheckbox(
                      value: _agreeToDataCollection,
                      onChanged: (value) {
                        setState(() {
                          _agreeToDataCollection = value ?? false;
                        });
                      },
                      text: 'I consent to the collection and processing of my data to provide personalized recommendations',
                      required: true,
                    ).animate().fadeIn(duration: 400.ms, delay: 650.ms),
                    const SizedBox(height: 12),
                    _buildConsentCheckbox(
                      value: _agreeToResearch,
                      onChanged: (value) {
                        setState(() {
                          _agreeToResearch = value ?? false;
                        });
                      },
                      text: 'I agree to allow anonymized data to be used for research purposes to improve AI models',
                      required: true,
                    ).animate().fadeIn(duration: 400.ms, delay: 700.ms),
                    const SizedBox(height: 12),
                    _buildConsentCheckbox(
                      value: _agreeToNotifications,
                      onChanged: (value) {
                        setState(() {
                          _agreeToNotifications = value ?? false;
                        });
                      },
                      text: 'I would like to receive helpful tips and reminders (optional, can be changed later)',
                      required: false,
                    ).animate().fadeIn(duration: 400.ms, delay: 750.ms),
                    const SizedBox(height: 32),
                    if (_errorMessage.isNotEmpty)
                      _buildErrorMessage(),
                    _buildContinueButton(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // Header
  // ============================================================
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.25),
            Colors.white.withValues(alpha: 0.10),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [const Color(0xFF5235C5), const Color(0xFF7B2CBF)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF5235C5).withValues(alpha: 0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.privacy_tip,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'We take your privacy seriously',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A2E),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).moveY(begin: 20, end: 0);
  }

  // ============================================================
  // Medical Disclaimer
  // ============================================================
  Widget _buildMedicalDisclaimer() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFE76F51).withValues(alpha: 0.08),
            const Color(0xFFFF6B6B).withValues(alpha: 0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
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
              Icons.warning_amber_rounded,
              color: Color(0xFFE76F51),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'This app provides self-awareness recommendations only. It is not a substitute for professional medical or psychological advice.',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFFE76F51),
                height: 1.4,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms, delay: 500.ms).moveY(begin: 15, end: 0);
  }

  // ============================================================
  // Privacy Item
  // ============================================================
  Widget _buildPrivacyItem(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8E8EE), width: 1),
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
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (item['color'] as Color).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              item['icon'] as IconData,
              color: item['color'] as Color,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['title'] as String,
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item['description'] as String,
                  style: GoogleFonts.manrope(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF6B6B7A),
                    height: 1.5,
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
  // Consent Checkbox
  // ============================================================
  Widget _buildConsentCheckbox({
    required bool value,
    required ValueChanged<bool?> onChanged,
    required String text,
    String? linkText,
    VoidCallback? onLinkTap,
    required bool required,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 22,
          height: 22,
          child: Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF5E35B1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    color: const Color(0xFF1A1A2E),
                    height: 1.5,
                  ),
                  children: [
                    TextSpan(text: text),
                    if (linkText != null && onLinkTap != null) ...[
                      const TextSpan(text: ' '),
                      WidgetSpan(
                        child: GestureDetector(
                          onTap: onLinkTap,
                          child: Text(
                            linkText,
                            style: GoogleFonts.manrope(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF5235C5),
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                    ],
                    if (required)
                      const TextSpan(
                        text: ' *',
                        style: TextStyle(
                          color: Color(0xFFE76F51),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ),
              if (required && !value)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    'This consent is required to continue',
                    style: GoogleFonts.manrope(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFFE76F51),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // Error Message
  // ============================================================
  Widget _buildErrorMessage() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFE76F51).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE76F51).withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFE76F51), size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _errorMessage,
              style: GoogleFonts.manrope(
                color: const Color(0xFFE76F51),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  // ============================================================
  // Continue Button
  // ============================================================
  Widget _buildContinueButton() {
    final isEnabled = _allConsentsRequired;
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isEnabled ? _saveConsent : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isEnabled ? const Color(0xFF5235C5) : const Color(0xFFD1D1D8),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: isEnabled ? 4 : 0,
          shadowColor: isEnabled
              ? const Color(0xFF5235C5).withValues(alpha: 0.3)
              : Colors.transparent,
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
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isEnabled)
                    const Icon(Icons.check_circle, size: 20),
                  if (isEnabled) const SizedBox(width: 8),
                  Text(
                    isEnabled ? 'I Agree & Continue' : 'Please Accept All Required Terms',
                    style: GoogleFonts.manrope(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isEnabled ? Colors.white : const Color(0xFF8A8A9A),
                    ),
                  ),
                ],
              ),
      ),
    ).animate().fadeIn(duration: 500.ms, delay: 800.ms).scale(
      begin: const Offset(0.95, 0.95),
      end: const Offset(1.0, 1.0),
      duration: 400.ms,
      delay: 800.ms,
    );
  }
}