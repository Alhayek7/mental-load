// lib/screens/terms_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

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
          'Terms & Conditions',
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ========== الهيدر ==========
              Container(
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
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF5E35B1).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.description,
                        color: Color(0xFF5E35B1),
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Text(
                        'Please read these terms carefully',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 500.ms).moveY(begin: 20, end: 0),

              const SizedBox(height: 24),

              // ========== تاريخ السريان ==========
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF5E35B1).withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 16, color: Color(0xFF5E35B1)),
                    const SizedBox(width: 8),
                    const Text(
                      'Effective Date: ',
                      style: TextStyle(fontSize: 12, color: Color(0xFF6B6B7A)),
                    ),
                    Text(
                      'June 15, 2026',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF5E35B1),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 100.ms),

              const SizedBox(height: 24),

              // ========== القائمة ==========
              _buildSection(
                number: '1',
                title: 'Acceptance of Terms',
                content: 'By creating an account and using the Mental Load application, you agree to be bound by these Terms & Conditions. If you do not agree to these terms, please do not use the application.',
                delay: 150,
              ),

              _buildSection(
                number: '2',
                title: 'Eligibility',
                content: 'You must be at least 14 years old to use this application. Users under 18 require parental consent. By using the app, you confirm that you meet these eligibility requirements.',
                delay: 200,
              ),

              _buildSection(
                number: '3',
                title: 'Account Responsibility',
                content: 'You are responsible for maintaining the confidentiality of your account credentials. You are fully responsible for all activities that occur under your account. Notify us immediately of any unauthorized use.',
                delay: 250,
              ),

              _buildSection(
                number: '4',
                title: 'Privacy & Data Collection',
                content: 'We collect and process your data as described in our Privacy Policy. Your data is encrypted and stored securely. We do not share your personal information with third parties without your consent.',
                delay: 300,
              ),

              _buildSection(
                number: '5',
                title: 'Medical Disclaimer',
                content: 'Mental Load is a self-awareness tool for cognitive load management. It is NOT a medical device and does not provide medical advice, diagnosis, or treatment. Always consult a qualified healthcare provider for medical concerns.',
                delay: 350,
              ),

              _buildSection(
                number: '6',
                title: 'User Conduct',
                content: 'You agree to use the application only for its intended purpose. You shall not misuse the app, attempt to bypass security features, or interfere with other users\' experience.',
                delay: 400,
              ),

              _buildSection(
                number: '7',
                title: 'Intellectual Property',
                content: 'All content, design, and code within Mental Load are the property of the development team. You may not copy, modify, or distribute any part of the application without permission.',
                delay: 450,
              ),

              _buildSection(
                number: '8',
                title: 'Limitation of Liability',
                content: 'To the maximum extent permitted by law, Mental Load shall not be liable for any indirect, incidental, or consequential damages arising from your use of the application.',
                delay: 500,
              ),

              _buildSection(
                number: '9',
                title: 'Termination',
                content: 'We reserve the right to suspend or terminate your account if you violate these terms. You may delete your account at any time from the app settings.',
                delay: 550,
              ),

              _buildSection(
                number: '10',
                title: 'Changes to Terms',
                content: 'We may update these terms from time to time. Continued use of the app after changes constitutes acceptance of the new terms. You will be notified of significant changes.',
                delay: 600,
              ),

              const SizedBox(height: 24),

              // ========== زر الموافقة ==========
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5E35B1),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'I Understand & Agree',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ).animate().fadeIn(delay: 650.ms).scale(
                begin: const Offset(0.95, 0.95),
                end: const Offset(1.0, 1.0),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String number,
    required String title,
    required String content,
    required int delay,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFF5E35B1).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5E35B1),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  content,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B6B7A),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: delay.ms).moveY(begin: 15, end: 0);
  }
}