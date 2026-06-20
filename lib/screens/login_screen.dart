// ============================================================
// 📄 lib/screens/login_screen.dart
// ✅ صفحة تسجيل الدخول - نسخة محسّنة ومتينة
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'signup_screen.dart';
import 'forgot_password_screen.dart';
import 'home_dashboard.dart';
import 'onboarding_screen.dart';
import 'privacy_consent_screen.dart';
import 'initial_questionnaire.dart';
import '../services/supabase_service.dart';
import '../services/google_auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _userNameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  String _errorMessage = '';
  final supabaseService = SupabaseService();

@override
void initState() {
  super.initState();
  // ✅ بيانات تجريبية لتسهيل التحقق من التطبيق
  // _userNameController.text = 'aalhayek7@smail.ucas.edu.ps';
  // _passwordController.text = '123456';
  _checkIfLoggedIn();
}

  @override
  void dispose() {
    _userNameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ============================================================
  // ✅ التحقق من حالة تسجيل الدخول
  // ============================================================
  Future<void> _checkIfLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

      if (isLoggedIn && mounted) {
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) _navigateBasedOnStatus();
      }
    } catch (e) {
      debugPrint('⚠️ _checkIfLoggedIn failed: $e');
      // ✅ لا نوقف التطبيق - فقط نترك المستخدم في شاشة تسجيل الدخول
    }
  }

  // ============================================================
  // ✅ التوجيه حسب حالة المستخدم
  // ============================================================
  Future<void> _navigateBasedOnStatus() async {
    if (!mounted) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final isGuest = prefs.getBool('isGuest') ?? false;
      final hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;
      final hasAcceptedPrivacy = prefs.getBool('hasAcceptedPrivacy') ?? false;
      final hasCompletedQuestionnaire =
          prefs.getBool('hasCompletedQuestionnaire') ?? false;

      debugPrint('🔐 Login -> Checking user status:');
      debugPrint('   isGuest: $isGuest');
      debugPrint('   hasSeenOnboarding: $hasSeenOnboarding');
      debugPrint('   hasAcceptedPrivacy: $hasAcceptedPrivacy');
      debugPrint('   hasCompletedQuestionnaire: $hasCompletedQuestionnaire');

      if (!mounted) return;

      if (isGuest) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeDashboard()),
        );
        return;
      }

      if (!hasSeenOnboarding) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const OnboardingScreen()),
        );
      } else if (!hasAcceptedPrivacy) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const PrivacyConsentScreen()),
        );
      } else if (!hasCompletedQuestionnaire) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const InitialQuestionnaire()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeDashboard()),
        );
      }
    } catch (e) {
      debugPrint('⚠️ _navigateBasedOnStatus failed: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Something went wrong. Please try again.';
        });
      }
    }
  }

// ============================================================
// ✅ تسجيل الدخول بـ Email/Password (يعمل لأي حساب)
// ============================================================
Future<void> _login() async {
  if (_isLoading) return;

  final email = _userNameController.text.trim();
  final password = _passwordController.text.trim();

  if (email.isEmpty || password.isEmpty) {
    setState(() {
      _errorMessage = 'Please enter both email and password';
    });
    return;
  }

  setState(() {
    _isLoading = true;
    _errorMessage = '';
  });

  try {
    final response = await supabaseService.signIn(email, password);

    if (response.user != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setBool('isGuest', false);
      await prefs.setString('loggedInUser', email);

      if (mounted) {
        await _navigateBasedOnStatus();
      }
    } else {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Invalid email or password';
        });
      }
    }
  } catch (e) {
    debugPrint('🔥 Login error: $e');
    if (mounted) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Invalid email or password';
      });
    }
  }
}

  // ============================================================
  // ✅ تسجيل الدخول عبر Facebook (للعرض التوضيحي فقط - Demo)
  // ============================================================
  Future<void> _loginWithFacebook() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      await Future.delayed(const Duration(milliseconds: 800));

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('loggedInUser', 'Facebook_User');

      if (mounted) {
        await _navigateBasedOnStatus();
      }
    } catch (e) {
      debugPrint('⚠️ Facebook demo login failed: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Something went wrong. Please try again.';
        });
      }
    }
  }

  // ============================================================
  // ✅ تسجيل الدخول عبر Google (حقيقي)
  // ============================================================
  Future<void> _loginWithGoogle() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await GoogleAuthService.signInWithGoogle();

      if (response != null && response.user != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString(
          'loggedInUser',
          response.user!.email ?? 'Google_User',
        );

        if (mounted) {
          await _navigateBasedOnStatus();
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _errorMessage = 'Google sign-in cancelled or failed';
          });
        }
      }
    } catch (e) {
      debugPrint('🔥 Google login error: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Google sign-in error. Please try again.';
        });
      }
    }
  }

  // ============================================================
  // ✅ تسجيل الدخول عبر Apple (للعرض التوضيحي فقط - Demo)
  // ============================================================
  Future<void> _loginWithApple() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      await Future.delayed(const Duration(milliseconds: 800));

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('loggedInUser', 'Apple_User');

      if (mounted) {
        await _navigateBasedOnStatus();
      }
    } catch (e) {
      debugPrint('⚠️ Apple demo login failed: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Something went wrong. Please try again.';
        });
      }
    }
  }

