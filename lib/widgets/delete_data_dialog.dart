// ============================================================
// 📄 lib/widgets/delete_data_dialog.dart
// 📌 نافذة حذف البيانات - Delete Data Dialog
// ============================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DeleteDataDialog extends StatefulWidget {
  final VoidCallback onConfirm;
  final bool isLoading;

  const DeleteDataDialog({
    super.key,
    required this.onConfirm,
    this.isLoading = false,
  });

  @override
  State<DeleteDataDialog> createState() => _DeleteDataDialogState();
}

class _DeleteDataDialogState extends State<DeleteDataDialog> {
  bool _isConfirmed = false;
  bool _showDetails = false;

  final List<Map<String, dynamic>> _dataItems = [
    {
      'icon': Icons.analytics_outlined,
      'title': 'Cognitive Load Scores',
      'description': 'All your analysis results and patterns',
      'color': Color(0xFF5235C5),
    },
    {
      'icon': Icons.history_outlined,
      'title': 'Check-in History',
      'description': 'All your daily reflections and records',
      'color': Color(0xFF1A5F7A),
    },
    {
      'icon': Icons.recommend_outlined,
      'title': 'Recommendations',
      'description': 'All personalized suggestions and insights',
      'color': Color(0xFF2D6A4F),
    },
    {
      'icon': Icons.person_outline,
      'title': 'Profile Information',
      'description': 'Your name, email, and preferences',
      'color': Color(0xFFF4A261),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, const Color(0xFFFFF5F5)],
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

              const SizedBox(height: 16),

              // ============================================================
              // Warning Icon
              // ============================================================
              _buildWarningIcon(),

              const SizedBox(height: 16),

              // ============================================================
              // Description
              // ============================================================
              _buildDescription(),

              const SizedBox(height: 16),

              // ============================================================
              // Data Items
              // ============================================================
              _buildDataItems(),

              const SizedBox(height: 16),

              // ============================================================
              // Confirmation
              // ============================================================
              _buildConfirmation(),

              const SizedBox(height: 20),

              // ============================================================
              // Buttons
              // ============================================================
              _buildButtons(),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // Header
  // ============================================================
  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFFE76F51).withValues(alpha: 0.1),
                const Color(0xFFFF6B6B).withValues(alpha: 0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(
            Icons.delete_outline_rounded,
            color: Color(0xFFE76F51),
            size: 24,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Delete All Data',
                style: GoogleFonts.manrope(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFFE76F51),
                ),
              ),
              Text(
                'This action cannot be undone',
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
          icon: const Icon(Icons.close, color: Color(0xFF8A8A9A), size: 18),
        ),
      ],
    );
  }

  // ============================================================
  // Warning Icon
  // ============================================================
  Widget _buildWarningIcon() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFE76F51).withValues(alpha: 0.1),
              const Color(0xFFFF6B6B).withValues(alpha: 0.1),
            ],
          ),
          shape: BoxShape.circle,
          border: Border.all(
            color: const Color(0xFFE76F51).withValues(alpha: 0.2),
            width: 2,
          ),
        ),
        child: const Icon(
          Icons.warning_amber_rounded,
          color: Color(0xFFE76F51),
          size: 48,
        ),
      ),
    );
  }

  // ============================================================
  // Description
  // ============================================================
  Widget _buildDescription() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE76F51).withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE76F51).withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        children: [
          Text(
            'This will permanently delete all your cognitive analysis data, check-in history, recommendations, and profile information.',
            style: GoogleFonts.manrope(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF1A1A2E),
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () {
              setState(() {
                _showDetails = !_showDetails;
              });
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _showDetails ? 'Hide details' : 'Show details',
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF5235C5),
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  _showDetails
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: const Color(0xFF5235C5),
                  size: 16,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // Data Items
  // ============================================================
  Widget _buildDataItems() {
    if (!_showDetails) return const SizedBox();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE8E8EE)),
        ),
        child: Column(
          children: _dataItems.map((item) {
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: const Color(0xFFE8E8EE),
                    width: _dataItems.indexOf(item) == _dataItems.length - 1
                        ? 0
                        : 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: (item['color'] as Color).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      item['icon'] as IconData,
                      color: item['color'] as Color,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['title'] as String,
                          style: GoogleFonts.manrope(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1A1A2E),
                          ),
                        ),
                        Text(
                          item['description'] as String,
                          style: GoogleFonts.manrope(
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF8A8A9A),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.delete_outline,
                    color: const Color(0xFFE76F51).withValues(alpha: 0.5),
                    size: 16,
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ============================================================
  // Confirmation
  // ============================================================
  Widget _buildConfirmation() {
    return GestureDetector(
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
                color: _isConfirmed ? const Color(0xFFE76F51) : Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: _isConfirmed
                      ? const Color(0xFFE76F51)
                      : const Color(0xFFB0B0BA),
                  width: 2,
                ),
              ),
              child: _isConfirmed
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'I understand that this action is permanent and irreversible',
                style: GoogleFonts.manrope(
                  fontSize: 13,
                  fontWeight: _isConfirmed ? FontWeight.w600 : FontWeight.w400,
                  color: _isConfirmed
                      ? const Color(0xFF1A1A2E)
                      : const Color(0xFF8A8A9A),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // Buttons
  // ============================================================
  Widget _buildButtons() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: widget.isLoading ? null : () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F8),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE8E8EE), width: 1),
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
        Expanded(
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
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.delete_outline_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Delete All Data',
                            style: GoogleFonts.manrope(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: !_isConfirmed
                                  ? Colors.white.withValues(alpha: 0.5)
                                  : Colors.white,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
