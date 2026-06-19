// lib/screens/forgot_password_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;
  String _errorMessage = '';
  String _successMessage = '';

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,}$');
    return emailRegex.hasMatch(email);
  }

  // ✅ إرسال رابط إعادة تعيين كلمة المرور الحقيقي عبر Supabase
  Future<void> _sendResetLink() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      setState(() => _errorMessage = 'Please enter your email');
      return;
    }

    if (!_isValidEmail(email)) {
      setState(() => _errorMessage = 'Please enter a valid email address');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      await Supabase.instance.client.auth.resetPasswordForEmail(email);

      setState(() {
        _emailSent = true;
        _isLoading = false;
        _successMessage =
            'A password reset link has been sent to $email. '
            'Open it from your email to set a new password.';
      });
    } on AuthException catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.message;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Something went wrong. Please try again.';
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
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
              Center(
                child: Text(
                  _emailSent
                      ? 'Check your inbox to continue'
                      : 'Enter your email to receive a reset link',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
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

              // حقل البريد (يُخفى بعد الإرسال الناجح)
              if (!_emailSent)
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
                      hintText: 'Email Address',
                      hintStyle: TextStyle(
                        color: Color(0xFF5235C5),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      prefixIcon: Icon(
                        Icons.email_outlined,
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

              const SizedBox(height: 32),

              // زر الإجراء
              if (!_emailSent)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _sendResetLink,
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
                        : const Text(
                            'Send Reset Link',
                            style: TextStyle(
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

              // زر إعادة الإرسال (بعد النجاح)
              if (_emailSent)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _isLoading
                        ? null
                        : () => setState(() {
                              _emailSent = false;
                              _successMessage = '';
                            }),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      side: const BorderSide(color: Color(0xFF5235C5)),
                    ),
                    child: const Text(
                      'Send to a different email',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF5235C5),
                      ),
                    ),
                  ),
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