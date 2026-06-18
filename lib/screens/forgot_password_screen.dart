// lib/screens/forgot_password_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  bool _showResetForm = false;
  String _errorMessage = '';
  String _successMessage = '';

  // التحقق من وجود المستخدم
  Future<void> _checkUser() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your email';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    await Future.delayed(const Duration(milliseconds: 500));

    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('userEmail');
    final savedUsername = prefs.getString('username');

    if (savedEmail == email || savedUsername == email) {
      setState(() {
        _showResetForm = true;
        _errorMessage = '';
        _isLoading = false;
      });
    } else {
      setState(() {
        _errorMessage = 'No account found with this email/username';
        _isLoading = false;
      });
    }
  }

  // إعادة تعيين كلمة المرور
  Future<void> _resetPassword() async {
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      setState(() {
        _errorMessage = 'Please fill all fields';
      });
      return;
    }

    if (newPassword != confirmPassword) {
      setState(() {
        _errorMessage = 'Passwords do not match';
      });
      return;
    }

    if (newPassword.length < 6) {
      setState(() {
        _errorMessage = 'Password must be at least 6 characters';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    await Future.delayed(const Duration(milliseconds: 500));

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('password', newPassword);

    setState(() {
      _successMessage = 'Password reset successfully!';
      _isLoading = false;
    });

    // العودة إلى صفحة تسجيل الدخول بعد 2 ثانية
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF5235C5)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Forgot Password',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A2E),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              // الشعار
              Center(
                child: Image.asset(
                  'assets/images/LOGO.png',
                  width: 80,
                  height: 80,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: const Color(0xFF5235C5).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.lock_reset,
                        size: 40,
                        color: Color(0xFF5235C5),
                      ),
                    );
                  },
                ).animate().scale(
                  duration: 600.ms,
                  curve: Curves.easeOutBack,
                ).fadeIn(duration: 500.ms),
              ),
              const SizedBox(height: 24),
              // العنوان الرئيسي
              const Center(
                child: Text(
                  'Reset Password',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5235C5),
                    letterSpacing: 1.2,
                  ),
                ),
              ).animate().fadeIn(duration: 500.ms, delay: 100.ms).moveY(
                begin: 20,
                end: 0,
                duration: 500.ms,
                delay: 100.ms,
              ),
              const SizedBox(height: 12),
              // النص الوصفي
              const Center(
                child: Text(
                  'Enter your email to reset your password',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF8A8A9A),
                    letterSpacing: 0.5,
                  ),
                ),
              ).animate().fadeIn(duration: 500.ms, delay: 200.ms).moveY(
                begin: 20,
                end: 0,
                duration: 500.ms,
                delay: 200.ms,
              ),
              const SizedBox(height: 48),
              // رسالة الخطأ
              if (_errorMessage.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE76F51).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE76F51).withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Color(0xFFE76F51), size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage,
                          style: const TextStyle(color: Color(0xFFE76F51), fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              // رسالة النجاح
              if (_successMessage.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2D6A4F).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF2D6A4F).withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Color(0xFF2D6A4F), size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _successMessage,
                          style: const TextStyle(color: Color(0xFF2D6A4F), fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              // حقل Email/Username
              if (!_showResetForm)
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFF5235C5).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF5235C5).withValues(alpha: 0.5), width: 1.5),
                  ),
                  child: TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: Color(0xFF1A1A2E)),
                    decoration: const InputDecoration(
                      hintText: 'Email or Username',
                      hintStyle: TextStyle(
                        color: Color(0xFF5235C5),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      prefixIcon: Icon(
                        Icons.email_outlined,  // ✅ تم التصحيح من email_outline إلى email_outlined
                        color: Color(0xFF5235C5),
                        size: 20,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    ),
                  ),
                ).animate().fadeIn(duration: 500.ms, delay: 300.ms).moveY(
                  begin: 20,
                  end: 0,
                  duration: 500.ms,
                  delay: 300.ms,
                ),
              // نموذج إعادة تعيين كلمة المرور
              if (_showResetForm) ...[
                // حقل كلمة المرور الجديدة
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFF5235C5).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF5235C5).withValues(alpha: 0.5), width: 1.5),
                  ),
                  child: TextField(
                    controller: _newPasswordController,
                    obscureText: !_isNewPasswordVisible,
                    style: const TextStyle(color: Color(0xFF1A1A2E)),
                    decoration: InputDecoration(
                      hintText: 'New Password',
                      hintStyle: const TextStyle(
                        color: Color(0xFF5235C5),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      prefixIcon: const Icon(
                        Icons.lock_outline,
                        color: Color(0xFF5235C5),
                        size: 20,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isNewPasswordVisible ? Icons.visibility_off : Icons.visibility,
                          color: const Color(0xFF5235C5),
                        ),
                        onPressed: () {
                          setState(() {
                            _isNewPasswordVisible = !_isNewPasswordVisible;
                          });
                        },
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    ),
                  ),
                ).animate().fadeIn(duration: 500.ms, delay: 400.ms).moveY(
                  begin: 20,
                  end: 0,
                  duration: 500.ms,
                  delay: 400.ms,
                ),
                const SizedBox(height: 12),
                // حقل تأكيد كلمة المرور
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFF5235C5).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF5235C5).withValues(alpha: 0.5), width: 1.5),
                  ),
                  child: TextField(
                    controller: _confirmPasswordController,
                    obscureText: !_isConfirmPasswordVisible,
                    style: const TextStyle(color: Color(0xFF1A1A2E)),
                    decoration: InputDecoration(
                      hintText: 'Confirm Password',
                      hintStyle: const TextStyle(
                        color: Color(0xFF5235C5),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      prefixIcon: const Icon(
                        Icons.lock_outline,
                        color: Color(0xFF5235C5),
                        size: 20,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isConfirmPasswordVisible ? Icons.visibility_off : Icons.visibility,
                          color: const Color(0xFF5235C5),
                        ),
                        onPressed: () {
                          setState(() {
                            _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                          });
                        },
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    ),
                  ),
                ).animate().fadeIn(duration: 500.ms, delay: 500.ms).moveY(
                  begin: 20,
                  end: 0,
                  duration: 500.ms,
                  delay: 500.ms,
                ),
              ],
              const SizedBox(height: 32),
              // زر الإجراء
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _showResetForm ? _resetPassword : _checkUser,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5235C5),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          _showResetForm ? 'Reset Password' : 'Verify Email',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                ),
              ).animate().fadeIn(duration: 500.ms, delay: 600.ms).scale(
                begin: const Offset(0.95, 0.95),
                end: const Offset(1.0, 1.0),
                duration: 400.ms,
                delay: 600.ms,
              ),
              const SizedBox(height: 24),
              // العودة إلى تسجيل الدخول
              Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                    );
                  },
                  child: RichText(
                    text: const TextSpan(
                      text: "Remember your password? ",
                      style: TextStyle(fontSize: 13, color: Color(0xFF6B6B7A)),
                      children: [
                        TextSpan(
                          text: 'Back to Login',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF5235C5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ).animate().fadeIn(duration: 500.ms, delay: 700.ms),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}