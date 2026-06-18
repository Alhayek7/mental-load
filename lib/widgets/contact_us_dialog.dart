// ============================================================
// 📄 lib/widgets/contact_us_dialog.dart
// 📌 نافذة التواصل معنا - Contact Us Dialog
// 🏆 Mental Load — Team GOAI — USAII Hackathon 2026
// ✅ Fixed: RenderFlex overflow + Supabase offline error handling
// ============================================================

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUsDialog extends StatefulWidget {
  const ContactUsDialog({super.key});

  @override
  State<ContactUsDialog> createState() => _ContactUsDialogState();
}

class _ContactUsDialogState extends State<ContactUsDialog>
    with SingleTickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  bool _isSubmitting = false;
  bool _showSuccess = false;
  late AnimationController _animController;
  late Animation<double> _scaleAnim;

  static const List<Map<String, String>> _teamMembers = [
    {'name': 'Ahmed Eid',      'role': 'AI Engineer',     'initials': 'AE', 'email': 'eidez1252002@gmail.com',         'color': 'purple'},
    {'name': 'Ayat Zaky',      'role': 'Data Scientist',  'initials': 'AZ', 'email': 'ayat.zaky.hamed@gmail.com',      'color': 'teal'},
    {'name': 'Ratul Hasan',    'role': 'ML Engineer',     'initials': 'RH', 'email': 'ratulhasan1644@gmail.com',       'color': 'blue'},
    {'name': 'Ahmed Wesam',    'role': 'Developer',       'initials': 'AW', 'email': 'aalhayek7@smail.ucas.edu.ps',    'color': 'coral'},
    {'name': 'Raghad AlSerhy', 'role': 'UI/UX Designer',  'initials': 'RM', 'email': 'raghadmohammad804@gmail.com',   'color': 'green'},
  ];

  @override
  void initState() {
    super.initState();
    _messageController.addListener(() => setState(() {}));
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _scaleAnim = CurvedAnimation(parent: _animController, curve: Curves.elasticOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _animController.dispose();
    super.dispose();
  }

  // ============================================================
  // URL launchers — مع معالجة كاملة للأخطاء
  // ============================================================
  Future<void> _sendEmail({String body = ''}) async {
    final Uri uri = Uri(
      scheme: 'mailto',
      path: 'aihackathon@usaii.org',
      query: Uri.encodeFull('subject=Mental Load Feedback&body=$body'),
    );
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        _showError('Could not open email app');
      }
    } on TimeoutException {
      _showError('Request timed out. Please try again.');
    } catch (e) {
      _showError('Could not open email app');
    }
  }

  Future<void> _openDiscord() async {
    final Uri uri = Uri.parse('https://discord.gg/ePjenJnyh4');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _showError('Could not open Discord');
      }
    } catch (e) {
      _showError('No internet connection');
    }
  }

  Future<void> _openGitHub() async {
    final Uri uri = Uri.parse('https://github.com/Alhayek7/mental-load');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _showError('Could not open GitHub');
      }
    } catch (e) {
      _showError('No internet connection');
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message,
            style: GoogleFonts.manrope(fontSize: 13, color: Colors.white)),
        backgroundColor: const Color(0xFFE76F51),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // ============================================================
  // Build — ConstrainedBox يمنع الـ overflow
  // ============================================================
  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * 0.88;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ScaleTransition(
        scale: _scaleAnim,
        child: ConstrainedBox(
          // ✅ FIX 1: أقصى ارتفاع لمنع الـ overflow على الشاشات الصغيرة
          constraints: BoxConstraints(maxHeight: maxHeight),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 32,
                  offset: const Offset(0, 12),
                  spreadRadius: 4,
                ),
              ],
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, anim) =>
                  FadeTransition(opacity: anim, child: child),
              child: _showSuccess ? _buildSuccessState() : _buildFormState(),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // Form State — SingleChildScrollView يحل الـ overflow
  // ============================================================
  Widget _buildFormState() {
    return SingleChildScrollView(
      // ✅ FIX 2: scroll بدلاً من Column ثابتة
      key: const ValueKey('form'),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 20),
          _buildContactOptions(),
          const SizedBox(height: 20),
          _buildDivider(),
          const SizedBox(height: 16),
          _buildMessageField(),
          const SizedBox(height: 12),
          _buildSendButton(),
          const SizedBox(height: 20),
          _buildTeamFooter(),
          // ✅ FIX 3: مسافة إضافية عند ظهور الكيبورد
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom > 0 ? 8 : 0),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 46, height: 46,
          decoration: BoxDecoration(
            color: const Color(0xFF534AB7),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.headset_mic_outlined, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Contact us',
                  style: GoogleFonts.manrope(fontSize: 19, fontWeight: FontWeight.w700, color: const Color(0xFF1A1A2E))),
              Text("We'd love to hear from you",
                  style: GoogleFonts.manrope(fontSize: 13, color: const Color(0xFF8A8A9A))),
            ],
          ),
        ),
        _CloseButton(onTap: () => Navigator.pop(context)),
      ],
    );
  }

  Widget _buildContactOptions() {
    final options = [
      _ContactOption(icon: Icons.email_outlined, label: 'Email',   subtitle: 'aihackathon\n@usaii.org', color: const Color(0xFF534AB7), bgColor: const Color(0xFFEEEDFE), onTap: () => _sendEmail()),
      _ContactOption(icon: Icons.discord,        label: 'Discord', subtitle: 'Join our\ncommunity',    color: const Color(0xFF185FA5), bgColor: const Color(0xFFE6F1FB), onTap: _openDiscord),
      _ContactOption(icon: Icons.code,           label: 'GitHub',  subtitle: 'mental-load\nrepo',     color: const Color(0xFF3B6D11), bgColor: const Color(0xFFEAF3DE), onTap: _openGitHub),
    ];
    return Row(children: options.map((o) => Expanded(child: _buildContactCard(o))).toList());
  }

  Widget _buildContactCard(_ContactOption opt) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Material(
        color: opt.bgColor,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: opt.onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            child: Column(
              children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: opt.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(opt.icon, color: opt.color, size: 22),
                ),
                const SizedBox(height: 6),
                Text(opt.label, style: GoogleFonts.manrope(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF1A1A2E))),
                const SizedBox(height: 2),
                Text(opt.subtitle, style: GoogleFonts.manrope(fontSize: 9.5, color: const Color(0xFF8A8A9A), height: 1.4), textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageField() {
    final charCount = _messageController.text.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Send a message', style: GoogleFonts.manrope(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF1A1A2E))),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF6F5FF),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _messageController.text.isNotEmpty
                  ? const Color(0xFF534AB7).withValues(alpha: 0.35)
                  : const Color(0xFFE5E5EE),
            ),
          ),
          child: TextField(
            controller: _messageController,
            maxLines: 4,
            maxLength: 500,
            decoration: InputDecoration(
              hintText: 'Write your message here...',
              hintStyle: GoogleFonts.manrope(fontSize: 13, color: const Color(0xFFB0B0BA)),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(14),
              counterText: '',
            ),
            style: GoogleFonts.manrope(fontSize: 13, color: const Color(0xFF1A1A2E)),
          ),
        ),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerRight,
          child: Text('$charCount / 500',
              style: GoogleFonts.manrope(fontSize: 11,
                  color: charCount > 450 ? const Color(0xFFE76F51) : const Color(0xFFB0B0BA))),
        ),
      ],
    );
  }

  Widget _buildSendButton() {
    final hasMessage = _messageController.text.trim().isNotEmpty;
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: (_isSubmitting || !hasMessage) ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: hasMessage ? const Color(0xFF534AB7) : const Color(0xFFD1D1D8),
          disabledBackgroundColor: hasMessage ? const Color(0xFF534AB7) : const Color(0xFFD1D1D8),
          foregroundColor: Colors.white,
          disabledForegroundColor: Colors.white70,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
        child: _isSubmitting
            ? const SizedBox(width: 20, height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.send_outlined, size: 17),
                  const SizedBox(width: 8),
                  Text(
                    hasMessage ? 'Send message' : 'Write a message first',
                    style: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
      ),
    );
  }

