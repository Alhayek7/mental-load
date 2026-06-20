// ============================================================
// 📄 lib/widgets/delete_account_dialog.dart
// 📌 نافذة حذف الحساب - Delete Account Dialog (محسّنة)
// ============================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DeleteAccountDialog extends StatefulWidget {
  final VoidCallback onConfirm;
  final bool isLoading;

  const DeleteAccountDialog({
    super.key,
    required this.onConfirm,
    this.isLoading = false,
  });

  @override
  State<DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<DeleteAccountDialog> {
  bool _isConfirmed = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.9,
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                const Color(0xFFFFF5F5),
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
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ============================================================
                // Icon
                // ============================================================
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFFE76F51).withValues(alpha: 0.15),
                        const Color(0xFFFF6B6B).withValues(alpha: 0.15),
                      ],
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFE76F51).withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.delete_forever_rounded,
                    color: Color(0xFFE76F51),
                    size: 48,
                  ),
                ),

                const SizedBox(height: 20),

                // ============================================================
                // Title
                // ============================================================
                Text(
                  'Delete Account',
                  style: GoogleFonts.manrope(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFFE76F51),
                  ),
                ),

                const SizedBox(height: 8),

                // ============================================================
                // Description
                // ============================================================
                Text(
                  'This action cannot be undone. All your data will be permanently deleted.',
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF6B6B7A),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 16),

                // ============================================================
                // Warning List (محسّن)
                // ============================================================
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF5F5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFE76F51).withValues(alpha: 0.15),
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildWarningItem(
                        icon: Icons.person_off_outlined,
                        text: 'Account will be permanently deleted',
                        color: const Color(0xFFE76F51),
                      ),
                      const SizedBox(height: 8),
                      _buildWarningItem(
                        icon: Icons.data_usage_outlined,
                        text: 'All check-ins and data will be removed',
                        color: const Color(0xFFE76F51),
                      ),
                      const SizedBox(height: 8),
                      _buildWarningItem(
                        icon: Icons.delete_sweep_outlined,
                        text: 'History and recommendations lost forever',
                        color: const Color(0xFFE76F51),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ============================================================
                // Confirmation Checkbox (محسّن)
                // ============================================================
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isConfirmed = !_isConfirmed;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _isConfirmed
                          ? const Color(0xFFE76F51).withValues(alpha: 0.05)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _isConfirmed
                            ? const Color(0xFFE76F51)
                            : const Color(0xFFE8E8EE),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: _isConfirmed
                                ? const Color(0xFFE76F51)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: _isConfirmed
                                  ? const Color(0xFFE76F51)
                                  : const Color(0xFFB0B0BA),
                              width: 2,
                            ),
                          ),
                          child: _isConfirmed
                              ? const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 16,
                                )
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'I understand that this action cannot be undone',
                            style: GoogleFonts.manrope(
                              fontSize: 13,
                              fontWeight: _isConfirmed ? FontWeight.w600 : FontWeight.w400,
                              color: _isConfirmed
                                  ? const Color(0xFF1A1A2E)
                                  : const Color(0xFF8A8A9A),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // ============================================================
                // Buttons (محسّن - حل مشكلة التجاوز)
                // ============================================================
                Row(
                  children: [
                    // ✅ زر Cancel
                    Expanded(
                      flex: 1,
                      child: GestureDetector(
                        onTap: widget.isLoading ? null : () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F5F8),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: const Color(0xFFE8E8EE),
                              width: 1,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'Cancel',
                              style: GoogleFonts.manrope(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF8A8A9A),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // ✅ زر Delete Account (مبسط - بدون Row إضافي)
                    Expanded(
                      flex: 1,
                      child: GestureDetector(
                        onTap: (_isConfirmed && !widget.isLoading)
                            ? widget.onConfirm
                            : null,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            gradient: (!_isConfirmed || widget.isLoading)
                                ? LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      const Color(0xFFB0B0BA),
                                      const Color(0xFF8A8A9A),
                                    ],
                                  )
                                : LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      const Color(0xFFE76F51),
                                      const Color(0xFFFF6B6B),
                                    ],
                                  ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: (!_isConfirmed || widget.isLoading)
                                ? null
                                : [
                                    BoxShadow(
                                      color: const Color(0xFFE76F51).withValues(alpha: 0.3),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                          ),
                          child: Center(
                            child: widget.isLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text( // ✅ استخدام Text مباشرة بدلاً من Row
                                    'Delete Account',
                                    style: GoogleFonts.manrope(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: !_isConfirmed
                                          ? Colors.white.withValues(alpha: 0.5)
                                          : Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWarningItem({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: color,
          size: 18,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.manrope(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF1A1A2E),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}