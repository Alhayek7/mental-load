// ============================================================
// 📄 lib/screens/about_screen.dart
// 📌 صفحة عن النظام - About Screen
// ============================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF9F8),
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ الشعار
            _buildLogoSection(),
            const SizedBox(height: 24),

            // ✅ معلومات التطبيق
            _buildAppInfo(),
            const SizedBox(height: 24),

            // ✅ الفريق
            _buildTeamSection(),
            const SizedBox(height: 24),

            // ✅ المشاركات
            _buildAchievementsSection(),
            const SizedBox(height: 24),

            // ✅ روابط التواصل
            _buildSocialLinks(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // App Bar
  // ============================================================
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      toolbarHeight: 90,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF5235C5).withValues(alpha: 0.08),
              const Color(0xFF1A5F7A).withValues(alpha: 0.04),
            ],
          ),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
          border: Border(
            bottom: BorderSide(
              color: const Color(0xFF5235C5).withValues(alpha: 0.06),
              width: 1,
            ),
          ),
        ),
      ),
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(
            Icons.arrow_back_rounded,
            color: Color(0xFF5235C5),
            size: 20,
          ),
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About',
            style: GoogleFonts.manrope(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1A1A2E),
              letterSpacing: -0.3,
            ),
          ),
          Row(
            children: [
              Container(
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  color: Color(0xFF5235C5),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'Mental Load App',
                style: GoogleFonts.manrope(
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF6B6B7A),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // Logo Section
  // ============================================================
  Widget _buildLogoSection() {
    return Center(
      child: Column(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF5235C5), Color(0xFF7B2CBF)],
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF5235C5).withValues(alpha: 0.3),
                  blurRadius: 30,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.psychology,
                size: 60,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Mental Load',
            style: GoogleFonts.manrope(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1A1A2E),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Version 1.0.0',
            style: GoogleFonts.manrope(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF8A8A9A),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF5235C5).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF5235C5).withValues(alpha: 0.15),
              ),
            ),
            child: Text(
              '🏆 USAII Global AI Hackathon 2026',
              style: GoogleFonts.manrope(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF5235C5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // App Info
  // ============================================================
  Widget _buildAppInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE8E8EE)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF5235C5).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.info_outline,
                  color: Color(0xFF5235C5),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'About the App',
                style: GoogleFonts.manrope(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A1A2E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Mental Load is an AI-powered daily check-in assistant that helps heavy AI tool users detect and manage cognitive overload before they feel it.',
            style: GoogleFonts.manrope(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF4A4A5A),
              height: 1.6,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildTag('🧠 AI-Powered'),
              _buildTag('📊 Real-time Analysis'),
              _buildTag('🔮 Predictions'),
              _buildTag('🛡️ Privacy First'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F7FF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE8E8EE),
        ),
      ),
      child: Text(
        label,
        style: GoogleFonts.manrope(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF5235C5),
        ),
      ),
    );
  }

  // ============================================================
  // Team Section
  // ============================================================
  Widget _buildTeamSection() {
    final teamMembers = [
      {
        'name': 'Ahmed Eid Abo Baid',
        'role': 'AI Engineer',
        'email': 'eidez1252002@gmail.com',
        'icon': Icons.psychology,
      },
      {
        'name': 'Ayat Zaky Shehada Hamed',
        'role': 'Data Scientist',
        'email': 'ayat.zaky.hamed@gmail.com',
        'icon': Icons.analytics,
      },
      {
        'name': 'Ratul Hasan Ruhan',
        'role': 'Machine Learning Engineer',
        'email': 'ratulhasan1644@gmail.com',
        'icon': Icons.memory,
      },
      {
        'name': 'Ahmed Wesam Alhayek',
        'role': 'Software Developer',
        'email': 'aalhayek7@smail.ucas.edu.ps',
        'icon': Icons.code,
      },
      {
        'name': 'Raghad Mohammad Jawad AlSerhy',
        'role': 'UI/UX Designer',
        'email': 'raghadmohammad804@gmail.com',
        'icon': Icons.design_services,
      },
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE8E8EE)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF5235C5).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.group,
                  color: Color(0xFF5235C5),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Team GOAI',
                style: GoogleFonts.manrope(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A1A2E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '5 passionate members working together to make a difference',
            style: GoogleFonts.manrope(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF6B6B7A),
            ),
          ),
          const SizedBox(height: 16),
          ...teamMembers.map((member) => _buildTeamMember(
                name: member['name'] as String,
                role: member['role'] as String,
                email: member['email'] as String,
                icon: member['icon'] as IconData,
              )),
        ],
      ),
    );
  }

  Widget _buildTeamMember({
    required String name,
    required String role,
    required String email,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F7FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE8E8EE),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF5235C5).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF5235C5), size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1A2E),
                  ),
                ),
                Text(
                  role,
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF6B6B7A),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _launchEmail(email),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF5235C5).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.email_outlined,
                color: Color(0xFF5235C5),
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // Achievements Section
  // ============================================================
  Widget _buildAchievementsSection() {
    final achievements = [
      {
        'icon': '🏆',
        'title': 'USAII Global AI Hackathon 2026',
        'description': 'Undergraduate Track - Productivity Challenge',
      },
      {
        'icon': '🧠',
        'title': 'AI-Powered Cognitive Detection',
        'description': 'BERT-based classification for cognitive load scoring',
      },
      {
        'icon': '🔮',
        'title': 'Predictive Analytics',
        'description': 'ARIMA forecasting for 3-day burnout prediction',
      },
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF5235C5).withValues(alpha: 0.06),
            const Color(0xFF1A5F7A).withValues(alpha: 0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF5235C5).withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF5235C5).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.emoji_events_outlined,
                  color: Color(0xFF5235C5),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Achievements',
                style: GoogleFonts.manrope(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A1A2E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...achievements.map((item) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFE8E8EE),
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      item['icon'] as String,
                      style: const TextStyle(fontSize: 28),
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
                          Text(
                            item['description'] as String,
                            style: GoogleFonts.manrope(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF6B6B7A),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  // ============================================================
  // Social Links
  // ============================================================
  Widget _buildSocialLinks() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE8E8EE)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF5235C5).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.link,
                  color: Color(0xFF5235C5),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Connect With Us',
                style: GoogleFonts.manrope(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A1A2E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildSocialButton(
                icon: Icons.code,
                label: 'GitHub',
                color: const Color(0xFF24292E),
                onTap: () => _launchUrl('https://github.com/Alhayek7/mental-load'),
              ),
              const SizedBox(width: 12),
              _buildSocialButton(
                icon: Icons.mail_outline,
                label: 'Email',
                color: const Color(0xFF5235C5),
                onTap: () => _launchEmail('aalhayek7@smail.ucas.edu.ps'),
              ),
            ],
          ),
        ],
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
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withValues(alpha: 0.15),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // Helpers
  // ============================================================
  Future<void> _launchUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    } catch (e) {
      debugPrint('Error launching URL: $e');
    }
  }

  Future<void> _launchEmail(String email) async {
    try {
      final uri = Uri.parse('mailto:$email');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    } catch (e) {
      debugPrint('Error launching email: $e');
    }
  }
}