Widget _buildTeamFooter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDivider(),
        const SizedBox(height: 12),
        Text(
          'TEAM GOAI — USAII HACKATHON 2026',
          style: GoogleFonts.manrope(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
            color: const Color(0xFFB0B0BA),
          ),
        ),
        const SizedBox(height: 10),
        // صف 1: عضوان
        Row(
          children: [
            Expanded(child: _buildTeamChip(_teamMembers[0])),
            const SizedBox(width: 8),
            Expanded(child: _buildTeamChip(_teamMembers[1])),
          ],
        ),
        const SizedBox(height: 8),
        // صف 2: عضوان
        Row(
          children: [
            Expanded(child: _buildTeamChip(_teamMembers[2])),
            const SizedBox(width: 8),
            Expanded(child: _buildTeamChip(_teamMembers[3])),
          ],
        ),
        const SizedBox(height: 8),
        // صف 3: العضو الخامس في المنتصف
        Row(
          children: [
            const Expanded(child: SizedBox()),
            Expanded(
              flex: 2,
              child: _buildTeamChip(_teamMembers[4]),
            ),
            const Expanded(child: SizedBox()),
          ],
        ),
      ],
    );
  }

  Widget _buildTeamChip(Map<String, String> member) {
    final colors = _avatarColors(member['color']!);
    return GestureDetector(
      onTap: () => launchUrl(Uri(scheme: 'mailto', path: member['email'])),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF6F6FA),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE5E5EE)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(color: colors.$1, shape: BoxShape.circle),
              alignment: Alignment.center,
              child: Text(
                member['initials']!,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: colors.$2,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member['name']!,
                    style: GoogleFonts.manrope(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A1A2E),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    member['role']!,
                    style: GoogleFonts.manrope(
                      fontSize: 9.5,
                      color: const Color(0xFF8A8A9A),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessState() {
    return SingleChildScrollView(
      key: const ValueKey('success'),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),
          Container(
            width: 64, height: 64,
            decoration: const BoxDecoration(color: Color(0xFFEAF3DE), shape: BoxShape.circle),
            child: const Icon(Icons.check_rounded, size: 34, color: Color(0xFF3B6D11)),
          ),
          const SizedBox(height: 16),
          Text('Message sent!',
              style: GoogleFonts.manrope(fontSize: 20, fontWeight: FontWeight.w700, color: const Color(0xFF1A1A2E))),
          const SizedBox(height: 8),
          Text('Thank you for reaching out.\nTeam GOAI will get back to you soon.',
              style: GoogleFonts.manrope(fontSize: 13, color: const Color(0xFF8A8A9A), height: 1.6),
              textAlign: TextAlign.center),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() { _showSuccess = false; _messageController.clear(); }),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    side: const BorderSide(color: Color(0xFFE0E0E8)),
                  ),
                  child: Text('Send another',
                      style: GoogleFonts.manrope(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF534AB7))),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF534AB7),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: Text('Done',
                      style: GoogleFonts.manrope(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildDivider() => Container(height: 0.5, color: const Color(0xFFE5E5EE));

  (Color, Color) _avatarColors(String color) => switch (color) {
    'purple' => (const Color(0xFFEEEDFE), const Color(0xFF534AB7)),
    'teal'   => (const Color(0xFFE1F5EE), const Color(0xFF0F6E56)),
    'blue'   => (const Color(0xFFE6F1FB), const Color(0xFF185FA5)),
    'coral'  => (const Color(0xFFFAECE7), const Color(0xFF993C1D)),
    'green'  => (const Color(0xFFEAF3DE), const Color(0xFF3B6D11)),
    _        => (const Color(0xFFF1EFE8), const Color(0xFF5F5E5A)),
  };

  // ============================================================
  // Submit — مع معالجة TimeoutException و Supabase SocketException
  // ============================================================
  Future<void> _submit() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    setState(() => _isSubmitting = true);

    try {
      await Future.delayed(const Duration(milliseconds: 800));
      await _sendEmail(body: message);

      if (!mounted) return;
      setState(() { _isSubmitting = false; _showSuccess = true; });
    } on TimeoutException {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      _showError('Request timed out. Check your connection.');
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      // ✅ FIX: Supabase SocketException / Failed host lookup
      final isNetworkError = e.toString().contains('SocketException') ||
          e.toString().contains('Failed host lookup') ||
          e.toString().contains('No address associated');
      _showError(isNetworkError
          ? 'No internet connection. Email will open offline.'
          : 'Something went wrong. Please try again.');
    }
  }
}

// ============================================================
// Helper Widgets
// ============================================================

class _CloseButton extends StatelessWidget {
  final VoidCallback onTap;
  const _CloseButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF5F5F8),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: const SizedBox(
          width: 34, height: 34,
          child: Icon(Icons.close, size: 17, color: Color(0xFF8A8A9A)),
        ),
      ),
    );
  }
}

class _ContactOption {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final Color bgColor;
  final VoidCallback onTap;
  const _ContactOption({required this.icon, required this.label, required this.subtitle,
      required this.color, required this.bgColor, required this.onTap});
}