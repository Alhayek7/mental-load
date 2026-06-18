// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'signup_screen.dart';
import 'forgot_password_screen.dart';
import 'home_dashboard.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';
import 'onboarding_screen.dart';
import 'privacy_consent_screen.dart';
import 'initial_questionnaire.dart';

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
    _userNameController.text = 'aalhayek7@smail.ucas.edu.ps';
    _passwordController.text = '123456';
    _checkIfLoggedIn();
  }

  Future<void> _clearAllPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // مسح جميع البيانات المخزنة
    print('✅ All SharedPreferences cleared');
  }

  @override
  void dispose() {
    _userNameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _checkIfLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (isLoggedIn) {
      if (mounted) {
        await Future.delayed(const Duration(milliseconds: 500));
        // ✅ استخدم الدالة الجديدة
        _navigateBasedOnStatus();
      }
    }
  }

  Future<void> _navigateBasedOnStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;
    final hasAcceptedPrivacy = prefs.getBool('hasAcceptedPrivacy') ?? false;
    final hasCompletedQuestionnaire =
        prefs.getBool('hasCompletedQuestionnaire') ?? false;

    debugPrint('🔐 Login -> Checking user status:');
    debugPrint('   hasSeenOnboarding: $hasSeenOnboarding');
    debugPrint('   hasAcceptedPrivacy: $hasAcceptedPrivacy');
    debugPrint('   hasCompletedQuestionnaire: $hasCompletedQuestionnaire');

    if (!hasSeenOnboarding) {
      debugPrint('➡️ Redirecting to Onboarding Screen');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const OnboardingScreen()),
      );
    } else if (!hasAcceptedPrivacy) {
      debugPrint('➡️ Redirecting to Privacy Consent Screen');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const PrivacyConsentScreen()),
      );
    } else if (!hasCompletedQuestionnaire) {
      debugPrint('➡️ Redirecting to Initial Questionnaire');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const InitialQuestionnaire()),
      );
    } else {
      debugPrint('➡️ Redirecting to Home Dashboard');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeDashboard()),
      );
    }
  }

  Future<void> _login() async {
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
        // ✅ حفظ حالة تسجيل الدخول في SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('loggedInUser', email);

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeDashboard()),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Invalid email or password';
      });
    }
  }

  Future<void> _loginWithFacebook() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    await Future.delayed(const Duration(milliseconds: 800));

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', 'Facebook_User');
    await prefs.setString('userEmail', 'user@facebook.com');
    await prefs.setString('loginMethod', 'facebook');
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('loggedInUser', 'Facebook_User');

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeDashboard()),
      );
    }
  }

  Future<void> _loginWithGoogle() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    await Future.delayed(const Duration(milliseconds: 800));

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', 'Google_User');
    await prefs.setString('userEmail', 'user@gmail.com');
    await prefs.setString('loginMethod', 'google');
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('loggedInUser', 'Google_User');

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeDashboard()),
      );
    }
  }

  Future<void> _loginWithApple() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    await Future.delayed(const Duration(milliseconds: 800));

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', 'Apple_User');
    await prefs.setString('userEmail', 'user@icloud.com');
    await prefs.setString('loginMethod', 'apple');
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('loggedInUser', 'Apple_User');

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeDashboard()),
      );
    }
  }

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
              // الشعار
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

              // Welcome
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

              // log in to continue...
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

              // رسالة الخطأ
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

              // User Name
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

              // Password
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

              // Forget Password
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
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

              // Sign Up Link
              Center(
                child: GestureDetector(
                  onTap: () {
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

              // Log In Button
              SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5E35B1),
                        foregroundColor: Colors.white,
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

              const SizedBox(height: 40),

              // Or Sign Up Via
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

              // Social Buttons (بدون FontAwesome)
              Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildSocialButton(
                        icon: Icons.facebook,
                        label: 'f',
                        onTap: _loginWithFacebook,
                      ),
                      const SizedBox(width: 24),
                      _buildSocialButton(
                        icon: Icons.g_mobiledata,
                        label: 'G',
                        onTap: _loginWithGoogle,
                      ),
                      const SizedBox(width: 24),
                      _buildSocialButton(
                        icon: Icons.apple,
                        label: '🍎',
                        onTap: _loginWithApple,
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

  Widget _buildSocialButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
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
          child: icon == Icons.apple
              ? Text(
                  label,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5E35B1),
                  ),
                )
              : Icon(icon, size: 24, color: const Color(0xFF5E35B1)),
        ),
      ),
    );
  }
}
