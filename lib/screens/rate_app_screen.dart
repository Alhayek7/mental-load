// ============================================================
// 📄 lib/screens/rate_app_screen.dart
// 📌 صفحة تقييم التطبيق - Rate the App
// ============================================================

import 'dart:io';  // ✅ أضف هذا السطر
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class RateAppScreen extends StatefulWidget {
  const RateAppScreen({super.key});

  @override
  State<RateAppScreen> createState() => _RateAppScreenState();
}

class _RateAppScreenState extends State<RateAppScreen> {
  int _selectedRating = 0;
  String _feedbackText = '';
  bool _isSubmitting = false;

  final List<Map<String, dynamic>> _ratingOptions = [
    {'emoji': '😡', 'label': 'Terrible', 'color': const Color(0xFFE76F51)},
    {'emoji': '😕', 'label': 'Bad', 'color': const Color(0xFFF4A261)},
    {'emoji': '😐', 'label': 'Okay', 'color': const Color(0xFFF9A826)},
    {'emoji': '😊', 'label': 'Good', 'color': const Color(0xFF2D6A4F)},
    {'emoji': '🤩', 'label': 'Amazing!', 'color': const Color(0xFF1A5F7A)},
  ];

  final List<String> _quickFeedbackOptions = [
    'Easy to use',
    'Helpful insights',
    'Beautiful design',
    'Accurate analysis',
    'Needs improvement',
  ];

  Future<void> _submitRating() async {
    if (_selectedRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a rating first'),
          backgroundColor: Color(0xFFE76F51),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    // محاكاة إرسال التقييم
    await Future.delayed(const Duration(seconds: 1));

    setState(() => _isSubmitting = false);

    // فتح متجر التطبيقات
    final Uri url = Uri.parse(
      Platform.isAndroid
          ? 'https://play.google.com/store/apps/details?id=com.clearload.app'
          : 'https://apps.apple.com/app/idXXXXXXXXX',
    );
    
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Thank you for your feedback! ⭐'),
          backgroundColor: Color(0xFF2D6A4F),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF9F8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF5235C5)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Rate the App',
          style: GoogleFonts.manrope(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1A1A2E),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ============================================================
            // Header
            // ============================================================
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
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
                    child: Column(
                      children: [
                        Text(
                          '⭐',
                          style: const TextStyle(fontSize: 50),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'How would you rate ClearLoad?',
                          style: GoogleFonts.manrope(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF1A1A2E),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Your feedback helps us improve and create a better experience for everyone.',
                          style: GoogleFonts.manrope(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF6B6B7A),
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // ============================================================
            // Rating Stars/Emojis
            // ============================================================
            Text(
              'Select Your Rating',
              style: GoogleFonts.manrope(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: _ratingOptions.asMap().entries.map((entry) {
                final index = entry.key;
                final option = entry.value;
                final isSelected = _selectedRating == index + 1;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedRating = index + 1;
                    });
                  },
                  child: Column(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? (option['color'] as Color).withValues(alpha: 0.15)
                              : Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? (option['color'] as Color)
                                : const Color(0xFFE8E8EE),
                            width: isSelected ? 3 : 1,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: (option['color'] as Color).withValues(alpha: 0.2),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            option['emoji'] as String,
                            style: TextStyle(
                              fontSize: 28,
                              color: isSelected
                                  ? (option['color'] as Color)
                                  : null,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        option['label'] as String,
                        style: GoogleFonts.manrope(
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                          color: isSelected
                              ? (option['color'] as Color)
                              : const Color(0xFF8A8A9A),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 32),

            // ============================================================
            // Quick Feedback Options
            // ============================================================
            Text(
              'What did you like most?',
              style: GoogleFonts.manrope(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _quickFeedbackOptions.map((option) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      // إذا كان الخيار موجوداً، احذفه، وإلا أضفه
                      if (_feedbackText.contains(option)) {
                        _feedbackText = _feedbackText
                            .replaceAll(option, '')
                            .replaceAll(',,', ',')
                            .trim();
                      } else {
                        if (_feedbackText.isNotEmpty) {
                          _feedbackText += ', $option';
                        } else {
                          _feedbackText = option;
                        }
                      }
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: _feedbackText.contains(option)
                          ? const Color(0xFF5235C5)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _feedbackText.contains(option)
                            ? const Color(0xFF5235C5)
                            : const Color(0xFFE8E8EE),
                        width: 1.5,
                      ),
                      boxShadow: _feedbackText.contains(option)
                          ? [
                              BoxShadow(
                                color: const Color(0xFF5235C5).withValues(alpha: 0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Text(
                      option,
                      style: GoogleFonts.manrope(
                        fontSize: 13,
                        fontWeight: _feedbackText.contains(option)
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: _feedbackText.contains(option)
                            ? Colors.white
                            : const Color(0xFF6B6B7A),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // ============================================================
            // Feedback Text Area
            // ============================================================
            Text(
              'Additional Feedback',
              style: GoogleFonts.manrope(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE8E8EE)),
              ),
              child: TextField(
                maxLines: 4,
                onChanged: (value) {
                  setState(() {
                    _feedbackText = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Share your thoughts...',
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
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF1A1A2E),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${_feedbackText.length}/500',
                style: GoogleFonts.manrope(
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFFB0B0BA),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // ============================================================
            // Submit Button
            // ============================================================
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitRating,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedRating > 0
                      ? const Color(0xFF5235C5)
                      : const Color(0xFFD1D1D8),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: _selectedRating > 0 ? 4 : 0,
                  shadowColor: _selectedRating > 0
                      ? const Color(0xFF5235C5).withValues(alpha: 0.3)
                      : Colors.transparent,
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _selectedRating > 0
                                ? 'Submit Rating & Open Store'
                                : 'Select a Rating First',
                            style: GoogleFonts.manrope(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (_selectedRating > 0) ...[
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward, size: 18),
                          ],
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 16),

            // ============================================================
            // Skip Button
            // ============================================================
            Center(
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Text(
                  'Skip for now',
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF8A8A9A),
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}