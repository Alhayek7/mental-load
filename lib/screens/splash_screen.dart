// ============================================================
// 📄 lib/screens/splash_screen.dart
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'onboarding_screen.dart';
import 'login_screen.dart';
import 'privacy_consent_screen.dart';
import 'initial_questionnaire.dart';
import 'home_dashboard.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    // ✅ الانتظار 2.5 ثانية لظهور الشاشة
    await Future.delayed(const Duration(milliseconds: 2500));

    final prefs = await SharedPreferences.getInstance();
    
    // ✅ التحقق من حالة المستخدم
    final hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;
    final hasAcceptedPrivacy = prefs.getBool('hasAcceptedPrivacy') ?? false;
    final hasCompletedQuestionnaire = prefs.getBool('hasCompletedQuestionnaire') ?? false;
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    debugPrint('🚀 Splash -> Checking user status:');
    debugPrint('   isLoggedIn: $isLoggedIn');
    debugPrint('   hasSeenOnboarding: $hasSeenOnboarding');
    debugPrint('   hasAcceptedPrivacy: $hasAcceptedPrivacy');
    debugPrint('   hasCompletedQuestionnaire: $hasCompletedQuestionnaire');

    if (!mounted) return;

    if (!isLoggedIn) {
      // ❌ غير مسجل دخول → شاشة تسجيل الدخول
      debugPrint('➡️ Redirecting to Login Screen');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } else if (!hasSeenOnboarding) {
      // ❌ لم يشاهد الترحيب → شاشة الترحيب
      debugPrint('➡️ Redirecting to Onboarding Screen');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const OnboardingScreen()),
      );
    } else if (!hasAcceptedPrivacy) {
      // ❌ لم يوافق على الخصوصية → شاشة الخصوصية
      debugPrint('➡️ Redirecting to Privacy Consent Screen');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const PrivacyConsentScreen()),
      );
    } else if (!hasCompletedQuestionnaire) {
      // ❌ لم يكمل الاستبيان → شاشة الاستبيان
      debugPrint('➡️ Redirecting to Initial Questionnaire');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const InitialQuestionnaire()),
      );
    } else {
      // ✅ كل شيء مكتمل → الصفحة الرئيسية
      debugPrint('➡️ Redirecting to Home Dashboard');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeDashboard()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF5235C5).withOpacity(0.15),
              const Color(0xFF1A5F7A).withOpacity(0.10),
              const Color(0xFF2D6A4F).withOpacity(0.15),
              Colors.white.withOpacity(0.95),
            ],
            stops: const [0.0, 0.3, 0.6, 1.0],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // القسم الأول: الصورة (شعار + اسم التطبيق)
            Expanded(
              flex: 3,
              child: Center(
                child: Image.asset(
                  'assets/images/splash2.png',
                  width: 220,
                  height: 220,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        color: const Color(0xFF5235C5).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: const Icon(
                        Icons.psychology,
                        size: 90,
                        color: Color(0xFF5235C5),
                      ),
                    );
                  },
                ).animate(
                  onPlay: (controller) => controller.repeat(reverse: true),
                ).scale(
                  begin: const Offset(0.9, 0.9),
                  end: const Offset(1.0, 1.0),
                  duration: 1200.ms,
                  curve: Curves.easeInOutSine,
                ).fadeIn(
                  duration: 600.ms,
                  curve: Curves.easeOut,
                ),
              ),
            ),
            // القسم الثاني: النص (Your AI Assistant...)
            Expanded(
              flex: 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withOpacity(0.25),
                          Colors.white.withOpacity(0.10),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Text(
                      'Your AI Assistant For\nCognitive Overload Management',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1A5F7A),
                        height: 1.5,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ).animate(
                    onPlay: (controller) => controller.repeat(reverse: true),
                  ).shimmer(
                    duration: 1800.ms,
                    color: const Color(0xFF5235C5).withOpacity(0.3),
                  ).fadeIn(
                    duration: 800.ms,
                    delay: 300.ms,
                    curve: Curves.easeOut,
                  ).moveY(
                    begin: 20,
                    end: 0,
                    duration: 600.ms,
                    delay: 300.ms,
                    curve: Curves.easeOut,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}