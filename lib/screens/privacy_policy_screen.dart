// ============================================================
// 📄 lib/screens/privacy_policy_screen.dart
// 📌 صفحة سياسة الخصوصية - Privacy Policy Screen
// ============================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF9F8),
      appBar: _buildAppBar(context),
      body: _buildBody(context),

    );
  }

  // ============================================================
  // App Bar
  // ============================================================
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      leading: Container(
        margin: const EdgeInsets.all(8),
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
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF5235C5)),
          onPressed: () => Navigator.pop(context),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Privacy Policy',
            style: GoogleFonts.manrope(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1A1A2E),
            ),
          ),
          Text(
            'Last updated: June 17, 2026',
            style: GoogleFonts.manrope(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF8A8A9A),
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () {
            // مشاركة أو طباعة
          },
          icon: const Icon(Icons.share_outlined, color: Color(0xFF5235C5)),
        ),
      ],
    );
  }

  // ============================================================
  // Body
  // ============================================================
Widget _buildBody(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ============================================================
          // Hero Card
          // ============================================================
          _buildHeroCard(),

          const SizedBox(height: 24),

          // ============================================================
          // Quick Navigation
          // ============================================================
          _buildQuickNavigation(),

          const SizedBox(height: 24),

          // ============================================================
          // Policy Sections
          // ============================================================
          _buildSection(
            number: '01',
            title: 'Information We Collect',
            icon: Icons.data_usage_outlined,
            color: const Color(0xFF5235C5),
            content: '''
We collect the following types of information to provide and improve our services:

• Check-in Responses: Your daily reflections about AI tool usage and cognitive state
• Voice Transcripts: If you choose to use voice input, we convert audio to text (audio files are not stored)
• Usage Patterns: How you interact with the app, including frequency and features used
• Device Information: Basic device type and operating system for compatibility
• Account Information: Name and email address you provide during registration

All data is collected with your explicit consent and used solely for providing personalized cognitive load analysis and recommendations.
''',
          ),

          _buildSection(
            number: '02',
            title: 'How We Store Your Data',
            icon: Icons.storage_outlined,
            color: const Color(0xFF1A5F7A),
            content: '''
Your data is stored securely using industry-standard practices:

• Encryption: All data is encrypted during transmission (TLS 1.3) and at rest (AES-256)
• Database: Supabase (PostgreSQL) with Row Level Security ensures data isolation
• Access: Only you can access your personal data through your authenticated account
• Retention: Data is stored until you delete your account or request data removal
• Backups: Automated daily backups are maintained for recovery purposes

We implement strict security measures to prevent unauthorized access, disclosure, or loss of your data.
''',
          ),

          _buildSection(
            number: '03',
            title: 'How We Use Your Information',
            icon: Icons.analytics_outlined,
            color: const Color(0xFF2D6A4F),
            content: '''
Your data helps us deliver a personalized and meaningful experience:

• Cognitive Analysis: AI models analyze your responses to detect cognitive load patterns
• Personalized Recommendations: Generate tailored suggestions to improve your well-being
• Progress Tracking: Monitor your cognitive health trends over time
• Feature Improvement: Aggregate anonymized data to enhance our AI algorithms
• Research Purposes: Anonymized data may be used for academic research to advance cognitive load understanding

We never use your data in ways that could harm or mislead you.
''',
          ),

          _buildSection(
            number: '04',
            title: 'Data Sharing & Third Parties',
            icon: Icons.share_outlined,
            color: const Color(0xFFE76F51),
            content: '''
We respect your privacy and limit data sharing:

• Never Sold: Your personal data is never sold to third parties
• No Marketing: We do not share data for advertising or marketing purposes
• Service Providers: Limited data may be shared with trusted service providers (Supabase, OpenAI) solely for app functionality
• Legal Compliance: We may disclose data if required by law or to protect rights and safety
• Aggregated Data: Anonymized statistical data may be shared for research purposes

Any third-party processing is subject to strict confidentiality agreements.
''',
            isWarning: true,
          ),

          _buildSection(
            number: '05',
            title: 'Your Rights & Control',
            icon: Icons.verified_outlined,
            color: const Color(0xFF5235C5),
            content: '''
You have full control over your data:

• View Data: Access all your personal information through the app settings
• Export Data: Download your complete data in JSON format
• Correct Data: Update your profile information anytime
• Delete Data: Remove specific data or your entire account
• Withdraw Consent: You can withdraw consent at any time
• Opt-Out: Choose not to participate in anonymized research

We respond to all data requests within 30 days as required by GDPR.
''',
          ),

          _buildSection(
            number: '06',
            title: 'Security Measures',
            icon: Icons.security_outlined,
            color: const Color(0xFF1A5F7A),
            content: '''
We implement comprehensive security measures:

• Encryption: End-to-end encryption for all data in transit and at rest
• Authentication: Secure login with Supabase Auth and password protection
• Access Control: Row Level Security ensures data isolation between users
• Regular Audits: Security assessments and vulnerability scans are conducted regularly
• Incident Response: We have procedures to address and notify users of security incidents

While we take security seriously, we recommend using strong passwords and keeping your credentials confidential.
''',
          ),

          _buildSection(
            number: '07',
            title: 'Contact Us',
            icon: Icons.contact_support_outlined,
            color: const Color(0xFF2D6A4F),
            content: '''
If you have questions, concerns, or requests regarding your privacy:

📧 Email: aihackathon@usaii.org
📍 USAII Organization

We aim to respond to all privacy inquiries within 48 hours.
''',
          ),

          const SizedBox(height: 24),

          // ============================================================
          // Footer
          // ============================================================
          _buildFooter(context),


          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ============================================================
  // Hero Card
  // ============================================================
  Widget _buildHeroCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF5235C5).withValues(alpha: 0.08),
            const Color(0xFF1A5F7A).withValues(alpha: 0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF5235C5).withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF5235C5), Color(0xFF7B2CBF)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF5235C5).withValues(alpha: 0.25),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.privacy_tip_outlined,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Privacy Matters',
                  style: GoogleFonts.manrope(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'ClearLoad is committed to protecting your personal data with transparency and care.',
                  style: GoogleFonts.manrope(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF6B6B7A),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // Quick Navigation
  // ============================================================
  Widget _buildQuickNavigation() {
    final items = [
      '01 Collection',
      '02 Storage',
      '03 Usage',
      '04 Sharing',
      '05 Rights',
      '06 Security',
      '07 Contact',
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
              const Icon(Icons.menu_book_outlined, color: Color(0xFF5235C5), size: 18),
              const SizedBox(width: 8),
              Text(
                'Quick Navigation',
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A1A2E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: items.map((label) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F8),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE8E8EE)),
                ),
                child: Text(
                  label,
                  style: GoogleFonts.manrope(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF6B6B7A),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // Policy Section
  // ============================================================
  Widget _buildSection({
    required String number,
    required String title,
    required IconData icon,
    required Color color,
    required String content,
    bool isWarning = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isWarning
            ? const Color(0xFFE76F51).withValues(alpha: 0.04)
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isWarning
              ? const Color(0xFFE76F51).withValues(alpha: 0.15)
              : const Color(0xFFE8E8EE),
          width: isWarning ? 2 : 1,
        ),
        boxShadow: isWarning
            ? [
                BoxShadow(
                  color: const Color(0xFFE76F51).withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ========== Header ==========
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    number,
                    style: GoogleFonts.manrope(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: color,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: GoogleFonts.manrope(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: isWarning ? const Color(0xFFE76F51) : const Color(0xFF1A1A2E),
                        ),
                      ),
                    ),
                    Icon(
                      icon,
                      color: isWarning ? const Color(0xFFE76F51) : color,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // ========== Content ==========
          Text(
            content,
            style: GoogleFonts.manrope(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: isWarning ? const Color(0xFF6B6B7A) : const Color(0xFF484554),
              height: 1.7,
            ),
          ),

          // ========== Warning Badge ==========
          if (isWarning)
            Container(
              margin: const EdgeInsets.only(top: 10),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFE76F51).withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFFE76F51).withValues(alpha: 0.1),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: Color(0xFFE76F51),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Please read this section carefully as it contains important information about data sharing.',
                      style: GoogleFonts.manrope(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFFE76F51),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

// ============================================================
// Footer
// ============================================================
Widget _buildFooter(BuildContext context) {  // ✅ أضف BuildContext context
  return Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFF2D6A4F).withValues(alpha: 0.06),
          const Color(0xFF1A5F7A).withValues(alpha: 0.04),
        ],
      ),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: const Color(0xFF2D6A4F).withValues(alpha: 0.12),
      ),
    ),
    child: Column(
      children: [
        Row(
          children: [
            const Icon(
              Icons.shield_outlined,
              color: Color(0xFF2D6A4F),
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Your privacy is our priority. We are committed to protecting your data.',
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2D6A4F),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),  // ✅ context متاح الآن
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5235C5),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              shadowColor: const Color(0xFF5235C5).withValues(alpha: 0.3),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle_outline, size: 20),
                const SizedBox(width: 8),
                Text(
                  'I Understand & Accept',
                  style: GoogleFonts.manrope(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
}