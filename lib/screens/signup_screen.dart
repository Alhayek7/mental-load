// lib/screens/signup_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'privacy_consent_screen.dart';
import 'terms_screen.dart';
import '../services/supabase_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _agreeTerms = false;
  bool _isLoading = false;
  String _errorMessage = '';

  final SupabaseService _supabaseService = SupabaseService();

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

Future<void> _signUp() async {
  final fullName = _fullNameController.text.trim();
  final email = _emailController.text.trim();
  final password = _passwordController.text.trim();
  final confirmPassword = _confirmPasswordController.text.trim();

  if (fullName.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
    setState(() {
      _errorMessage = 'Please fill in all fields';
    });
    return;
  }

  if (!_isValidEmail(email)) {
    setState(() {
      _errorMessage = 'Please enter a valid email address';
    });
    return;
  }

  if (password != confirmPassword) {
    setState(() {
      _errorMessage = 'Passwords do not match';
    });
    return;
  }

  if (password.length < 6) {
    setState(() {
      _errorMessage = 'Password must be at least 6 characters';
    });
    return;
  }

  if (!_agreeTerms) {
    setState(() {
      _errorMessage = 'You must agree to the Terms & Conditions';
    });
    return;
  }

  setState(() {
    _isLoading = true;
    _errorMessage = '';
  });

  try {
    debugPrint('📧 Attempting sign up for: $email');
    
    final response = await _supabaseService.signUp(
      email: email,
      password: password,
      fullName: fullName,
    );

    debugPrint('✅ Sign up response: ${response.user?.id}');

    if (response.user != null) {
      await _supabaseService.saveUserData(
        userId: response.user!.id,
        email: email,
        fullName: fullName,
      );

      debugPrint('✅ User data saved successfully');

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const PrivacyConsentScreen()),
        );
      }
    }
  } on AuthException catch (e) {
    debugPrint('🔥 AuthException: ${e.message}');
    setState(() {
      _errorMessage = _getAuthErrorMessage(e.message);
      _isLoading = false;
    });
  } catch (e) {
    debugPrint('🔥 Error: $e');
    setState(() {
      _errorMessage = 'An error occurred. Please try again.';
      _isLoading = false;
    });
  }
}

  String _getAuthErrorMessage(String message) {
    if (message.contains('already registered')) {
      return 'This email is already registered. Please login instead.';
    } else if (message.contains('invalid email')) {
      return 'Please enter a valid email address.';
    } else if (message.contains('password')) {
      return 'Password must be at least 6 characters.';
    }
    return 'Sign up failed. Please try again.';
  }

  Future<void> _signUpWithGoogle() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    await Future.delayed(const Duration(milliseconds: 800));
    setState(() {
      _isLoading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Google Sign Up coming soon!'), backgroundColor: Color(0xFF5E35B1)),
    );
  }

  Future<void> _signUpWithFacebook() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    await Future.delayed(const Duration(milliseconds: 800));
    setState(() {
      _isLoading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Facebook Sign Up coming soon!'), backgroundColor: Color(0xFF5E35B1)),
    );
  }

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
          'Sign Up',
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
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              
              // ========== العنوان ==========
              const Text(
                'Sign up',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Create your Account...',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B6B7A),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // ========== Sign Up Via ==========
              const Text(
                'Sign Up Via',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              const SizedBox(height: 16),
              
              // ========== 3 أزرار ==========
              Row(
                children: [
                  _buildSocialButton(
                    icon: Icons.facebook,
                    label: 'Facebook',
                    color: const Color(0xFF1877F2),
                    onTap: _signUpWithFacebook,
                  ),
                  const SizedBox(width: 12),
                  _buildSocialButton(
                    icon: Icons.g_mobiledata,
                    label: 'Google',
                    color: const Color(0xFFDB4437),
                    onTap: _signUpWithGoogle,
                  ),
                  const SizedBox(width: 12),
                  _buildSocialButton(
                    icon: Icons.email_outlined,
                    label: 'Email',
                    color: const Color(0xFF5235C5),
                    onTap: () {},
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // ========== OR Divider ==========
              Row(
                children: [
                  Expanded(child: Divider(color: const Color(0xFFD1D1D8), thickness: 1)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text('or', style: TextStyle(color: const Color(0xFF8A8A9A), fontSize: 14)),
                  ),
                  Expanded(child: Divider(color: const Color(0xFFD1D1D8), thickness: 1)),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // ========== رسالة الخطأ ==========
              if (_errorMessage.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE76F51).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE76F51).withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Color(0xFFE76F51), size: 18),
                      const SizedBox(width: 10),
                      Expanded(child: Text(_errorMessage, style: const TextStyle(color: Color(0xFFE76F51), fontSize: 13))),
                    ],
                  ),
                ),
              
              // ========== Full Name ==========
              const Text(
                'Full Name',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF1A1A2E)),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFD1D1D8), width: 1),
                ),
                child: TextField(
                  controller: _fullNameController,
                  decoration: const InputDecoration(
                    hintText: 'Ahmed Mohammed',
                    prefixIcon: Icon(Icons.person_outline, color: Color(0xFF8A8A9A)),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // ========== Email ==========
              const Text(
                'Email',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF1A1A2E)),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFD1D1D8), width: 1),
                ),
                child: TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    hintText: 'ahmed@example.com',
                    prefixIcon: Icon(Icons.email_outlined, color: Color(0xFF8A8A9A)),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // ========== Password ==========
              const Text(
                'Password',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF1A1A2E)),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFD1D1D8), width: 1),
                ),
                child: TextField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    hintText: '••••••••',
                    prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF8A8A9A)),
                    suffixIcon: IconButton(
                      icon: Icon(_isPasswordVisible ? Icons.visibility_off : Icons.visibility, color: const Color(0xFF8A8A9A)),
                      onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // ========== Confirm Password ==========
              const Text(
                'Confirm Password',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF1A1A2E)),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFD1D1D8), width: 1),
                ),
                child: TextField(
                  controller: _confirmPasswordController,
                  obscureText: !_isConfirmPasswordVisible,
                  decoration: InputDecoration(
                    hintText: '••••••••',
                    prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF8A8A9A)),
                    suffixIcon: IconButton(
                      icon: Icon(_isConfirmPasswordVisible ? Icons.visibility_off : Icons.visibility, color: const Color(0xFF8A8A9A)),
                      onPressed: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // ========== Terms & Conditions Section (مع زر عرض الشروط) ==========
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: _agreeTerms,
                        onChanged: (value) => setState(() => _agreeTerms = value ?? false),
                        activeColor: const Color(0xFF5235C5),
                      ),
                      const Text(
                        'I Agree the Conditions & Terms',
                        style: TextStyle(fontSize: 14, color: Color(0xFF1A1A2E)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const TermsScreen()),
                      );
                    },
                    child: const Padding(
                      padding: EdgeInsets.only(left: 40),
                      child: Text(
                        'View Terms & Conditions',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF5235C5),
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // ========== Sign Up Button ==========
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _signUp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5235C5),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                      : const Text('Sign up', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 26),
              const SizedBox(height: 4),
              Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }
}