// ============================================================
// ✅ تسجيل الدخول كـ "ضيف" (بحساب حقيقي لتجربة سلسة للجنة التحكيم)
// ============================================================
Future<void> _loginAsGuest() async {
  if (_isLoading) return;

  setState(() {
    _isLoading = true;
    _errorMessage = '';
  });

  // ✅ حساب حقيقي مُعدّ مسبقاً للجنة التحكيم
  const guestEmail = 'aalhayek7@smail.ucas.edu.ps';
  const guestPassword = '123456';

  try {
    // ✅ تعبئة الحقول (للمظهر فقط)
    _userNameController.text = guestEmail;
    _passwordController.text = guestPassword;

    // ✅ محاولة تسجيل الدخول إلى Supabase
    final response = await supabaseService.signIn(guestEmail, guestPassword);

    if (response.user != null) {
      // ✅ تم تسجيل الدخول بنجاح
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setBool('isGuest', false); // ليس ضيفاً، بل حساب حقيقي
      await prefs.setString('loggedInUser', guestEmail);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Logged in successfully as Demo User'),
            backgroundColor: Color(0xFF2D6A4F),
            duration: Duration(seconds: 2),
          ),
        );
        await _navigateBasedOnStatus();
      }
    } else {
      // ❌ في حال فشل تسجيل الدخول (مثلاً الحساب غير موجود)
      await _createGuestAccount(); // نحاول إنشاؤه
    }
  } catch (e) {
    debugPrint('⚠️ Guest login failed: $e');
    // ✅ في حال فشل تسجيل الدخول بسبب عدم وجود إنترنت أو الحساب
    await _createGuestAccount();
  }
}

