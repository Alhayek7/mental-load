// ============================================================
// 📄 lib/widgets/contact_us_dialog.dart
// 📌 نافذة التواصل معنا - Contact Us Dialog
// ============================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUsDialog extends StatefulWidget {
  const ContactUsDialog({super.key});

  @override
  State<ContactUsDialog> createState() => _ContactUsDialogState();
}

class _ContactUsDialogState extends State<ContactUsDialog> {
  final TextEditingController _messageController = TextEditingController();
  bool _isSubmitting = false;

  final List<Map<String, dynamic>> _contactOptions = [
    {
      'icon': Icons.email_outlined,
      'title': 'Email',
      'subtitle': 'aihackathon@usaii.org',
      'color': Color(0xFF5235C5),
      'action': _sendEmail,
    },
    {
      'icon': Icons.phone_outlined,
      'title': 'Phone',
      'subtitle': '+1 (800) 123-4567',
      'color': Color(0xFF1A5F7A),
      'action': _makePhoneCall,
    },
    {
      'icon': Icons.chat_outlined,
      'title': 'Discord',
      'subtitle': 'Join our community',
      'color': Color(0xFF2D6A4F),
      'action': _openDiscord,
    },
  ];

  static Future<void> _sendEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'aihackathon@usaii.org',
      query: 'subject=ClearLoad%20Feedback&body=',
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  static Future<void> _makePhoneCall() async {
    final Uri phoneUri = Uri(scheme: 'tel', path: '+18001234567');
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  static Future<void> _openDiscord() async {
    final Uri discordUri = Uri.parse('https://discord.gg/ePjenJnyh4');
    if (await canLaunchUrl(discordUri)) {
      await launchUrl(discordUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              const Color(0xFFF5F7FF),
            ],
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 30,
              offset: const Offset(0, 10),
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ============================================================
            // Header
            // ============================================================
            _buildHeader(),

            const SizedBox(height: 20),

            // ============================================================
            // Contact Options
            // ============================================================
            _buildContactOptions(),

            const SizedBox(height: 20),

            // ============================================================
            // Message Field
            // ============================================================
            _buildMessageField(),

            const SizedBox(height: 16),

            // ============================================================
            // Send Button
            // ============================================================
            _buildSendButton(),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [const Color(0xFF5235C5), const Color(0xFF7B2CBF)],
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF5235C5).withValues(alpha: 0.25),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.contact_support_outlined,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Contact Us',
                style: GoogleFonts.manrope(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1A1A2E),
                ),
              ),
              Text(
                'We\'d love to hear from you',
                style: GoogleFonts.manrope(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF8A8A9A),
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => Navigator.pop(context),
          style: IconButton.styleFrom(
            backgroundColor: const Color(0xFFF5F5F8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: const Icon(
            Icons.close,
            color: Color(0xFF8A8A9A),
            size: 18,
          ),
        ),
      ],
    );
  }

  Widget _buildContactOptions() {
    return Row(
      children: _contactOptions.map((option) {
        return Expanded(
          child: GestureDetector(
            onTap: () => option['action'](),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (option['color'] as Color).withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: (option['color'] as Color).withValues(alpha: 0.1),
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    option['icon'] as IconData,
                    color: option['color'] as Color,
                    size: 28,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    option['title'] as String,
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A1A2E),
                    ),
                  ),
                  Text(
                    option['subtitle'] as String,
                    style: GoogleFonts.manrope(
                      fontSize: 9,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF8A8A9A),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMessageField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Send us a message',
          style: GoogleFonts.manrope(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF8F7FF),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE8E8EE)),
          ),
          child: TextField(
            controller: _messageController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Write your message here...',
              hintStyle: GoogleFonts.manrope(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: const Color(0xFFB0B0BA),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
              counterText: '',
            ),
            maxLength: 500,
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            '${_messageController.text.length}/500',
            style: GoogleFonts.manrope(
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: const Color(0xFFB0B0BA),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSendButton() {
    final hasMessage = _messageController.text.trim().isNotEmpty;
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitMessage,
        style: ElevatedButton.styleFrom(
          backgroundColor: hasMessage
              ? const Color(0xFF5235C5)
              : const Color(0xFFD1D1D8),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: hasMessage ? 4 : 0,
          shadowColor: hasMessage
              ? const Color(0xFF5235C5).withValues(alpha: 0.3)
              : Colors.transparent,
        ),
        child: _isSubmitting
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.send_outlined, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    hasMessage ? 'Send Message' : 'Write a message first',
                    style: GoogleFonts.manrope(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> _submitMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    setState(() => _isSubmitting = true);

    // محاكاة إرسال الرسالة
    await Future.delayed(const Duration(seconds: 1));

    setState(() => _isSubmitting = false);

    // فتح البريد الإلكتروني مع الرسالة
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'aihackathon@usaii.org',
      query: 'subject=ClearLoad%20Feedback&body=${Uri.encodeComponent(message)}',
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Thank you for your feedback!'),
            backgroundColor: Color(0xFF2D6A4F),
          ),
        );
      }
    } else {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open email app'),
          backgroundColor: Color(0xFFE76F51),
        ),
      );
    }
  }
}