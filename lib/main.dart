// ============================================================
// 📄 lib/main.dart
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ تحميل المتغيرات البيئية من ملف .env
  try {
    await dotenv.load(fileName: ".env");
    debugPrint('✅ .env loaded successfully');
  } catch (e) {
    debugPrint('❌ Error loading .env: $e');
  }

  // ✅ تهيئة Supabase
  // ⚠️ لا تضع مفاتيح حقيقية كقيم افتراضية ثابتة في الكود لأسباب أمنية.
  // تأكد من وجود ملف .env يحتوي على:
  // SUPABASE_URL=...
  // SUPABASE_ANON_KEY=...
  final supabaseUrl = dotenv.env['SUPABASE_URL'];
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];

  if (supabaseUrl == null || supabaseAnonKey == null) {
    debugPrint(
      '❌ SUPABASE_URL أو SUPABASE_ANON_KEY غير موجودة في ملف .env. '
      'تأكد من إضافة ملف .env في جذر المشروع وتضمينه في pubspec.yaml (assets).',
    );
  }

  await Supabase.initialize(
    url: supabaseUrl ?? '',
    anonKey: supabaseAnonKey ?? '',
  );

  runApp(const MentalLoadApp());
}

class MentalLoadApp extends StatelessWidget {
  const MentalLoadApp({super.key});

  @override
  Widget build(BuildContext context) {
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
        fontFamily: 'Manrope',
      ),
      // ✅ تظهر SplashScreen دائماً عند فتح التطبيق.
      // كل منطق فحص حالة المستخدم (isLoggedIn, hasSeenOnboarding...)
      // والتنقل بعد ذلك موجود بالكامل داخل splash_screen.dart
      home: const SplashScreen(),
    );
  }
}