// ============================================================
// ✅ إنشاء حساب الضيف تلقائياً إذا لم يكن موجوداً
// ============================================================
Future<void> _createGuestAccount() async {
  try {
    const guestEmail = 'aalhayek7@smail.ucas.edu.ps';
    const guestPassword = '123456';

    // ✅ إنشاء الحساب في Supabase
    await supabaseService.signUp(
      email: guestEmail,
      password: guestPassword,
      fullName: 'Demo User (Judge Account)',
    );

    // ✅ بعد الإنشاء، نسجل الدخول تلقائياً
    final response = await supabaseService.signIn(guestEmail, guestPassword);

    if (response.user != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setBool('isGuest', false);
      await prefs.setString('loggedInUser', guestEmail);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Demo account created and logged in!'),
            backgroundColor: Color(0xFF2D6A4F),
            duration: Duration(seconds: 2),
          ),
        );
        await _navigateBasedOnStatus();
      }
    }
  } catch (e) {
    debugPrint('⚠️ Guest account creation failed: $e');
    if (mounted) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Could not create demo account. Please try again.';
      });
    }
  }
}

  // ============================================================
  // ✅ بناء واجهة المستخدم
  // ============================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FF),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ✅ الشعار
              Center(
                    child: Image.asset(
                      'assets/images/LOGO.png',
                      width: 100,
                      height: 100,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF5E35B1,
                            ).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: const Icon(
                            Icons.psychology,
                            size: 50,
                            color: Color(0xFF5E35B1),
                          ),
                        );
                      },
                    ),
                  )
                  .animate()
                  .scale(duration: 500.ms, curve: Curves.easeOutBack)
                  .fadeIn(duration: 400.ms),

              const SizedBox(height: 20),

              // ✅ Welcome
              const Text(
                    'Welcome',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5E35B1),
                      letterSpacing: 1.2,
                    ),
                  )
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 100.ms)
                  .moveY(begin: 15, end: 0, duration: 400.ms, delay: 100.ms),

              const SizedBox(height: 8),

              // ✅ log in to continue...
              const Text(
                    'log in to continue...',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF6B6B7A),
                      letterSpacing: 0.5,
                    ),
                  )
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 150.ms)
                  .moveY(begin: 15, end: 0, duration: 400.ms, delay: 150.ms),

              const SizedBox(height: 48),

              // ✅ رسالة الخطأ
              if (_errorMessage.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE76F51).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFE76F51).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Color(0xFFE76F51),
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _errorMessage,
                          style: const TextStyle(
                            color: Color(0xFFE76F51),
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 300.ms).moveY(begin: 10, end: 0),

              // ✅ Email Field
              Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDFDFF),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFDEDCFF),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(
                            0xFF5E35B1,
                          ).withValues(alpha: 0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _userNameController,
                      enabled: !_isLoading,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF1A1A2E),
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Email Address',
                        hintStyle: TextStyle(
                          color: Color(0xFFBDBDBD),
                          fontSize: 15,
                          fontWeight: FontWeight.normal,
                        ),
                        prefixIcon: Icon(
                          Icons.person_outline,
                          color: Color(0xFFA5A5C0),
                          size: 22,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                      ),
                    ),
                  )
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 200.ms)
                  .moveY(begin: 20, end: 0, duration: 400.ms, delay: 200.ms),

              const SizedBox(height: 16),

              // ✅ Password Field
              Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDFDFF),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFDEDCFF),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(
                            0xFF5E35B1,
                          ).withValues(alpha: 0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _passwordController,
                      enabled: !_isLoading,
                      obscureText: !_isPasswordVisible,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF1A1A2E),
                      ),
                      decoration: InputDecoration(
                        hintText: 'Password',
                        hintStyle: const TextStyle(
                          color: Color(0xFFBDBDBD),
                          fontSize: 15,
                          fontWeight: FontWeight.normal,
                        ),
                        prefixIcon: const Icon(
                          Icons.key,
                          color: Color(0xFFA5A5C0),
                          size: 22,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: const Color(0xFFA5A5C0),
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                      ),
                    ),
                  )
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 250.ms)
                  .moveY(begin: 20, end: 0, duration: 400.ms, delay: 250.ms),

              const SizedBox(height: 8),

              // ✅ Forget Password
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ForgotPasswordScreen(),
                            ),
                          );
                        },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 4,
                    ),
                  ),
                  child: const Text(
                    'Forget Password?',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF6B6B7A),
                    ),
                  ),
                ),
              ).animate().fadeIn(duration: 400.ms, delay: 300.ms),

              const SizedBox(height: 16),

              // ✅ Sign Up Link
              Center(
                child: GestureDetector(
                  onTap: _isLoading
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignupScreen(),
                            ),
                          );
                        },
                  child: RichText(
                    text: const TextSpan(
                      text: "Don't Have Account ? ",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1A1A2E),
                      ),
                      children: [
                        TextSpan(
                          text: 'Sign Up',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF5E35B1),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ).animate().fadeIn(duration: 400.ms, delay: 350.ms),

              const SizedBox(height: 32),

              // ✅ Log In Button
              SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5E35B1),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor:
                            const Color(0xFF5E35B1).withValues(alpha: 0.6),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 4,
                        shadowColor: const Color(
                          0xFF5E35B1,
                        ).withValues(alpha: 0.3),
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
                          : const Text(
                              'Log In',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                    ),
                  )
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 400.ms)
                  .scale(
                    begin: const Offset(0.96, 0.96),
                    end: const Offset(1.0, 1.0),
                    duration: 400.ms,
                    delay: 400.ms,
                  ),

              const SizedBox(height: 16),

              // ✅ Guest Button
              SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _isLoading ? null : _loginAsGuest,
                      icon: const Icon(
                        Icons.person_outline_rounded,
                        size: 20,
                        color: Color(0xFF8A8A9A),
                      ),
                      label: const Text(
                        'Continue as Guest',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF8A8A9A),
                          letterSpacing: 0.3,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        side: const BorderSide(
                          color: Color(0xFFDEDCFF),
                          width: 1.5,
                        ),
                        backgroundColor: Colors.white,
                      ),
                    ),
                  )
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 430.ms)
                  .moveY(begin: 10, end: 0, duration: 400.ms, delay: 430.ms),

              const SizedBox(height: 32),

              // ✅ Or Sign Up Via
              const Center(
                child: Text(
                  'Or Sign Up Via',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF8A8A9A),
                    letterSpacing: 0.8,
                  ),
                ),
              ).animate().fadeIn(duration: 400.ms, delay: 450.ms),

              const SizedBox(height: 20),

              // ✅ Social Buttons (أيقونات FontAwesome الحقيقية)
              Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildSocialButton(
                        icon: FontAwesomeIcons.facebookF,
                        color: const Color(0xFF1877F2),
                        onTap: _loginWithFacebook,
                        enabled: !_isLoading,
                      ),
                      const SizedBox(width: 20),
                      _buildSocialButton(
                        icon: FontAwesomeIcons.google,
                        color: const Color(0xFF4285F4),
                        onTap: _loginWithGoogle,
                        enabled: !_isLoading,
                      ),
                      const SizedBox(width: 20),
                      _buildSocialButton(
                        icon: FontAwesomeIcons.apple,
                        color: Colors.black,
                        onTap: _loginWithApple,
                        enabled: !_isLoading,
                      ),
                    ],
                  )
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 500.ms)
                  .scale(
                    begin: const Offset(0.95, 0.95),
                    end: const Offset(1.0, 1.0),
                    duration: 400.ms,
                    delay: 500.ms,
                  ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // ✅ بناء زر التواصل الاجتماعي
  // ============================================================
  Widget _buildSocialButton({
    required FaIconData icon,
    required Color color,
    required VoidCallback onTap,
    bool enabled = true,
    Color? backgroundColor,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Opacity(
        opacity: enabled ? 1.0 : 0.5,
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: backgroundColor ?? Colors.white,
            border: Border.all(color: const Color(0xFFE8E8EE), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: FaIcon(icon, size: 22, color: color),
          ),
        ),
      ),
    );
  }
}