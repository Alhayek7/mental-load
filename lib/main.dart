// ============================================================
// 📄 lib/main.dart
// ============================================================

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/login_screen.dart';
import 'screens/privacy_consent_screen.dart';
import 'screens/initial_questionnaire.dart';
import 'screens/home_dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ تهيئة Supabase
  await Supabase.initialize(
    url: 'https://orjgxyxxuoqjyhivpifb.supabase.co',
    anonKey: 'sb_publishable_eE4xLtu7v2Aq9FCeZJnZSw_oMpqw1jJ',
  );

  runApp(const MentalLoadApp());
}

class MentalLoadApp extends StatefulWidget {
  const MentalLoadApp({super.key});

  @override
  State<MentalLoadApp> createState() => _MentalLoadAppState();
}

class _MentalLoadAppState extends State<MentalLoadApp> {
  bool _isLoading = true;
  String _initialRoute = 'splash';

  @override
  void initState() {
    super.initState();
    _checkInitialRoute();
  }

  Future<void> _checkInitialRoute() async {
    final prefs = await SharedPreferences.getInstance();
    
    // ✅ التحقق من حالة المستخدم
    final hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;
    final hasAcceptedPrivacy = prefs.getBool('hasAcceptedPrivacy') ?? false;
    final hasCompletedQuestionnaire = prefs.getBool('hasCompletedQuestionnaire') ?? false;
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    debugPrint('📊 User Status:');
    debugPrint('   isLoggedIn: $isLoggedIn');
    debugPrint('   hasSeenOnboarding: $hasSeenOnboarding');
    debugPrint('   hasAcceptedPrivacy: $hasAcceptedPrivacy');
    debugPrint('   hasCompletedQuestionnaire: $hasCompletedQuestionnaire');

    setState(() {
      _isLoading = false;
      
      if (!isLoggedIn) {
        // ❌ غير مسجل دخول → شاشة تسجيل الدخول
        _initialRoute = 'login';
      } else if (!hasSeenOnboarding) {
        // ❌ لم يشاهد الترحيب → شاشة الترحيب
        _initialRoute = 'onboarding';
      } else if (!hasAcceptedPrivacy) {
        // ❌ لم يوافق على الخصوصية → شاشة الخصوصية
        _initialRoute = 'privacy';
      } else if (!hasCompletedQuestionnaire) {
        // ❌ لم يكمل الاستبيان → شاشة الاستبيان
        _initialRoute = 'questionnaire';
      } else {
        // ✅ كل شيء مكتمل → الصفحة الرئيسية
        _initialRoute = 'home';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const MaterialApp(
        home: Scaffold(
          backgroundColor: Color(0xFFF8F7FF),
          body: Center(
            child: CircularProgressIndicator(color: Color(0xFF5E35B1)),
          ),
        ),
      );
    }

    return MaterialApp(
      title: 'Mental Load',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: const Color(0xFF5E35B1),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5E35B1),
          primary: const Color(0xFF5E35B1),
        ),
        scaffoldBackgroundColor: const Color(0xFFF8F7FF),
        fontFamily: 'Inter',
      ),
      home: _getInitialScreen(),
    );
  }

  Widget _getInitialScreen() {
    switch (_initialRoute) {
      case 'splash':
        return const SplashScreen();
      case 'login':
        return const LoginScreen();
      case 'onboarding':
        return const OnboardingScreen();
      case 'privacy':
        return const PrivacyConsentScreen();
      case 'questionnaire':
        return const InitialQuestionnaire();
      case 'home':
        return const HomeDashboard();
      default:
        return const SplashScreen();
    }
  }
}