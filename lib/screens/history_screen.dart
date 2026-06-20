// ============================================================
// 📄 lib/screens/history_screen.dart
// 📌 صفحة السجل - History Screen
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/supabase_service.dart';
import 'checkin_screen.dart';
import 'dart:io';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final SupabaseService _supabaseService = SupabaseService();

  List<Map<String, dynamic>> _historyData = [];
  bool _isLoading = true;
  String _selectedFilter = 'All';
  String? _errorMessage;

  final List<String> _filters = ['All', 'Low Load', 'Medium Load', 'High Load'];
  bool _hasLoadedOnce = false; // ✅ أضف هذا السطر

  @override
  void initState() {
    super.initState();
    _loadHistoryData();
  }

  Future<void> _loadHistoryData() async {
    debugPrint('🔄 Loading history data...');

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // ✅ 1. التحقق من الإنترنت
      final hasInternet = await _hasInternetConnection();
      if (!hasInternet) {
        // ✅ إذا كان هناك بيانات مخزنة، اعرضها
        if (_historyData.isNotEmpty) {
          setState(() {
            _isLoading = false;
          });
          return;
        }

        // ✅ إذا لا يوجد بيانات، اعرض رسالة عدم وجود إنترنت
        setState(() {
          _errorMessage = 'no_internet';
          _isLoading = false;
        });
        return;
      }

      final user = _supabaseService.currentUser;
      debugPrint('👤 Current user: ${user?.email ?? "NO USER"}');

      if (user == null) {
        debugPrint('❌ No user logged in!');
        setState(() {
          _errorMessage = 'Please login to view your history';
          _isLoading = false;
        });
        return;
      }

      debugPrint('📊 Fetching checkins for user: ${user.id}');

      final response = await _supabaseService.client
          .from('checkins')
          .select(
            'id, checkin_date, cognitive_load_score, recommendation, free_text',
          )
          .eq('user_id', user.id)
          .order('checkin_date', ascending: false)
          .limit(30)
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () {
              throw Exception('Connection timeout');
            },
          );

      debugPrint('📊 Found ${response.length} records');

      if (response.isNotEmpty) {
        final List<Map<String, dynamic>> formattedData = [];

        for (final item in response) {
          final score = item['cognitive_load_score'] ?? 0;
          final date = DateTime.parse(item['checkin_date']);

          String category;
          if (score <= 2) {
            category = 'Low';
          } else if (score == 3) {
            category = 'Medium';
          } else {
            category = 'High';
          }

          final now = DateTime.now();
          final difference = now.difference(date).inDays;

          String dateLabel;
          if (difference == 0) {
            dateLabel = 'Today';
          } else if (difference == 1) {
            dateLabel = 'Yesterday';
          } else if (difference <= 7) {
            dateLabel = '$difference Days Ago';
          } else {
            dateLabel = '${date.day}/${date.month}/${date.year}';
          }

          formattedData.add({
            'id': item['id'],
            'date': dateLabel,
            'fullDate': '${date.day}/${date.month}/${date.year}',
            'category': category,
            'score': (score * 2).toDouble(),
            'color': _getCategoryColor(category),
            'recommendation': item['recommendation'] ?? '',
            'free_text': item['free_text'] ?? '',
          });
        }

        setState(() {
          _historyData = formattedData;
          _isLoading = false;
          _hasLoadedOnce = true; // ✅ ضع علامة التحميل الناجح
        });
      } else {
        debugPrint('📭 No history found');
        setState(() {
          _historyData = [];
          _isLoading = false;
          _hasLoadedOnce = true;
        });
      }
    } catch (e) {
      debugPrint('❌ Error loading history: $e');

      // ✅ 3. معالجة أخطاء الاتصال
      if (e.toString().contains('Connection timeout') ||
          e.toString().contains('Failed host lookup')) {
        setState(() {
          _errorMessage = 'no_internet';
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load history. Please try again.';
          _isLoading = false;
        });
      }
    }

    debugPrint('✅ History loading complete. isLoading: $_isLoading');
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Low':
        return const Color(0xFF2D6A4F);
      case 'Medium':
        return const Color(0xFFF4A261);
      case 'High':
        return const Color(0xFFE76F51);
      default:
        return const Color(0xFF8A8A9A);
    }
  }

  Future<bool> _hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  // ============================================================
  // ✅ دالة مساعدة للحصول على معلومات الفئة
  // ============================================================
  Map<String, dynamic> _getCategoryInfo(String category, Color color) {
    // تأكد من أن category ليست null
    final String cleanCategory = (category ?? 'Medium').toString();

    switch (cleanCategory) {
      case 'Low':
        return {
          'icon': Icons.check_circle_outline,
          'label': 'Low Load',
          'description':
              '✅ Your cognitive load is low. You\'re managing your mental energy well. Keep up the great habits!',
        };
      case 'Medium':
        return {
          'icon': Icons.info_outline,
          'label': 'Medium Load',
          'description':
              '📊 Moderate cognitive load detected. Consider taking short breaks and monitoring your AI usage to maintain balance.',
        };
      case 'High':
        return {
          'icon': Icons.warning_amber_rounded,
          'label': 'High Load',
          'description':
              '⚠️ High cognitive load detected. Take immediate action: reduce AI tools, take a 20-minute break, and practice deep breathing.',
        };
      default:
        return {
          'icon': Icons.analytics_outlined,
          'label': 'Analyzed',
          'description':
              'Cognitive load analysis completed. Review your score for insights.',
        };
    }
  }

  List<Map<String, dynamic>> _getFilteredData() {
    if (_selectedFilter == 'All') return _historyData;
    return _historyData
        .where(
          (item) => item['category'] == _selectedFilter.replaceAll(' Load', ''),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredData = _getFilteredData();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FF),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 8),
            _buildFilters(),
            const SizedBox(height: 16),
            Expanded(
              child: _isLoading && !_hasLoadedOnce
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: Color(0xFF5E35B1)),
                          SizedBox(height: 16),
                          Text(
                            'Loading history...',
                            style: TextStyle(
                              color: Color(0xFF8A8A9A),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    )
                  : _errorMessage ==
                        'no_internet' // ✅ شرط جديد
                  ? _buildNoInternetState()
                  : _errorMessage != null
                  ? _buildErrorState()
                  : filteredData.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      physics: const BouncingScrollPhysics(),
                      itemCount: filteredData.length,
                      itemBuilder: (context, index) {
                        return _buildHistoryItem(filteredData[index], index);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // Header (ترويسة احترافية - مع عدد السجلات في الإحصائيات)
  // ============================================================
  Widget _buildHeader() {
    final user = _supabaseService.currentUser;
    final userName = user?.email?.split('@')[0] ?? 'User';
    final totalRecords = _historyData.length;

    return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ============================================================
              // الصف العلوي: العنوان + اسم المستخدم + زر التحديث
              // ============================================================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // ✅ أيقونة + عنوان + اسم المستخدم
                  Expanded(
                    flex: 3,
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFF5235C5), Color(0xFF7B2CBF)],
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFF5235C5,
                                ).withValues(alpha: 0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.history_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      'History',
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xFF1A1A2E),
                                        letterSpacing: -0.5,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // ✅ اسم المستخدم (Badge)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          const Color(
                                            0xFF5235C5,
                                          ).withValues(alpha: 0.12),
                                          const Color(
                                            0xFF7B2CBF,
                                          ).withValues(alpha: 0.08),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: const Color(
                                          0xFF5235C5,
                                        ).withValues(alpha: 0.15),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.person_outline,
                                          size: 10,
                                          color: const Color(0xFF5235C5),
                                        ),
                                        const SizedBox(width: 4),
                                        Flexible(
                                          child: Text(
                                            userName,
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: const Color(0xFF5235C5),
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
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
                                  Flexible(
                                    child: Text(
                                      'Review your cognitive load journey',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                        color: const Color(0xFF6B6B7A),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // ✅ زر التحديث فقط
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      onPressed: _loadHistoryData,
                      icon: const Icon(
                        Icons.refresh_rounded,
                        color: Color(0xFF5235C5),
                        size: 20,
                      ),
                      padding: const EdgeInsets.all(8),
                      constraints: const BoxConstraints(
                        minWidth: 36,
                        minHeight: 36,
                      ),
                      tooltip: 'Refresh history',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // ============================================================
              // ✅ شريط الإحصائيات السريعة (مع عدد السجلات)
              // ============================================================
              // ✅ استخدام Wrap لمنع Overflow
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  // ✅ عدد السجلات (مضاف هنا)
                  _buildQuickStat(
                    label: 'Records',
                    value: totalRecords.toString(),
                    icon: Icons.checklist_outlined,
                    color: const Color(0xFF5235C5),
                  ),
                  _buildQuickStat(
                    label: 'Avg',
                    value: _calculateAverageScore(),
                    icon: Icons.trending_up_outlined,
                    color: const Color(0xFF2D6A4F),
                  ),
                  _buildQuickStat(
                    label: 'High',
                    value: _calculateHighestScore(),
                    icon: Icons.arrow_upward_outlined,
                    color: const Color(0xFFE76F51),
                  ),
                  _buildQuickStat(
                    label: 'Low',
                    value: _calculateLowestScore(),
                    icon: Icons.arrow_downward_outlined,
                    color: const Color(0xFF2D6A4F),
                  ),
                ],
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(duration: 400.ms)
        .slideY(begin: -0.1, end: 0, duration: 400.ms);
  }

  // ============================================================
  // دوال مساعدة للإحصائيات
  // ============================================================
  String _calculateAverageScore() {
    if (_historyData.isEmpty) return '--';
    final sum = _historyData.fold(
      0.0,
      (total, item) => total + (item['score'] ?? 0.0),
    );
    return (sum / _historyData.length).toStringAsFixed(1);
  }

  String _calculateHighestScore() {
    if (_historyData.isEmpty) return '--';
    final highest = _historyData.reduce(
      (a, b) => (a['score'] ?? 0) > (b['score'] ?? 0) ? a : b,
    );
    return (highest['score'] ?? 0).toStringAsFixed(1);
  }

  String _calculateLowestScore() {
    if (_historyData.isEmpty) return '--';
    final lowest = _historyData.reduce(
      (a, b) => (a['score'] ?? 0) < (b['score'] ?? 0) ? a : b,
    );
    return (lowest['score'] ?? 0).toStringAsFixed(1);
  }

  // ============================================================
  // عنصر الإحصائية السريعة (مصغّر)
  // ============================================================
  Widget _buildQuickStat({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.06),
            color.withValues(alpha: 0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.08), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: color, size: 12),
          ),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF8A8A9A),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = _selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: _buildFilterChip(filter, isSelected),
          );
        },
      ),
    ).animate().fadeIn(delay: 100.ms);
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    final color = label == 'All'
        ? const Color(0xFF5E35B1)
        : label == 'Low Load'
        ? const Color(0xFF2D6A4F)
        : label == 'Medium Load'
        ? const Color(0xFFF4A261)
        : const Color(0xFFE76F51);

    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? color : const Color(0xFFE8E8EE),
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xFF6B6B7A),
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryItem(Map<String, dynamic> item, int index) {
    final color = item['color'] as Color;
    final isLow = item['category'] == 'Low';
    final isMedium = item['category'] == 'Medium';
    final isHigh = item['category'] == 'High';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
      child: Row(
        children: [
          // ✅ أيقونة الحالة
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isLow
                  ? Icons.check_circle_outline
                  : isMedium
                  ? Icons.info_outline
                  : Icons.warning_amber_rounded,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),

          // ✅ النصوص (التاريخ + التصنيف أسفل التاريخ)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ✅ التاريخ (السطر الأول)
                Text(
                  item['date'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 4),
                // ✅ التصنيف (السطر الثاني - أسفل التاريخ)
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      item['category'],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: color,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      item['fullDate'],
                      style: TextStyle(fontSize: 11, color: Colors.grey[400]),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ✅ النتيجة + زر View Report
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${item['score']}/10',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              // ✅ زر View Report
              GestureDetector(
                onTap: () => _showReportDetails(item),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF5E35B1).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFF5E35B1).withValues(alpha: 0.15),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'View',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF5E35B1),
                        ),
                      ),
                      const SizedBox(width: 2),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 8,
                        color: const Color(0xFF5E35B1),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: (150 + index * 50).ms);
  }

  // ============================================================
  // عرض تفاصيل التقرير - النسخة النهائية
  // ============================================================
  void _showReportDetails(Map<String, dynamic> item) {
    final String category = item['category']?.toString() ?? 'Medium';
    final Color color = item['color'] ?? const Color(0xFFF4A261);
    final double score = (item['score'] ?? 0.0).toDouble();
    final String date = item['fullDate'] ?? 'Unknown';
    final String recommendation = item['recommendation'] ?? '';
    final String freeText = item['free_text'] ?? '';

    final categoryInfo = _getCategoryInfo(category, color);
    final bool isLow = category == 'Low';
    final bool isMedium = category == 'Medium';
    // ✅ إزالة isHigh لأنها غير مستخدمة

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, const Color(0xFFF8F7FF)],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 30,
                offset: const Offset(0, -10),
              ),
            ],
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle Bar
                Center(
                  child: Container(
                    width: 50,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD1D1D8),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // ============================================================
                // HEADER
                // ============================================================
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [color, color.withValues(alpha: 0.7)],
                            ),
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: color.withValues(alpha: 0.3),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Icon(
                              isLow
                                  ? Icons.emoji_emotions_outlined
                                  : isMedium
                                  ? Icons.sentiment_neutral_outlined
                                  : Icons.sentiment_very_dissatisfied_outlined,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Report Details',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1A1A2E),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: color,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  categoryInfo['label'] as String,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: color,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: color.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    category,
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                      color: color,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F8),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.close,
                          color: Color(0xFF8A8A9A),
                          size: 20,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // ============================================================
                // شريط التصنيف
                // ============================================================
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        color.withValues(alpha: 0.12),
                        color.withValues(alpha: 0.04),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: color.withValues(alpha: 0.2),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          categoryInfo['icon'] as IconData,
                          color: color,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          categoryInfo['description'] as String,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: color,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ============================================================
                // Score Card
                // ============================================================
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        color.withValues(alpha: 0.08),
                        color.withValues(alpha: 0.02),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: color.withValues(alpha: 0.15),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Cognitive Load Score',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF6B6B7A),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  '${score.toStringAsFixed(1)}',
                                  style: TextStyle(
                                    fontSize: 42,
                                    fontWeight: FontWeight.w900,
                                    color: color,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '/ 10',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF8A8A9A),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    categoryInfo['icon'] as IconData,
                                    color: color,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    categoryInfo['label'] as String,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: color,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 100,
                        height: 100,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 90,
                              height: 90,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: color.withValues(alpha: 0.05),
                              ),
                            ),
                            SizedBox(
                              width: 80,
                              height: 80,
                              child: CircularProgressIndicator(
                                value: (score / 10).clamp(0.0, 1.0),
                                strokeWidth: 10,
                                backgroundColor: color.withValues(alpha: 0.1),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  color,
                                ),
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${((score / 10) * 100).toInt()}%',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: color,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Load',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF8A8A9A),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ============================================================
                // Details Grid
                // ============================================================
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F7FF),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE8E8EE)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildDetailItem(
                          icon: Icons.calendar_today_outlined,
                          label: 'Date',
                          value: date,
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: const Color(0xFFE8E8EE),
                      ),
                      Expanded(
                        child: _buildDetailItem(
                          icon: Icons.category_outlined,
                          label: 'Category',
                          value: category,
                          valueColor: color,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ============================================================
                // Reflection
                // ============================================================
                if (freeText.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F7FF),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE8E8EE)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.text_fields,
                              color: const Color(0xFF8A8A9A),
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Your Reflection',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF8A8A9A),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          freeText,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF1A1A2E),
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                if (freeText.isNotEmpty) const SizedBox(height: 16),

                // ============================================================
                // Recommendation
                // ============================================================
                if (recommendation.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
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
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF2D6A4F,
                            ).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.lightbulb_outline,
                            color: Color(0xFF2D6A4F),
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'AI Recommendation',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF2D6A4F),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                recommendation,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFF484554),
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 20),
                // ============================================================
                // ✅ رسالة تشجيعية حسب الفئة (ضعها هنا)
                // ============================================================
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        isLow
                            ? const Color(0xFF2D6A4F).withValues(alpha: 0.08)
                            : isMedium
                            ? const Color(0xFFF4A261).withValues(alpha: 0.08)
                            : const Color(0xFFE76F51).withValues(alpha: 0.08),
                        Colors.white,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isLow
                          ? const Color(0xFF2D6A4F).withValues(alpha: 0.15)
                          : isMedium
                          ? const Color(0xFFF4A261).withValues(alpha: 0.15)
                          : const Color(0xFFE76F51).withValues(alpha: 0.15),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isLow
                              ? const Color(0xFF2D6A4F).withValues(alpha: 0.1)
                              : isMedium
                              ? const Color(0xFFF4A261).withValues(alpha: 0.1)
                              : const Color(0xFFE76F51).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          isLow
                              ? Icons.celebration_outlined
                              : isMedium
                              ? Icons.info_outline
                              : Icons.warning_outlined,
                          color: isLow
                              ? const Color(0xFF2D6A4F)
                              : isMedium
                              ? const Color(0xFFF4A261)
                              : const Color(0xFFE76F51),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isLow
                                  ? '💪 Keep It Up!'
                                  : isMedium
                                  ? '🔶 Take a Moment'
                                  : '⚠️ Need Immediate Action',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: isLow
                                    ? const Color(0xFF2D6A4F)
                                    : isMedium
                                    ? const Color(0xFFF4A261)
                                    : const Color(0xFFE76F51),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isLow
                                  ? '🌟 Excellent work! Your cognitive load is well managed. Keep up these healthy habits and maintain your balanced approach to AI usage.'
                                  : isMedium
                                  ? '📊 You\'re in a moderate zone. Take short breaks, reduce multitasking, and monitor your AI tool usage to prevent escalation.'
                                  : '🚨 Your cognitive load is high! Take immediate action: Step away from screens, take a 20-minute break, reduce AI tools to 1-2, and practice deep breathing.',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                                color: isLow
                                    ? const Color(
                                        0xFF2D6A4F,
                                      ).withValues(alpha: 0.8)
                                    : isMedium
                                    ? const Color(
                                        0xFFF4A261,
                                      ).withValues(alpha: 0.8)
                                    : const Color(
                                        0xFFE76F51,
                                      ).withValues(alpha: 0.8),
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ============================================================
                // Action Buttons
                // ============================================================
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
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
                              'Close',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF8A8A9A),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFF5235C5), Color(0xFF7B2CBF)],
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFF5235C5,
                                ).withValues(alpha: 0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.share_outlined,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Share Report',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // دالة مساعدة لعنصر التفاصيل
  // ============================================================
  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFE8E8EE).withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF8A8A9A), size: 18),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF8A8A9A),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: valueColor ?? const Color(0xFF1A1A2E),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ✅ أيقونة كبيرة مع خلفية متدرجة
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF5235C5).withValues(alpha: 0.08),
                  const Color(0xFF7B2CBF).withValues(alpha: 0.04),
                ],
              ),
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF5235C5).withValues(alpha: 0.12),
                width: 2,
              ),
            ),
            child: Icon(
              Icons.history_outlined,
              size: 48,
              color: const Color(0xFF5235C5).withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 24),

          // ✅ النص الرئيسي
          Text(
            '📭 No History Yet',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1A1A2E),
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 10),

          // ✅ النص الوصفي (جملة تشجيعية)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF5235C5).withValues(alpha: 0.04),
                  const Color(0xFF7B2CBF).withValues(alpha: 0.02),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF5235C5).withValues(alpha: 0.06),
              ),
            ),
            child: Column(
              children: [
                Text(
                  'Start your first check-in today to begin tracking your cognitive load journey.',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF6B6B7A),
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  '✨ Every check-in brings you closer to understanding your mental wellbeing.',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF5235C5).withValues(alpha: 0.7),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),

          // ✅ زر "بدء Check-in"
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CheckinScreen()),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF5235C5), Color(0xFF7B2CBF)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF5235C5).withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.add_comment_outlined,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Start Your First Check-in',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),
          // ✅ نص إضافي صغير
          Text(
            'It takes less than 2 minutes 🚀',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: const Color(0xFFB0B0BA),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ أضف هذه الدالة بعد دالة _buildEmptyState
  Widget _buildNoInternetState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ✅ أيقونة
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFFE76F51).withValues(alpha: 0.1),
                    const Color(0xFFFF6B6B).withValues(alpha: 0.05),
                  ],
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFE76F51).withValues(alpha: 0.2),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.wifi_off_rounded,
                color: Color(0xFFE76F51),
                size: 64,
              ),
            ),
            const SizedBox(height: 24),

            // ✅ العنوان
            Text(
              'No Internet Connection',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 12),

            // ✅ الوصف
            Text(
              'We couldn\'t connect to the server. Please check your internet connection and try again.',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF6B6B7A),
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // ✅ معلومات إضافية
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F7FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE8E8EE)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: Color(0xFF5235C5),
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Your history will be available once you reconnect',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF5235C5),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // ✅ زر إعادة المحاولة
            ElevatedButton(
              onPressed: _loadHistoryData,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5235C5),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                shadowColor: const Color(0xFF5235C5).withValues(alpha: 0.3),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.refresh_rounded, size: 20),
                  SizedBox(width: 10),
                  Text(
                    'Try Again',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ✅ نص مساعد
            Text(
              'or connect to Wi-Fi and try again',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF8A8A9A),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 72, color: const Color(0xFFE76F51)),
          const SizedBox(height: 16),
          Text(
            _errorMessage ?? 'Something went wrong',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFFE76F51),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadHistoryData,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5E35B1),
              foregroundColor: Colors.white,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
