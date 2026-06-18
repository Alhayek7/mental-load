// // ============================================================
// // 📄 lib/screens/insights_screen.dart
// // 📌 صفحة الرؤى والتحليلات - Insights Screen
// // (دمج PatternsScreen + AnalyticsScreen - بدون تبويب علوي)
// // ============================================================

// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:fl_chart/fl_chart.dart';

// class InsightsScreen extends StatefulWidget {
//   const InsightsScreen({super.key});

//   @override
//   State<InsightsScreen> createState() => _InsightsScreenState();
// }

// class _InsightsScreenState extends State<InsightsScreen> {
//   // ============================================================
//   // بيانات الرسم البياني (Patterns)
//   // ============================================================
//   final List<FlSpot> _chartData = const [
//     FlSpot(0, 4.5),
//     FlSpot(1, 3.8),
//     FlSpot(2, 4.2),
//     FlSpot(3, 5.1),
//     FlSpot(4, 3.5),
//     FlSpot(5, 4.8),
//     FlSpot(6, 4.0),
//   ];

//   final List<String> _weekDays = [
//     'Mon',
//     'Tue',
//     'Wed',
//     'Thu',
//     'Fri',
//     'Sat',
//     'Sun',
//   ];

//   // ============================================================
//   // بيانات Analytics
//   // ============================================================
//   final List<FlSpot> _weeklyData = const [
//     FlSpot(0, 3.2),
//     FlSpot(1, 4.5),
//     FlSpot(2, 3.8),
//     FlSpot(3, 6.2),
//     FlSpot(4, 5.5),
//     FlSpot(5, 2.8),
//     FlSpot(6, 4.0),
//   ];

//   final List<FlSpot> _monthlyData = const [
//     FlSpot(0, 4.0),
//     FlSpot(1, 4.5),
//     FlSpot(2, 5.2),
//     FlSpot(3, 4.8),
//     FlSpot(4, 6.0),
//     FlSpot(5, 5.5),
//     FlSpot(6, 4.2),
//     FlSpot(7, 3.8),
//     FlSpot(8, 4.5),
//     FlSpot(9, 5.0),
//     FlSpot(10, 4.2),
//     FlSpot(11, 3.5),
//     FlSpot(12, 4.0),
//     FlSpot(13, 4.8),
//     FlSpot(14, 5.5),
//     FlSpot(15, 4.0),
//     FlSpot(16, 3.2),
//     FlSpot(17, 4.5),
//     FlSpot(18, 5.0),
//     FlSpot(19, 4.2),
//     FlSpot(20, 3.8),
//     FlSpot(21, 4.0),
//     FlSpot(22, 4.5),
//     FlSpot(23, 5.2),
//     FlSpot(24, 4.8),
//     FlSpot(25, 3.5),
//     FlSpot(26, 4.0),
//     FlSpot(27, 4.2),
//     FlSpot(28, 3.8),
//     FlSpot(29, 4.5),
//   ];

//   final List<String> _months = [
//     'Jan',
//     'Feb',
//     'Mar',
//     'Apr',
//     'May',
//     'Jun',
//     'Jul',
//     'Aug',
//     'Sep',
//     'Oct',
//     'Nov',
//     'Dec',
//   ];
//   String _selectedPeriod = 'Week';

//   // ============================================================
//   // بيانات الأنماط الشخصية
//   // ============================================================
//   final List<Map<String, String>> _personalPatterns = [
//     {
//       'title': 'Highest Fatigue Occurs in the Afternoon',
//       'description': 'Your cognitive load tends to peak between 2 PM and 5 PM.',
//     },
//     {
//       'title': 'Frequent Tool Switching Increases Load',
//       'description':
//           'Switching between multiple AI tools raises mental effort and cognitive strain.',
//     },
//     {
//       'title': 'Sessions Longer Than 3 Hours Reduce Focus',
//       'description':
//           'Long sessions may lead to cognitive overload and lower concentration.',
//     },
//     {
//       'title': 'Regular Breaks Improve Performance',
//       'description':
//           'Taking breaks helps restore focus and maintain mental energy.',
//     },
//   ];

//   // ============================================================
//   // بيانات توقعات الإرهاق
//   // ============================================================
//   final List<Map<String, dynamic>> _forecastData = [
//     {
//       'day': 'Tomorrow',
//       'date': 'May 20, 2026',
//       'score': 4.5,
//       'level': 'Medium',
//       'color': const Color(0xFFF4A261),
//     },
//     {
//       'day': 'Day 2',
//       'date': 'May 21, 2026',
//       'score': 6.2,
//       'level': 'High',
//       'color': const Color(0xFFE76F51),
//     },
//     {
//       'day': 'Day 3',
//       'date': 'May 22, 2026',
//       'score': 7.5,
//       'level': 'High',
//       'color': const Color(0xFFE76F51),
//     },
//   ];

//   // ============================================================
//   // دوال مساعدة
//   // ============================================================
//   double _calculateAverage(List<FlSpot> data) {
//     if (data.isEmpty) return 0;
//     double sum = 0;
//     for (var spot in data) {
//       sum += spot.y;
//     }
//     return sum / data.length;
//   }

//   // ============================================================
//   // البناء الرئيسي
//   // ============================================================
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFFCF9F8),
//       appBar: _buildAppBar(),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // ============================================================
//             // 📊 قسم Patterns
//             // ============================================================
//             _buildSectionHeader(
//               '📊 Your Patterns',
//               'Personal patterns detected from your usage data',
//             ),
//             const SizedBox(height: 12),

//             _buildCognitiveOverview(),
//             const SizedBox(height: 16),

//             _buildCognitiveProfile(),
//             const SizedBox(height: 16),

//             _buildCognitiveLoadTrend(),
//             const SizedBox(height: 16),

//             _buildRecommendationImpact(),
//             const SizedBox(height: 16),

//             _buildPersonalPatterns(),
//             const SizedBox(height: 16),

//             _buildFatigueForecast(),
//             const SizedBox(height: 16),

//             _buildAIInsight(),

//             const SizedBox(height: 32),

//             // ============================================================
//             // 📈 قسم Analytics
//             // ============================================================
//             _buildSectionHeader(
//               '📈 Analytics',
//               'Detailed statistics and analysis',
//             ),
//             const SizedBox(height: 12),

//             _buildPeriodSelector(),
//             const SizedBox(height: 16),

//             _buildMainChart(),
//             const SizedBox(height: 16),

//             _buildStatisticsSummary(),
//             const SizedBox(height: 16),

//             _buildCategoryDistribution(),
//             const SizedBox(height: 16),

//             _buildAIToolsImpact(),
//             const SizedBox(height: 16),

//             _buildInsightsSummary(),

//             const SizedBox(height: 80),
//           ],
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // App Bar (ترويسة احترافية - موسعة)
//   // ============================================================
//   PreferredSizeWidget _buildAppBar() {
//     return AppBar(
//       backgroundColor: Colors.transparent,
//       elevation: 0,
//       toolbarHeight: 100, // ✅ زيادة الارتفاع
//       flexibleSpace: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//             colors: [
//               const Color(0xFF5235C5).withValues(alpha: 0.08),
//               const Color(0xFF1A5F7A).withValues(alpha: 0.04),
//             ],
//           ),
//           borderRadius: const BorderRadius.only(
//             bottomLeft: Radius.circular(35),
//             bottomRight: Radius.circular(35),
//           ),
//           border: Border(
//             bottom: BorderSide(
//               color: const Color(0xFF5235C5).withValues(alpha: 0.06),
//               width: 1,
//             ),
//           ),
//         ),
//       ),
//       title: Padding(
//         padding: const EdgeInsets.only(top: 8.0),
//         child: Row(
//           children: [
//             // ============================================================
//             // أيقونة مميزة (أكبر)
//             // ============================================================
//             Container(
//               padding: const EdgeInsets.all(14),
//               decoration: BoxDecoration(
//                 gradient: const LinearGradient(
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                   colors: [Color(0xFF5235C5), Color(0xFF7B2CBF)],
//                 ),
//                 borderRadius: BorderRadius.circular(18),
//                 boxShadow: [
//                   BoxShadow(
//                     color: const Color(0xFF5235C5).withValues(alpha: 0.3),
//                     blurRadius: 16,
//                     offset: const Offset(0, 6),
//                   ),
//                 ],
//               ),
//               child: const Icon(
//                 Icons.insights_rounded,
//                 color: Colors.white,
//                 size: 28,
//               ),
//             ),
//             const SizedBox(width: 18),

//             // ============================================================
//             // النصوص (أكبر وأوضح)
//             // ============================================================
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Insights',
//                     style: GoogleFonts.manrope(
//                       fontSize: 26,
//                       fontWeight: FontWeight.w800,
//                       color: const Color(0xFF1A1A2E),
//                       letterSpacing: -0.5,
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Row(
//                     children: [
//                       Container(
//                         width: 4,
//                         height: 4,
//                         decoration: const BoxDecoration(
//                           color: Color(0xFF5235C5),
//                           shape: BoxShape.circle,
//                         ),
//                       ),
//                       const SizedBox(width: 8),
//                       Text(
//                         'Your personal patterns & detailed analytics',
//                         style: GoogleFonts.manrope(
//                           fontSize: 13,
//                           fontWeight: FontWeight.w400,
//                           color: const Color(0xFF6B6B7A),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),

//             // ============================================================
//             // زر الفترة (أكبر)
//             // ============================================================
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//               decoration: BoxDecoration(
//                 color: const Color(0xFF5235C5).withValues(alpha: 0.08),
//                 borderRadius: BorderRadius.circular(24),
//                 border: Border.all(
//                   color: const Color(0xFF5235C5).withValues(alpha: 0.12),
//                   width: 1.5,
//                 ),
//               ),
//               child: Row(
//                 children: [
//                   Icon(
//                     Icons.calendar_today_outlined,
//                     color: const Color(0xFF5235C5),
//                     size: 16,
//                   ),
//                   const SizedBox(width: 8),
//                   Text(
//                     _selectedPeriod,
//                     style: GoogleFonts.manrope(
//                       fontSize: 14,
//                       fontWeight: FontWeight.w700,
//                       color: const Color(0xFF5235C5),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // Section Header
//   // ============================================================
//   Widget _buildSectionHeader(String title, String subtitle) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           title,
//           style: GoogleFonts.manrope(
//             fontSize: 20,
//             fontWeight: FontWeight.w800,
//             color: const Color(0xFF5235C5),
//           ),
//         ),
//         const SizedBox(height: 4),
//         Text(
//           subtitle,
//           style: GoogleFonts.manrope(
//             fontSize: 13,
//             fontWeight: FontWeight.w400,
//             color: const Color(0xFF484554),
//           ),
//         ),
//         const SizedBox(height: 8),
//         Container(
//           height: 3,
//           width: 60,
//           decoration: BoxDecoration(
//             color: const Color(0xFF5235C5),
//             borderRadius: BorderRadius.circular(2),
//           ),
//         ),
//       ],
//     );
//   }

// // ============================================================
// // 1. Weekly Overview (محسّن)
// // ============================================================
// Widget _buildCognitiveOverview() {
//   return _buildCard(
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             Container(
//               padding: const EdgeInsets.all(8),
//               decoration: BoxDecoration(
//                 color: const Color(0xFF5235C5).withValues(alpha: 0.08),
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: const Icon(
//                 Icons.calendar_view_week_outlined,
//                 color: Color(0xFF5235C5),
//                 size: 20,
//               ),
//             ),
//             const SizedBox(width: 12),
//             Text(
//               'Weekly Overview',
//               style: GoogleFonts.manrope(
//                 fontSize: 18,
//                 fontWeight: FontWeight.w700,
//                 color: const Color(0xFF1A1A2E),
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 6),
//         Text(
//           'A quick summary of your cognitive health and AI usage activity.',
//           style: GoogleFonts.manrope(
//             fontSize: 13,
//             fontWeight: FontWeight.w400,
//             color: const Color(0xFF6B6B7A),
//             height: 1.4,
//           ),
//         ),
//         const SizedBox(height: 18),
//         Row(
//           children: [
//             Expanded(
//               child: _buildStatCardEnhanced(
//                 label: 'Total Check-Ins',
//                 value: '12',
//                 subLabel: 'Completed reflections',
//                 icon: Icons.checklist_outlined,
//                 color: const Color(0xFF5235C5),
//               ),
//             ),
//             const SizedBox(width: 10),
//             Expanded(
//               child: _buildStatCardEnhanced(
//                 label: 'Average Load',
//                 value: '4.2',
//                 suffix: '/10',
//                 subLabel: 'Your average cognitive load',
//                 icon: Icons.trending_up_outlined,
//                 color: const Color(0xFF2D6A4F),
//               ),
//             ),
//             const SizedBox(width: 10),
//             Expanded(
//               child: _buildStatCardEnhanced(
//                 label: 'Highest Load',
//                 value: '8.7',
//                 suffix: '/10',
//                 subLabel: 'Highest detected',
//                 icon: Icons.arrow_upward_outlined,
//                 color: const Color(0xFFE76F51),
//               ),
//             ),
//           ],
//         ),
//       ],
//     ),
//   );
// }

// Widget _buildStatCardEnhanced({
//   required String label,
//   required String value,
//   String suffix = '',
//   required String subLabel,
//   required IconData icon,
//   required Color color,
// }) {
//   return Container(
//     padding: const EdgeInsets.all(14),
//     decoration: BoxDecoration(
//       gradient: LinearGradient(
//         begin: Alignment.topLeft,
//         end: Alignment.bottomRight,
//         colors: [
//           color.withValues(alpha: 0.06),
//           color.withValues(alpha: 0.02),
//         ],
//       ),
//       borderRadius: BorderRadius.circular(14),
//       border: Border.all(
//         color: color.withValues(alpha: 0.08),
//       ),
//     ),
//     child: Column(
//       children: [
//         Icon(icon, color: color, size: 18),
//         const SizedBox(height: 6),
//         Text(
//           label,
//           style: GoogleFonts.manrope(
//             fontSize: 10,
//             fontWeight: FontWeight.w600,
//             color: const Color(0xFF6B6B7A),
//           ),
//           textAlign: TextAlign.center,
//         ),
//         const SizedBox(height: 4),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.baseline,
//           textBaseline: TextBaseline.alphabetic,
//           children: [
//             Text(
//               value,
//               style: GoogleFonts.manrope(
//                 fontSize: 24,
//                 fontWeight: FontWeight.w800,
//                 color: color,
//               ),
//             ),
//             if (suffix.isNotEmpty)
//               Text(
//                 suffix,
//                 style: GoogleFonts.manrope(
//                   fontSize: 13,
//                   fontWeight: FontWeight.w600,
//                   color: color.withValues(alpha: 0.7),
//                 ),
//               ),
//           ],
//         ),
//         Text(
//           subLabel,
//           style: GoogleFonts.manrope(
//             fontSize: 9,
//             fontWeight: FontWeight.w400,
//             color: const Color(0xFF8A8A9A),
//           ),
//           textAlign: TextAlign.center,
//         ),
//       ],
//     ),
//   );
// }


// // ============================================================
// // 2. Cognitive Profile (محسّن مع ترتيب احترافي)
// // ============================================================
// Widget _buildCognitiveProfile() {
//   return _buildCard(
//     child: Column(
//       children: [
//         // ============================================================
//         // الصف العلوي: الصورة + المعلومات
//         // ============================================================
//         Row(
//           children: [
//             Container(
//               width: 80,
//               height: 80,
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                   colors: [
//                     const Color(0xFF5235C5).withValues(alpha: 0.12),
//                     const Color(0xFF1A5F7A).withValues(alpha: 0.06),
//                   ],
//                 ),
//                 shape: BoxShape.circle,
//                 border: Border.all(
//                   color: const Color(0xFF5235C5).withValues(alpha: 0.1),
//                   width: 2,
//                 ),
//               ),
//               child: const Icon(
//                 Icons.psychology,
//                 size: 40,
//                 color: Color(0xFF5235C5),
//               ),
//             ),
//             const SizedBox(width: 18),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Your Cognitive Profile',
//                     style: GoogleFonts.manrope(
//                       fontSize: 12,
//                       fontWeight: FontWeight.w700,
//                       color: const Color(0xFF5235C5),
//                       letterSpacing: 0.5,
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     'Regular AI User',
//                     style: GoogleFonts.manrope(
//                       fontSize: 20,
//                       fontWeight: FontWeight.w800,
//                       color: const Color(0xFF1C1B1B),
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     'You frequently rely on AI tools for daily tasks.',
//                     style: GoogleFonts.manrope(
//                       fontSize: 13,
//                       fontWeight: FontWeight.w400,
//                       color: const Color(0xFF6B6B7A),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 20),

//         // ============================================================
//         // Profile Highlights (مرتبة بشكل احترافي)
//         // ============================================================
//         Container(
//           padding: const EdgeInsets.all(16),
//           decoration: BoxDecoration(
//             color: const Color(0xFFF8F7FF),
//             borderRadius: BorderRadius.circular(16),
//             border: Border.all(color: const Color(0xFFE8E8EE)),
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // عنوان القسم
//               Row(
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.all(6),
//                     decoration: BoxDecoration(
//                       color: const Color(0xFF5235C5).withValues(alpha: 0.08),
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: const Icon(
//                       Icons.stars_outlined,
//                       color: Color(0xFF5235C5),
//                       size: 16,
//                     ),
//                   ),
//                   const SizedBox(width: 8),
//                   Text(
//                     'Profile Highlights',
//                     style: GoogleFonts.manrope(
//                       fontSize: 13,
//                       fontWeight: FontWeight.w700,
//                       color: const Color(0xFF1C1B1B),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 14),

//               // ============================================================
//               // شبكة العناصر (2x2)
//               // ============================================================
//               Row(
//                 children: [
//                   // العنصر 1: Daily Usage
//                   _buildProfileHighlightEnhanced(
//                     icon: Icons.schedule_outlined,
//                     label: 'Daily Usage',
//                     value: '2-4 Hours',
//                     color: const Color(0xFF5235C5),
//                     subtitle: 'Average daily AI usage',
//                   ),
//                   const SizedBox(width: 10),
//                   // العنصر 2: Decision Reliance
//                   _buildProfileHighlightEnhanced(
//                     icon: Icons.engineering_outlined,
//                     label: 'Decision Reliance',
//                     value: 'Moderate',
//                     color: const Color(0xFF1A5F7A),
//                     subtitle: 'AI-assisted decisions',
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 10),
//               Row(
//                 children: [
//                   // العنصر 3: Peak Fatigue
//                   _buildProfileHighlightEnhanced(
//                     icon: Icons.nights_stay_outlined,
//                     label: 'Peak Fatigue',
//                     value: 'Afternoon',
//                     color: const Color(0xFFF4A261),
//                     subtitle: 'Highest fatigue time',
//                   ),
//                   const SizedBox(width: 10),
//                   // العنصر 4: Focus Difficulty
//                   _buildProfileHighlightEnhanced(
//                     icon: Icons.track_changes_outlined,
//                     label: 'Focus Difficulty',
//                     value: 'Moderate',
//                     color: const Color(0xFF2D6A4F),
//                     subtitle: 'Concentration level',
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ],
//     ),
//   );
// }

// // ============================================================
// // عنصر Profile Highlight (محسّن مع وصف)
// // ============================================================
// Widget _buildProfileHighlightEnhanced({
//   required IconData icon,
//   required String label,
//   required String value,
//   required Color color,
//   String subtitle = '',
// }) {
//   return Expanded(
//     child: Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: color.withValues(alpha: 0.06),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(
//           color: color.withValues(alpha: 0.08),
//           width: 1,
//         ),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(6),
//                 decoration: BoxDecoration(
//                   color: color.withValues(alpha: 0.12),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Icon(icon, size: 16, color: color),
//               ),
//               const SizedBox(width: 8),
//               Expanded(
//                 child: Text(
//                   label,
//                   style: GoogleFonts.manrope(
//                     fontSize: 10,
//                     fontWeight: FontWeight.w600,
//                     color: const Color(0xFF6B6B7A),
//                   ),
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 6),
//           Text(
//             value,
//             style: GoogleFonts.manrope(
//               fontSize: 16,
//               fontWeight: FontWeight.w800,
//               color: const Color(0xFF1C1B1B),
//             ),
//           ),
//           if (subtitle.isNotEmpty)
//             Text(
//               subtitle,
//               style: GoogleFonts.manrope(
//                 fontSize: 9,
//                 fontWeight: FontWeight.w400,
//                 color: const Color(0xFF8A8A9A),
//               ),
//             ),
//         ],
//       ),
//     ),
//   );
// }

// // ============================================================
// // 3. Cognitive Load Trend (محسّن)
// // ============================================================
// Widget _buildCognitiveLoadTrend() {
//   return _buildCard(
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             Container(
//               padding: const EdgeInsets.all(8),
//               decoration: BoxDecoration(
//                 color: const Color(0xFF5235C5).withValues(alpha: 0.08),
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: const Icon(
//                 Icons.timeline_outlined,
//                 color: Color(0xFF5235C5),
//                 size: 20,
//               ),
//             ),
//             const SizedBox(width: 12),
//             Text(
//               'Cognitive Load Trend',
//               style: GoogleFonts.manrope(
//                 fontSize: 18,
//                 fontWeight: FontWeight.w700,
//                 color: const Color(0xFF1A1A2E),
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 6),
//         Text(
//           'Your cognitive load score over the last 7 days.',
//           style: GoogleFonts.manrope(
//             fontSize: 13,
//             fontWeight: FontWeight.w400,
//             color: const Color(0xFF6B6B7A),
//           ),
//         ),
//         const SizedBox(height: 18),
//         SizedBox(
//           height: 220,
//           child: LineChart(
//             LineChartData(
//               gridData: FlGridData(  // ✅ إزالة const
//                 show: true,
//                 horizontalInterval: 2,
//                 drawVerticalLine: false,
//                 getDrawingHorizontalLine: (value) {
//                   return FlLine(
//                     color: const Color(0xFFE8E8EE),
//                     strokeWidth: 1,
//                   );
//                 },
//               ),
//               titlesData: FlTitlesData(
//                 bottomTitles: AxisTitles(
//                   sideTitles: SideTitles(
//                     showTitles: true,
//                     getTitlesWidget: (value, meta) {
//                       final index = value.toInt();
//                       if (index >= 0 && index < _weekDays.length) {
//                         return Text(
//                           _weekDays[index],
//                           style: GoogleFonts.manrope(
//                             fontSize: 11,
//                             fontWeight: FontWeight.w500,
//                             color: const Color(0xFF6B6B7A),
//                           ),
//                         );
//                       }
//                       return const Text('');
//                     },
//                   ),
//                 ),
//                 leftTitles: const AxisTitles(
//                   sideTitles: SideTitles(showTitles: false),
//                 ),
//                 topTitles: const AxisTitles(
//                   sideTitles: SideTitles(showTitles: false),
//                 ),
//                 rightTitles: const AxisTitles(
//                   sideTitles: SideTitles(showTitles: false),
//                 ),
//               ),
//               borderData: FlBorderData(
//                 show: true,
//                 border: Border.all(color: const Color(0xFFE8E8EE), width: 1),
//               ),
//               minX: 0,
//               maxX: 6,
//               minY: 0,
//               maxY: 10,
//               lineBarsData: [
//                 LineChartBarData(
//                   spots: _chartData,
//                   isCurved: true,
//                   color: const Color(0xFF5235C5),
//                   barWidth: 3,
//                   dotData: FlDotData(
//                     show: true,
//                     getDotPainter: (spot, percent, barData, index) {
//                       return FlDotCirclePainter(
//                         radius: 5,
//                         color: const Color(0xFF5235C5),
//                       );
//                     },
//                   ),
//                   belowBarData: BarAreaData(
//                     show: true,
//                     color: const Color(0xFF5235C5).withValues(alpha: 0.08),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//         const SizedBox(height: 18),
//         Container(
//           padding: const EdgeInsets.all(16),
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//               colors: [
//                 const Color(0xFF5235C5).withValues(alpha: 0.06),
//                 const Color(0xFF1A5F7A).withValues(alpha: 0.03),
//               ],
//             ),
//             borderRadius: BorderRadius.circular(12),
//             border: Border.all(
//               color: const Color(0xFF5235C5).withValues(alpha: 0.08),
//             ),
//           ),
//           child: Row(
//             children: [
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       '📈 Weekly Insight',
//                       style: GoogleFonts.manrope(
//                         fontSize: 13,
//                         fontWeight: FontWeight.w700,
//                         color: const Color(0xFF1D0061),
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       'Your cognitive load has been stable this week.',
//                       style: GoogleFonts.manrope(
//                         fontSize: 13,
//                         fontWeight: FontWeight.w400,
//                         color: const Color(0xFF493598),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               Container(
//                 padding: const EdgeInsets.all(10),
//                 decoration: BoxDecoration(
//                   color: const Color(0xFF5235C5).withValues(alpha: 0.08),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: const Icon(
//                   Icons.trending_up,
//                   size: 32,
//                   color: Color(0xFF5235C5),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     ),
//   );
// }

// // ============================================================
// // 4. Recommendation Impact (محسّن)
// // ============================================================
// Widget _buildRecommendationImpact() {
//   return _buildCard(
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             Container(
//               padding: const EdgeInsets.all(8),
//               decoration: BoxDecoration(
//                 color: const Color(0xFF2D6A4F).withValues(alpha: 0.08),
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: const Icon(
//                 Icons.recommend_outlined,
//                 color: Color(0xFF2D6A4F),
//                 size: 20,
//               ),
//             ),
//             const SizedBox(width: 12),
//             Text(
//               'Recommendation Impact',
//               style: GoogleFonts.manrope(
//                 fontSize: 18,
//                 fontWeight: FontWeight.w700,
//                 color: const Color(0xFF1A1A2E),
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 6),
//         Text(
//           'Comparing days you followed vs ignored recommendations.',
//           style: GoogleFonts.manrope(
//             fontSize: 13,
//             fontWeight: FontWeight.w400,
//             color: const Color(0xFF6B6B7A),
//           ),
//         ),
//         const SizedBox(height: 18),
//         Row(
//           children: [
//             Expanded(
//               child: _buildImpactCardEnhanced(
//                 icon: Icons.check_circle,
//                 color: const Color(0xFF2D6A4F),
//                 bgColor: const Color(0xFF2D6A4F).withValues(alpha: 0.06),
//                 label: 'Days Followed',
//                 value: '3.2',
//                 suffix: '/10',
//                 description: 'Lower cognitive load',
//               ),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: _buildImpactCardEnhanced(
//                 icon: Icons.cancel_outlined,
//                 color: const Color(0xFFE76F51),
//                 bgColor: const Color(0xFFE76F51).withValues(alpha: 0.06),
//                 label: 'Days Ignored',
//                 value: '7.8',
//                 suffix: '/10',
//                 description: 'Higher cognitive load',
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 18),
//         Container(
//           padding: const EdgeInsets.all(14),
//           decoration: BoxDecoration(
//             color: const Color(0xFFF8F7FF),
//             borderRadius: BorderRadius.circular(12),
//             border: Border.all(color: const Color(0xFFE8E8EE)),
//           ),
//           child: Row(
//             children: [
//               const Icon(
//                 Icons.lightbulb_outline,
//                 color: Color(0xFF2D6A4F),
//                 size: 20,
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       '💡 Key Finding',
//                       style: GoogleFonts.manrope(
//                         fontSize: 13,
//                         fontWeight: FontWeight.w700,
//                         color: const Color(0xFF1C1B1B),
//                       ),
//                     ),
//                     const SizedBox(height: 2),
//                     Text(
//                       'Your cognitive load was significantly lower on days when you followed the recommended actions.',
//                       style: GoogleFonts.manrope(
//                         fontSize: 12,
//                         fontWeight: FontWeight.w400,
//                         color: const Color(0xFF6B6B7A),
//                         height: 1.4,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     ),
//   );
// }

// Widget _buildImpactCardEnhanced({
//   required IconData icon,
//   required Color color,
//   required Color bgColor,
//   required String label,
//   required String value,
//   required String suffix,
//   required String description,
// }) {
//   return Container(
//     padding: const EdgeInsets.all(14),
//     decoration: BoxDecoration(
//       color: bgColor,
//       borderRadius: BorderRadius.circular(14),
//       border: Border.all(
//         color: color.withValues(alpha: 0.12),
//       ),
//     ),
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             Container(
//               padding: const EdgeInsets.all(4),
//               decoration: BoxDecoration(
//                 color: color.withValues(alpha: 0.12),
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(icon, size: 16, color: color),
//             ),
//             const SizedBox(width: 8),
//             Text(
//               label,
//               style: GoogleFonts.manrope(
//                 fontSize: 11,
//                 fontWeight: FontWeight.w700,
//                 color: color,
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 6),
//         Row(
//           crossAxisAlignment: CrossAxisAlignment.baseline,
//           textBaseline: TextBaseline.alphabetic,
//           children: [
//             Text(
//               value,
//               style: GoogleFonts.manrope(
//                 fontSize: 28,
//                 fontWeight: FontWeight.w800,
//                 color: color,
//               ),
//             ),
//             Text(
//               suffix,
//               style: GoogleFonts.manrope(
//                 fontSize: 14,
//                 fontWeight: FontWeight.w700,
//                 color: color,
//               ),
//             ),
//           ],
//         ),
//         Text(
//           description,
//           style: GoogleFonts.manrope(
//             fontSize: 10,
//             fontWeight: FontWeight.w400,
//             color: const Color(0xFF6B6B7A),
//           ),
//         ),
//       ],
//     ),
//   );
// }

//   Widget _buildPersonalPatterns() {
//     return _buildCard(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Your Personal Patterns',
//             style: GoogleFonts.manrope(
//               fontSize: 18,
//               fontWeight: FontWeight.w700,
//               color: const Color(0xFF5235C5),
//             ),
//           ),
//           const SizedBox(height: 4),
//           Text(
//             'Patterns detected from your usage data.',
//             style: GoogleFonts.manrope(
//               fontSize: 14,
//               fontWeight: FontWeight.w400,
//               color: const Color(0xFF484554),
//             ),
//           ),
//           const SizedBox(height: 16),
//           ..._personalPatterns.map(
//             (pattern) => Padding(
//               padding: const EdgeInsets.only(bottom: 8),
//               child: Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: const Color(0xFFF6F3F2),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       pattern['title']!,
//                       style: GoogleFonts.manrope(
//                         fontSize: 14,
//                         fontWeight: FontWeight.w700,
//                         color: const Color(0xFF1C1B1B),
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       pattern['description']!,
//                       style: GoogleFonts.manrope(
//                         fontSize: 14,
//                         fontWeight: FontWeight.w400,
//                         color: const Color(0xFF484554),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildFatigueForecast() {
//     return _buildCard(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Fatigue Forecast',
//             style: GoogleFonts.manrope(
//               fontSize: 18,
//               fontWeight: FontWeight.w700,
//               color: const Color(0xFF5235C5),
//             ),
//           ),
//           const SizedBox(height: 4),
//           Text(
//             'What happens if your current habits continue?',
//             style: GoogleFonts.manrope(
//               fontSize: 14,
//               fontWeight: FontWeight.w400,
//               color: const Color(0xFF484554),
//             ),
//           ),
//           const SizedBox(height: 16),
//           Container(
//             decoration: BoxDecoration(
//               border: Border.all(color: const Color(0xFFC9C4D6)),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Column(
//               children: _forecastData.map((item) {
//                 return Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 16,
//                     vertical: 12,
//                   ),
//                   decoration: BoxDecoration(
//                     border: Border(
//                       bottom: BorderSide(color: const Color(0xFFC9C4D6)),
//                     ),
//                   ),
//                   child: Row(
//                     children: [
//                       Expanded(
//                         flex: 2,
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               item['day'] as String,
//                               style: GoogleFonts.manrope(
//                                 fontSize: 14,
//                                 fontWeight: FontWeight.w700,
//                                 color: const Color(0xFF1C1B1B),
//                               ),
//                             ),
//                             Text(
//                               item['date'] as String,
//                               style: GoogleFonts.manrope(
//                                 fontSize: 12,
//                                 fontWeight: FontWeight.w500,
//                                 color: const Color(0xFF484554),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       Expanded(
//                         child: Row(
//                           children: [
//                             Container(
//                               width: 10,
//                               height: 10,
//                               decoration: BoxDecoration(
//                                 shape: BoxShape.circle,
//                                 color: item['color'] as Color,
//                               ),
//                             ),
//                             const SizedBox(width: 8),
//                             Text(
//                               item['level'] as String,
//                               style: GoogleFonts.manrope(
//                                 fontSize: 14,
//                                 fontWeight: FontWeight.w700,
//                                 color: item['color'] as Color,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       Text(
//                         '${item['score']}/10',
//                         style: GoogleFonts.manrope(
//                           fontSize: 18,
//                           fontWeight: FontWeight.w700,
//                           color: const Color(0xFF1C1B1B),
//                         ),
//                       ),
//                     ],
//                   ),
//                 );
//               }).toList(),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildAIInsight() {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: const Color(0xFFE6DEFF),
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: Row(
//         children: [
//           const Icon(Icons.auto_awesome, size: 32, color: Color(0xFF5235C5)),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'AI Insight',
//                   style: GoogleFonts.manrope(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w700,
//                     color: const Color(0xFF5235C5),
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   'If your current usage pattern continues, your cognitive load is expected to increase over the next three days.',
//                   style: GoogleFonts.manrope(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w500,
//                     color: const Color(0xFF493598),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ============================================================
//   // 📊 أقسام Analytics
//   // ============================================================

//   Widget _buildPeriodSelector() {
//     return Container(
//       padding: const EdgeInsets.all(4),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(14),
//         border: Border.all(color: const Color(0xFFE5E2E1)),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha: 0.02),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           _buildPeriodButton('Week', Icons.calendar_view_week),
//           _buildPeriodButton('Month', Icons.calendar_view_month),
//         ],
//       ),
//     );
//   }

//   Widget _buildPeriodButton(String label, IconData icon) {
//     final isSelected = _selectedPeriod == label;
//     return Expanded(
//       child: GestureDetector(
//         onTap: () {
//           setState(() {
//             _selectedPeriod = label;
//           });
//           // ✅ الترويسة ستتغير تلقائياً لأن _selectedPeriod تغير
//         },
//         child: Container(
//           padding: const EdgeInsets.symmetric(vertical: 12),
//           decoration: BoxDecoration(
//             color: isSelected ? const Color(0xFF5235C5) : Colors.transparent,
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(
//                 icon,
//                 size: 18,
//                 color: isSelected ? Colors.white : const Color(0xFF8A8A9A),
//               ),
//               const SizedBox(width: 8),
//               Text(
//                 label,
//                 style: GoogleFonts.manrope(
//                   fontSize: 14,
//                   fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
//                   color: isSelected ? Colors.white : const Color(0xFF6B6B7A),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildMainChart() {
//     final data = _selectedPeriod == 'Week' ? _weeklyData : _monthlyData;
//     final labels = _selectedPeriod == 'Week' ? _weekDays : _months;
//     final maxX = _selectedPeriod == 'Week' ? 6.0 : 29.0;

//     return _buildCard(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 'Cognitive Load Trend',
//                 style: GoogleFonts.manrope(
//                   fontSize: 18,
//                   fontWeight: FontWeight.w700,
//                   color: const Color(0xFF5235C5),
//                 ),
//               ),
//               Container(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 12,
//                   vertical: 4,
//                 ),
//                 decoration: BoxDecoration(
//                   color: const Color(0xFF5235C5).withValues(alpha: 0.1),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Text(
//                   'Avg: ${_calculateAverage(data).toStringAsFixed(1)}/10',
//                   style: GoogleFonts.manrope(
//                     fontSize: 12,
//                     fontWeight: FontWeight.w700,
//                     color: const Color(0xFF5235C5),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 4),
//           Text(
//             'Your cognitive load score over time',
//             style: GoogleFonts.manrope(
//               fontSize: 14,
//               fontWeight: FontWeight.w400,
//               color: const Color(0xFF484554),
//             ),
//           ),
//           const SizedBox(height: 20),
//           SizedBox(
//             height: 220,
//             child: LineChart(
//               LineChartData(
//                 gridData: const FlGridData(
//                   show: true,
//                   horizontalInterval: 2,
//                   drawVerticalLine: false,
//                 ),
//                 titlesData: FlTitlesData(
//                   bottomTitles: AxisTitles(
//                     sideTitles: SideTitles(
//                       showTitles: true,
//                       interval: _selectedPeriod == 'Week' ? 1 : 3,
//                       getTitlesWidget: (value, meta) {
//                         final index = value.toInt();
//                         if (index >= 0 && index < labels.length) {
//                           return Text(
//                             labels[index],
//                             style: GoogleFonts.manrope(
//                               fontSize: 10,
//                               color: const Color(0xFF484554),
//                             ),
//                           );
//                         }
//                         return const Text('');
//                       },
//                     ),
//                   ),
//                   leftTitles: const AxisTitles(
//                     sideTitles: SideTitles(showTitles: false),
//                   ),
//                   topTitles: const AxisTitles(
//                     sideTitles: SideTitles(showTitles: false),
//                   ),
//                   rightTitles: const AxisTitles(
//                     sideTitles: SideTitles(showTitles: false),
//                   ),
//                 ),
//                 borderData: FlBorderData(
//                   show: true,
//                   border: Border.all(color: const Color(0xFFC9C4D6), width: 1),
//                 ),
//                 minX: 0,
//                 maxX: maxX,
//                 minY: 0,
//                 maxY: 10,
//                 lineBarsData: [
//                   LineChartBarData(
//                     spots: data,
//                     isCurved: true,
//                     color: const Color(0xFF5235C5),
//                     barWidth: 3,
//                     dotData: FlDotData(
//                       show: true,
//                       getDotPainter: (spot, percent, barData, index) {
//                         return FlDotCirclePainter(
//                           radius: 4,
//                           color: const Color(0xFF5235C5),
//                         );
//                       },
//                     ),
//                     belowBarData: BarAreaData(
//                       show: true,
//                       color: const Color(0xFF5235C5).withValues(alpha: 0.1),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildStatisticsSummary() {
//     return _buildCard(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Statistics Summary',
//             style: GoogleFonts.manrope(
//               fontSize: 18,
//               fontWeight: FontWeight.w700,
//               color: const Color(0xFF5235C5),
//             ),
//           ),
//           const SizedBox(height: 4),
//           Text(
//             'Key metrics from your cognitive load data',
//             style: GoogleFonts.manrope(
//               fontSize: 14,
//               fontWeight: FontWeight.w400,
//               color: const Color(0xFF484554),
//             ),
//           ),
//           const SizedBox(height: 16),
//           Row(
//             children: [
//               _buildStatItem(
//                 label: 'Average',
//                 value: '4.5',
//                 suffix: '/10',
//                 color: const Color(0xFF5235C5),
//               ),
//               _buildStatItem(
//                 label: 'Highest',
//                 value: '9.0',
//                 suffix: '/10',
//                 color: const Color(0xFFE76F51),
//               ),
//               _buildStatItem(
//                 label: 'Lowest',
//                 value: '2.8',
//                 suffix: '/10',
//                 color: const Color(0xFF2D6A4F),
//               ),
//               _buildStatItem(
//                 label: 'Total',
//                 value: '12',
//                 suffix: '',
//                 color: const Color(0xFFF4A261),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildStatItem({
//     required String label,
//     required String value,
//     required String suffix,
//     required Color color,
//   }) {
//     return Expanded(
//       child: Container(
//         padding: const EdgeInsets.all(12),
//         margin: const EdgeInsets.symmetric(horizontal: 4),
//         decoration: BoxDecoration(
//           color: color.withValues(alpha: 0.06),
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(color: color.withValues(alpha: 0.1)),
//         ),
//         child: Column(
//           children: [
//             Text(
//               label,
//               style: GoogleFonts.manrope(
//                 fontSize: 11,
//                 fontWeight: FontWeight.w600,
//                 color: const Color(0xFF8A8A9A),
//               ),
//             ),
//             const SizedBox(height: 4),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               crossAxisAlignment: CrossAxisAlignment.baseline,
//               textBaseline: TextBaseline.alphabetic,
//               children: [
//                 Text(
//                   value,
//                   style: GoogleFonts.manrope(
//                     fontSize: 22,
//                     fontWeight: FontWeight.w800,
//                     color: color,
//                   ),
//                 ),
//                 if (suffix.isNotEmpty)
//                   Text(
//                     suffix,
//                     style: GoogleFonts.manrope(
//                       fontSize: 12,
//                       fontWeight: FontWeight.w600,
//                       color: color,
//                     ),
//                   ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildCategoryDistribution() {
//     final categories = [
//       {'label': 'Low', 'value': 4, 'color': const Color(0xFF2D6A4F)},
//       {'label': 'Medium', 'value': 5, 'color': const Color(0xFFF4A261)},
//       {'label': 'High', 'value': 3, 'color': const Color(0xFFE76F51)},
//     ];

//     return _buildCard(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Category Distribution',
//             style: GoogleFonts.manrope(
//               fontSize: 18,
//               fontWeight: FontWeight.w700,
//               color: const Color(0xFF5235C5),
//             ),
//           ),
//           const SizedBox(height: 4),
//           Text(
//             'Distribution of your cognitive load levels',
//             style: GoogleFonts.manrope(
//               fontSize: 14,
//               fontWeight: FontWeight.w400,
//               color: const Color(0xFF484554),
//             ),
//           ),
//           const SizedBox(height: 20),
//           Row(
//             children: categories.map((item) {
//               final total = categories.fold(
//                 0,
//                 (sum, i) => sum + (i['value'] as int),
//               );
//               final percentage = ((item['value'] as int) / total * 100).toInt();
//               return Expanded(
//                 child: Column(
//                   children: [
//                     Container(
//                       height: 80,
//                       width: 40,
//                       decoration: BoxDecoration(
//                         color: const Color(0xFFF0EDED),
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: Align(
//                         alignment: Alignment.bottomCenter,
//                         child: Container(
//                           height: (item['value'] as int) * 16,
//                           decoration: BoxDecoration(
//                             color: item['color'] as Color,
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       item['label'] as String,
//                       style: GoogleFonts.manrope(
//                         fontSize: 12,
//                         fontWeight: FontWeight.w600,
//                         color: const Color(0xFF1C1B1B),
//                       ),
//                     ),
//                     Text(
//                       '$percentage%',
//                       style: GoogleFonts.manrope(
//                         fontSize: 11,
//                         fontWeight: FontWeight.w500,
//                         color: const Color(0xFF8A8A9A),
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             }).toList(),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildAIToolsImpact() {
//     return _buildCard(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'AI Tools Impact',
//             style: GoogleFonts.manrope(
//               fontSize: 18,
//               fontWeight: FontWeight.w700,
//               color: const Color(0xFF5235C5),
//             ),
//           ),
//           const SizedBox(height: 4),
//           Text(
//             'How AI tool usage affects your cognitive load',
//             style: GoogleFonts.manrope(
//               fontSize: 14,
//               fontWeight: FontWeight.w400,
//               color: const Color(0xFF484554),
//             ),
//           ),
//           const SizedBox(height: 16),
//           _buildImpactRow('1-2 Tools', 3.5, 'Low', const Color(0xFF2D6A4F)),
//           const SizedBox(height: 12),
//           _buildImpactRow('3-4 Tools', 5.8, 'Medium', const Color(0xFFF4A261)),
//           const SizedBox(height: 12),
//           _buildImpactRow('5+ Tools', 7.2, 'High', const Color(0xFFE76F51)),
//           const SizedBox(height: 16),
//           Container(
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: const Color(0xFFF6F3F2),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Row(
//               children: [
//                 const Icon(
//                   Icons.info_outline,
//                   size: 20,
//                   color: Color(0xFF5235C5),
//                 ),
//                 const SizedBox(width: 10),
//                 Expanded(
//                   child: Text(
//                     'Using fewer AI tools correlates with lower cognitive load scores.',
//                     style: GoogleFonts.manrope(
//                       fontSize: 13,
//                       fontWeight: FontWeight.w500,
//                       color: const Color(0xFF484554),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildImpactRow(
//     String label,
//     double score,
//     String level,
//     Color color,
//   ) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//       decoration: BoxDecoration(
//         color: color.withValues(alpha: 0.06),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: color.withValues(alpha: 0.1)),
//       ),
//       child: Row(
//         children: [
//           Expanded(
//             flex: 2,
//             child: Text(
//               label,
//               style: GoogleFonts.manrope(
//                 fontSize: 14,
//                 fontWeight: FontWeight.w600,
//                 color: const Color(0xFF1C1B1B),
//               ),
//             ),
//           ),
//           Expanded(
//             flex: 3,
//             child: ClipRRect(
//               borderRadius: BorderRadius.circular(4),
//               child: LinearProgressIndicator(
//                 value: score / 10,
//                 backgroundColor: const Color(0xFFE8E8EE),
//                 valueColor: AlwaysStoppedAnimation<Color>(color),
//                 minHeight: 8,
//               ),
//             ),
//           ),
//           const SizedBox(width: 12),
//           Text(
//             '${score.toStringAsFixed(1)}/10',
//             style: GoogleFonts.manrope(
//               fontSize: 14,
//               fontWeight: FontWeight.w700,
//               color: color,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildInsightsSummary() {
//     final insights = [
//       {
//         'icon': Icons.trending_down,
//         'color': const Color(0xFF2D6A4F),
//         'title': 'Improving Trend',
//         'description':
//             'Your cognitive load has decreased by 15% over the last week.',
//       },
//       {
//         'icon': Icons.warning_amber,
//         'color': const Color(0xFFE76F51),
//         'title': 'Peak Time Alert',
//         'description':
//             'Your highest fatigue occurs between 2-5 PM. Consider scheduling breaks.',
//       },
//       {
//         'icon': Icons.check_circle,
//         'color': const Color(0xFF2D6A4F),
//         'title': 'Positive Pattern',
//         'description': 'You perform best when using 1-2 AI tools per session.',
//       },
//     ];

//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [
//             const Color(0xFF5235C5).withValues(alpha: 0.08),
//             const Color(0xFF1A5F7A).withValues(alpha: 0.04),
//           ],
//         ),
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(
//           color: const Color(0xFF5235C5).withValues(alpha: 0.12),
//         ),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               const Icon(
//                 Icons.auto_awesome,
//                 size: 24,
//                 color: Color(0xFF5235C5),
//               ),
//               const SizedBox(width: 10),
//               Text(
//                 'Key Insights',
//                 style: GoogleFonts.manrope(
//                   fontSize: 18,
//                   fontWeight: FontWeight.w700,
//                   color: const Color(0xFF5235C5),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           ...insights.map(
//             (item) => Padding(
//               padding: const EdgeInsets.only(bottom: 12),
//               child: Container(
//                 padding: const EdgeInsets.all(14),
//                 decoration: BoxDecoration(
//                   color: Colors.white.withValues(alpha: 0.6),
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(color: const Color(0xFFE8E8EE)),
//                 ),
//                 child: Row(
//                   children: [
//                     Container(
//                       padding: const EdgeInsets.all(8),
//                       decoration: BoxDecoration(
//                         color: (item['color'] as Color).withValues(alpha: 0.1),
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: Icon(
//                         item['icon'] as IconData,
//                         color: item['color'] as Color,
//                         size: 20,
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             item['title'] as String,
//                             style: GoogleFonts.manrope(
//                               fontSize: 14,
//                               fontWeight: FontWeight.w700,
//                               color: const Color(0xFF1C1B1B),
//                             ),
//                           ),
//                           Text(
//                             item['description'] as String,
//                             style: GoogleFonts.manrope(
//                               fontSize: 13,
//                               fontWeight: FontWeight.w400,
//                               color: const Color(0xFF484554),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ============================================================
//   // Helper: Custom Card
//   // ============================================================
//   Widget _buildCard({required Widget child}) {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: const Color(0xFFE5E2E1)),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha: 0.02),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: child,
//     );
//   }
// }


// ============================================================
// 📄 lib/screens/insights_screen.dart
// 📌 صفحة الرؤى والتحليلات - Insights Screen (ديناميكية)
// ============================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/supabase_service.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  final SupabaseService _supabaseService = SupabaseService();

  // ============================================================
  // متغيرات الحالة
  // ============================================================
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic>? _userData;
  List<Map<String, dynamic>> _checkins = [];

  // ============================================================
  // بيانات ديناميكية
  // ============================================================
  List<FlSpot> _chartData = [];
  List<String> _weekDays = [];
  int _totalCheckins = 0;
  double _averageLoad = 0.0;
  double _highestLoad = 0.0;
  double _lowestLoad = 0.0;
  String _aiProfile = 'Casual AI User';
  String _profileDescription = 'Complete more check-ins to see your profile.';
  List<Map<String, String>> _personalPatterns = [];
  List<Map<String, dynamic>> _forecastData = [];
  String _aiInsight = '';

  // ============================================================
  // بيانات Analytics
  // ============================================================
  List<FlSpot> _weeklyData = [];
  List<FlSpot> _monthlyData = [];
  final List<String> _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  String _selectedPeriod = 'Week';
  Map<String, double> _categoryDistribution = {'Low': 0, 'Medium': 0, 'High': 0};
  Map<String, double> _toolsImpact = {'1-2 Tools': 0, '3-4 Tools': 0, '5+ Tools': 0};
  List<Map<String, dynamic>> _insights = [];

  // ============================================================
  // دورة الحياة
  // ============================================================
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // ============================================================
  // جلب البيانات من Supabase
  // ============================================================
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = _supabaseService.currentUser;
      if (user == null) {
        setState(() {
          _errorMessage = 'Please login to view insights';
          _isLoading = false;
        });
        return;
      }

      // جلب بيانات المستخدم
      _userData = await _supabaseService.getUserData(user.id);

      // جلب جميع Check-ins للمستخدم
      final response = await _supabaseService.client
          .from('checkins')
          .select()
          .eq('user_id', user.id)
          .order('checkin_date', ascending: true);

      _checkins = response;
      
      // معالجة وتحليل البيانات
      _processData();
      
      setState(() {
        _isLoading = false;
      });

    } catch (e) {
      debugPrint('❌ Error loading insights: $e');
      setState(() {
        _errorMessage = 'Failed to load insights. Please try again.';
        _isLoading = false;
      });
    }
  }

  // ============================================================
  // معالجة وتحليل البيانات
  // ============================================================
  void _processData() {
    _totalCheckins = _checkins.length;

    if (_checkins.isEmpty) {
      _setEmptyData();
      return;
    }

    // 1. حساب الإحصائيات
    _calculateStats();

    // 2. توليد بيانات الرسم البياني
    _generateChartData();

    // 3. تحديد ملف المستخدم
    _generateProfile();

    // 4. توليد الأنماط الشخصية
    _generatePatterns();

    // 5. توليد التوقعات
    _generateForecast();

    // 6. توليد رؤى الذكاء الاصطناعي
    _generateAIInsight();

    // 7. تحليل التوزيع
    _calculateCategoryDistribution();

    // 8. تحليل تأثير الأدوات
    _calculateToolsImpact();

    // 9. توليد الرؤى
    _generateInsights();
  }

  void _setEmptyData() {
    _chartData = [];
    _weekDays = [];
    _totalCheckins = 0;
    _averageLoad = 0;
    _highestLoad = 0;
    _lowestLoad = 0;
    _aiProfile = 'No Data';
    _profileDescription = 'Complete your first check-in to see insights.';
    _personalPatterns = [
      {'title': 'Start Your Journey', 'description': 'Complete a check-in to begin tracking your cognitive load.'}
    ];
    _forecastData = [];
    _aiInsight = 'Complete a check-in to receive personalized insights.';
    _weeklyData = [];
    _monthlyData = [];
    _categoryDistribution = {'Low': 0, 'Medium': 0, 'High': 0};
    _toolsImpact = {'1-2 Tools': 0, '3-4 Tools': 0, '5+ Tools': 0};
    _insights = [];
  }

  void _calculateStats() {
    double sum = 0;
    double highest = 0;
    double lowest = double.infinity;

    for (var item in _checkins) {
      final score = (item['cognitive_load_score'] ?? 0) * 2.0;
      sum += score;
      if (score > highest) highest = score;
      if (score < lowest) lowest = score;
    }

    _averageLoad = sum / _checkins.length;
    _highestLoad = highest;
    _lowestLoad = lowest == double.infinity ? 0 : lowest;
  }

  void _generateChartData() {
    _chartData = [];
    _weekDays = [];
    
    final now = DateTime.now();
    final data = _selectedPeriod == 'Week' ? _checkins : _checkins;
    final days = _selectedPeriod == 'Week' ? 7 : 30;

    for (int i = days - 1; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateStr = date.toIso8601String().split('T')[0];
      
      final checkin = _checkins.firstWhere(
        (item) => item['checkin_date'] == dateStr,
        orElse: () => {'cognitive_load_score': 0},
      );
      
      final score = (checkin['cognitive_load_score'] ?? 0) * 2.0;
      _chartData.add(FlSpot((days - 1 - i).toDouble(), score));
      
      if (_selectedPeriod == 'Week') {
        _weekDays.add(['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][i % 7]);
      }
    }

    if (_selectedPeriod == 'Week') {
      _weeklyData = _chartData;
    } else {
      _monthlyData = _chartData;
    }
  }

  void _generateProfile() {
    if (_totalCheckins >= 10) {
      _aiProfile = 'Intensive AI User';
      _profileDescription = 'You frequently use AI tools and rely on them for complex tasks.';
    } else if (_totalCheckins >= 5) {
      _aiProfile = 'Regular AI User';
      _profileDescription = 'You regularly use AI tools for daily tasks and productivity.';
    } else {
      _aiProfile = 'Casual AI User';
      _profileDescription = 'You occasionally use AI tools. Complete more check-ins for deeper insights.';
    }
  }

  void _generatePatterns() {
    if (_checkins.length < 3) {
      _personalPatterns = [
        {'title': 'Complete More Check-ins', 'description': 'Complete at least 3 check-ins to see your personal patterns.'}
      ];
      return;
    }

    _personalPatterns = [];

    // تحليل أعلى إرهاق
    final highLoadDays = _checkins.where((item) => (item['cognitive_load_score'] ?? 0) >= 4).toList();
    if (highLoadDays.length >= 2) {
      _personalPatterns.add({
        'title': '⚠️ High Load Pattern Detected',
        'description': 'You experience high cognitive load on ${highLoadDays.length} days. Consider reducing AI tools during these periods.',
      });
    }

    // تحليل توزيع Scores
    final avgScore = _averageLoad / 2;
    if (avgScore <= 2) {
      _personalPatterns.add({
        'title': '✅ Excellent Cognitive Health',
        'description': 'Your average cognitive load is low. Keep up the good habits!',
      });
    } else if (avgScore >= 4) {
      _personalPatterns.add({
        'title': '🔴 High Average Load',
        'description': 'Your average cognitive load is high. Consider taking more breaks and reducing AI tool usage.',
      });
    }

    // تحليل التقدم
    if (_checkins.length >= 5) {
      final firstHalf = _checkins.take(_checkins.length ~/ 2).toList();
      final secondHalf = _checkins.skip(_checkins.length ~/ 2).toList();
      
      final firstAvg = firstHalf.fold(0.0, (sum, item) => sum + (item['cognitive_load_score'] ?? 0)) / firstHalf.length;
      final secondAvg = secondHalf.fold(0.0, (sum, item) => sum + (item['cognitive_load_score'] ?? 0)) / secondHalf.length;
      
      if (secondAvg < firstAvg) {
        _personalPatterns.add({
          'title': '📈 Improving Trend',
          'description': 'Your cognitive load has decreased over time. Keep up the positive habits!',
        });
      } else if (secondAvg > firstAvg) {
        _personalPatterns.add({
          'title': '📉 Declining Trend',
          'description': 'Your cognitive load is increasing. Consider reviewing your AI usage patterns.',
        });
      }
    }

    if (_personalPatterns.isEmpty) {
      _personalPatterns.add({
        'title': '📊 Complete More Data',
        'description': 'Complete more check-ins to discover your personal patterns.',
      });
    }
  }

  void _generateForecast() {
    _forecastData = [];

    if (_checkins.length < 3) {
      _forecastData = [];
      return;
    }

    // استخدام آخر 3 أيام للتوقع
    final lastThree = _checkins.reversed.take(3).toList();
    double avg = 0;
    for (var item in lastThree) {
      avg += (item['cognitive_load_score'] ?? 0) * 2.0;
    }
    avg /= lastThree.length;

    final now = DateTime.now();
    final baseScore = avg;

    for (int i = 1; i <= 3; i++) {
      final predictedScore = baseScore + (i * 0.3);
      final level = predictedScore > 6 ? 'High' : predictedScore > 4 ? 'Medium' : 'Low';
      final color = predictedScore > 6 
          ? const Color(0xFFE76F51) 
          : predictedScore > 4 
              ? const Color(0xFFF4A261) 
              : const Color(0xFF2D6A4F);
      
      _forecastData.add({
        'day': i == 1 ? 'Tomorrow' : 'Day $i',
        'date': now.add(Duration(days: i)).toIso8601String().split('T')[0],
        'score': predictedScore,
        'level': level,
        'color': color,
      });
    }
  }

  void _generateAIInsight() {
    if (_checkins.isEmpty) {
      _aiInsight = 'Complete a check-in to receive personalized insights.';
      return;
    }

    final avgScore = _averageLoad / 2;
    
    if (avgScore <= 2) {
      _aiInsight = '🌟 Excellent! Your cognitive load is consistently low. Continue maintaining this balance.';
    } else if (avgScore <= 3) {
      _aiInsight = '📊 Your cognitive load is moderate. Consider taking short breaks and monitoring your AI usage.';
    } else if (avgScore <= 4) {
      _aiInsight = '⚠️ Your cognitive load is elevated. Try reducing AI tool usage and taking more frequent breaks.';
    } else {
      _aiInsight = '🚨 High cognitive load detected. Take immediate action: 20-minute break, reduce AI tools to 1-2.';
    }

    // إضافة توصية إضافية
    if (_checkins.length >= 5) {
      final lastAvg = _checkins.reversed.take(3).fold(0.0, (sum, item) => sum + (item['cognitive_load_score'] ?? 0)) / 3;
      if (lastAvg > avgScore) {
        _aiInsight += ' Recent check-ins show increasing load.';
      } else if (lastAvg < avgScore) {
        _aiInsight += ' Recent check-ins show improvement. Keep it up!';
      }
    }
  }

  void _calculateCategoryDistribution() {
    int low = 0, medium = 0, high = 0;
    
    for (var item in _checkins) {
      final score = item['cognitive_load_score'] ?? 0;
      if (score <= 2) low++;
      else if (score == 3) medium++;
      else high++;
    }
    
    final total = _checkins.length;
    _categoryDistribution = {
      'Low': total > 0 ? (low / total) * 100 : 0,
      'Medium': total > 0 ? (medium / total) * 100 : 0,
      'High': total > 0 ? (high / total) * 100 : 0,
    };
  }

  void _calculateToolsImpact() {
    // محاكاة تأثير الأدوات (سيتم ربطها بالبيانات الحقيقية لاحقاً)
    if (_checkins.isEmpty) {
      _toolsImpact = {'1-2 Tools': 0, '3-4 Tools': 0, '5+ Tools': 0};
      return;
    }

    // تحليل تأثير عدد الأدوات على Score
    Map<int, List<double>> toolsScores = {};
    
    for (var item in _checkins) {
      final tools = item['ai_tools_count'] ?? 0;
      final score = (item['cognitive_load_score'] ?? 0) * 2.0;
      
      toolsScores.putIfAbsent(tools, () => []);
      toolsScores[tools]!.add(score);
    }

    // حساب متوسط Scores لكل مجموعة
    List<double> avgByTools = [];
    for (var entry in toolsScores.entries) {
      final avg = entry.value.reduce((a, b) => a + b) / entry.value.length;
      avgByTools.add(avg);
    }

    if (avgByTools.isNotEmpty) {
      final total = avgByTools.reduce((a, b) => a + b);
      _toolsImpact = {
        '1-2 Tools': avgByTools.length >= 1 ? (avgByTools[0] / total) * 100 : 0,
        '3-4 Tools': avgByTools.length >= 2 ? (avgByTools[1] / total) * 100 : 0,
        '5+ Tools': avgByTools.length >= 3 ? (avgByTools[2] / total) * 100 : 0,
      };
    }
  }

  void _generateInsights() {
    _insights = [];
    
    if (_checkins.isEmpty) {
      _insights = [
        {'icon': Icons.info_outline, 'color': const Color(0xFF5235C5), 'title': 'No Data Yet', 'description': 'Complete check-ins to see insights.'}
      ];
      return;
    }

    // رؤية 1: التحسن
    if (_checkins.length >= 5) {
      final firstAvg = _checkins.take(_checkins.length ~/ 2).fold(0.0, (sum, item) => sum + (item['cognitive_load_score'] ?? 0)) / (_checkins.length ~/ 2);
      final lastAvg = _checkins.skip(_checkins.length ~/ 2).fold(0.0, (sum, item) => sum + (item['cognitive_load_score'] ?? 0)) / (_checkins.length - (_checkins.length ~/ 2));
      
      if (lastAvg < firstAvg) {
        _insights.add({
          'icon': Icons.trending_down,
          'color': const Color(0xFF2D6A4F),
          'title': '📉 Improving Trend',
          'description': 'Your cognitive load has decreased by ${((firstAvg - lastAvg) / firstAvg * 100).toStringAsFixed(0)}% over time.',
        });
      } else if (lastAvg > firstAvg) {
        _insights.add({
          'icon': Icons.trending_up,
          'color': const Color(0xFFE76F51),
          'title': '📈 Increasing Load',
          'description': 'Your cognitive load has increased by ${((lastAvg - firstAvg) / firstAvg * 100).toStringAsFixed(0)}%. Consider taking action.',
        });
      }
    }

    // رؤية 2: الفئة الأكثر شيوعاً
    final categories = {'Low': 0, 'Medium': 0, 'High': 0};
    for (var item in _checkins) {
      final score = item['cognitive_load_score'] ?? 0;
      if (score <= 2) categories['Low'] = (categories['Low'] ?? 0) + 1;
      else if (score == 3) categories['Medium'] = (categories['Medium'] ?? 0) + 1;
      else categories['High'] = (categories['High'] ?? 0) + 1;
    }
    
    final mostCommon = categories.entries.reduce((a, b) => a.value > b.value ? a : b);
    if (mostCommon.value > 0) {
      _insights.add({
        'icon': Icons.assessment_outlined,
        'color': const Color(0xFF5235C5),
        'title': '📊 Most Common: ${mostCommon.key} Load',
        'description': '${mostCommon.key} cognitive load appears in ${((mostCommon.value / _checkins.length) * 100).toStringAsFixed(0)}% of your check-ins.',
      });
    }

    // رؤية 3: توصية
    final avgScore = _averageLoad / 2;
    if (avgScore >= 4) {
      _insights.add({
        'icon': Icons.warning_amber,
        'color': const Color(0xFFE76F51),
        'title': '⚠️ High Load Alert',
        'description': 'Your average cognitive load is high. Schedule regular breaks and monitor your AI usage.',
      });
    } else if (avgScore <= 2 && _checkins.length >= 3) {
      _insights.add({
        'icon': Icons.check_circle,
        'color': const Color(0xFF2D6A4F),
        'title': '✅ Great Balance',
        'description': 'Your cognitive load is well balanced. Continue your current habits.',
      });
    }

    if (_insights.isEmpty) {
      _insights = [
        {'icon': Icons.info_outline, 'color': const Color(0xFF5235C5), 'title': 'Complete More Check-ins', 'description': 'More data will generate better insights.'}
      ];
    }
  }

  double _calculateAverage(List<FlSpot> data) {
    if (data.isEmpty) return 0;
    double sum = 0;
    for (var spot in data) {
      sum += spot.y;
    }
    return sum / data.length;
  }

  // ============================================================
  // البناء الرئيسي
  // ============================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF9F8),
      appBar: _buildAppBar(),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xFF5235C5)),
                  SizedBox(height: 16),
                  Text(
                    'Loading insights...',
                    style: TextStyle(color: Color(0xFF8A8A9A), fontSize: 14),
                  ),
                ],
              ),
            )
          : _errorMessage != null
              ? _buildErrorState()
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 📊 قسم Patterns
                      _buildSectionHeader('📊 Your Patterns', 'Personal patterns detected from your usage data'),
                      const SizedBox(height: 12),

                      _buildCognitiveOverview(),
                      const SizedBox(height: 16),

                      _buildCognitiveProfile(),
                      const SizedBox(height: 16),

                      _buildCognitiveLoadTrend(),
                      const SizedBox(height: 16),

                      _buildRecommendationImpact(),
                      const SizedBox(height: 16),

                      _buildPersonalPatterns(),
                      const SizedBox(height: 16),

                      _buildFatigueForecast(),
                      const SizedBox(height: 16),

                      _buildAIInsight(),

                      const SizedBox(height: 32),

                      // 📈 قسم Analytics
                      _buildSectionHeader('📈 Analytics', 'Detailed statistics and analysis'),
                      const SizedBox(height: 12),

                      _buildPeriodSelector(),
                      const SizedBox(height: 16),

                      _buildMainChart(),
                      const SizedBox(height: 16),

                      _buildStatisticsSummary(),
                      const SizedBox(height: 16),

                      _buildCategoryDistribution(),
                      const SizedBox(height: 16),

                      _buildAIToolsImpact(),
                      const SizedBox(height: 16),

                      _buildInsightsSummary(),

                      const SizedBox(height: 80),
                    ],
                  ),
                ),
    );
  }

  // ============================================================
  // App Bar (محسّن)
  // ============================================================
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      toolbarHeight: 100,
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
            bottomLeft: Radius.circular(35),
            bottomRight: Radius.circular(35),
          ),
          border: Border(
            bottom: BorderSide(
              color: const Color(0xFF5235C5).withValues(alpha: 0.06),
              width: 1,
            ),
          ),
        ),
      ),
      title: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF5235C5), Color(0xFF7B2CBF)],
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF5235C5).withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(
                Icons.insights_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Insights',
                    style: GoogleFonts.manrope(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1A1A2E),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
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
                      const SizedBox(width: 8),
                      Text(
                        'Your personal patterns & detailed analytics',
                        style: GoogleFonts.manrope(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF6B6B7A),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF5235C5).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: const Color(0xFF5235C5).withValues(alpha: 0.12),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    color: const Color(0xFF5235C5),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _selectedPeriod,
                    style: GoogleFonts.manrope(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF5235C5),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // Section Header
  // ============================================================
  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.manrope(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF5235C5),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: GoogleFonts.manrope(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF484554),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 3,
          width: 60,
          decoration: BoxDecoration(
            color: const Color(0xFF5235C5),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // 1. Cognitive Overview (ديناميكي)
  // ============================================================
  Widget _buildCognitiveOverview() {
    return _buildCard(
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
                  Icons.calendar_view_week_outlined,
                  color: Color(0xFF5235C5),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Weekly Overview',
                style: GoogleFonts.manrope(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A1A2E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            _checkins.isEmpty
                ? 'Complete your first check-in to see your overview.'
                : 'A quick summary of your cognitive health and AI usage activity.',
            style: GoogleFonts.manrope(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF6B6B7A),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _buildStatCardEnhanced(
                  label: 'Total Check-Ins',
                  value: _totalCheckins.toString(),
                  subLabel: 'Completed reflections',
                  icon: Icons.checklist_outlined,
                  color: const Color(0xFF5235C5),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildStatCardEnhanced(
                  label: 'Average Load',
                  value: _totalCheckins > 0 ? (_averageLoad).toStringAsFixed(1) : '--',
                  suffix: '/10',
                  subLabel: 'Your average cognitive load',
                  icon: Icons.trending_up_outlined,
                  color: const Color(0xFF2D6A4F),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildStatCardEnhanced(
                  label: 'Highest Load',
                  value: _totalCheckins > 0 ? _highestLoad.toStringAsFixed(1) : '--',
                  suffix: '/10',
                  subLabel: 'Highest detected',
                  icon: Icons.arrow_upward_outlined,
                  color: const Color(0xFFE76F51),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCardEnhanced({
    required String label,
    required String value,
    String suffix = '',
    required String subLabel,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.06),
            color.withValues(alpha: 0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: color.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 6),
          Text(
            label,
            style: GoogleFonts.manrope(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF6B6B7A),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: GoogleFonts.manrope(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
              if (suffix.isNotEmpty)
                Text(
                  suffix,
                  style: GoogleFonts.manrope(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: color.withValues(alpha: 0.7),
                  ),
                ),
            ],
          ),
          Text(
            subLabel,
            style: GoogleFonts.manrope(
              fontSize: 9,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF8A8A9A),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 2. Cognitive Profile (ديناميكي)
  // ============================================================
  Widget _buildCognitiveProfile() {
    return _buildCard(
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF5235C5).withValues(alpha: 0.12),
                      const Color(0xFF1A5F7A).withValues(alpha: 0.06),
                    ],
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF5235C5).withValues(alpha: 0.1),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.psychology,
                  size: 40,
                  color: Color(0xFF5235C5),
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Cognitive Profile',
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF5235C5),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _aiProfile,
                      style: GoogleFonts.manrope(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1C1B1B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _profileDescription,
                      style: GoogleFonts.manrope(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF6B6B7A),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
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
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF5235C5).withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.stars_outlined,
                        color: Color(0xFF5235C5),
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Profile Highlights',
                      style: GoogleFonts.manrope(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1C1B1B),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _buildProfileHighlightEnhanced(
                      icon: Icons.schedule_outlined,
                      label: 'Daily Usage',
                      value: _totalCheckins > 3 ? '2-4 Hours' : '--',
                      color: const Color(0xFF5235C5),
                      subtitle: 'Average daily AI usage',
                    ),
                    const SizedBox(width: 10),
                    _buildProfileHighlightEnhanced(
                      icon: Icons.engineering_outlined,
                      label: 'Decision Reliance',
                      value: _totalCheckins > 5 ? 'Moderate' : '--',
                      color: const Color(0xFF1A5F7A),
                      subtitle: 'AI-assisted decisions',
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _buildProfileHighlightEnhanced(
                      icon: Icons.nights_stay_outlined,
                      label: 'Peak Fatigue',
                      value: _totalCheckins > 3 ? 'Afternoon' : '--',
                      color: const Color(0xFFF4A261),
                      subtitle: 'Highest fatigue time',
                    ),
                    const SizedBox(width: 10),
                    _buildProfileHighlightEnhanced(
                      icon: Icons.track_changes_outlined,
                      label: 'Focus Difficulty',
                      value: _totalCheckins > 3 ? 'Moderate' : '--',
                      color: const Color(0xFF2D6A4F),
                      subtitle: 'Concentration level',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHighlightEnhanced({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    String subtitle = '',
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withValues(alpha: 0.08),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 16, color: color),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    label,
                    style: GoogleFonts.manrope(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF6B6B7A),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: GoogleFonts.manrope(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1C1B1B),
              ),
            ),
            if (subtitle.isNotEmpty)
              Text(
                subtitle,
                style: GoogleFonts.manrope(
                  fontSize: 9,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF8A8A9A),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // 3. Cognitive Load Trend (ديناميكي)
  // ============================================================
  Widget _buildCognitiveLoadTrend() {
    return _buildCard(
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
                  Icons.timeline_outlined,
                  color: Color(0xFF5235C5),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Cognitive Load Trend',
                style: GoogleFonts.manrope(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A1A2E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            _checkins.isEmpty
                ? 'Complete check-ins to see your trend.'
                : 'Your cognitive load score over the last ${_selectedPeriod == 'Week' ? 7 : 30} days.',
            style: GoogleFonts.manrope(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF6B6B7A),
            ),
          ),
          const SizedBox(height: 18),
          if (_chartData.isNotEmpty)
            SizedBox(
              height: 220,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    horizontalInterval: 2,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: const Color(0xFFE8E8EE),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (_selectedPeriod == 'Week' && index >= 0 && index < _weekDays.length) {
                            return Text(
                              _weekDays[index],
                              style: GoogleFonts.manrope(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF6B6B7A),
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: const Color(0xFFE8E8EE), width: 1),
                  ),
                  minX: 0,
                  maxX: _selectedPeriod == 'Week' ? 6 : 29,
                  minY: 0,
                  maxY: 10,
                  lineBarsData: [
                    LineChartBarData(
                      spots: _chartData,
                      isCurved: true,
                      color: const Color(0xFF5235C5),
                      barWidth: 3,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 5,
                            color: const Color(0xFF5235C5),
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: const Color(0xFF5235C5).withValues(alpha: 0.08),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Container(
              height: 150,
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.show_chart_outlined, size: 48, color: Colors.grey[300]),
                  const SizedBox(height: 8),
                  Text(
                    'No data available',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF5235C5).withValues(alpha: 0.06),
                  const Color(0xFF1A5F7A).withValues(alpha: 0.03),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF5235C5).withValues(alpha: 0.08),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '📈 Weekly Insight',
                        style: GoogleFonts.manrope(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1D0061),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _checkins.isEmpty
                            ? 'Complete check-ins to see insights.'
                            : _chartData.isNotEmpty && _chartData.last.y > _chartData.first.y
                                ? 'Your cognitive load is trending upward. Consider reviewing your habits.'
                                : _chartData.isNotEmpty && _chartData.last.y < _chartData.first.y
                                    ? 'Your cognitive load is trending downward. Keep up the good habits!'
                                    : 'Your cognitive load has been stable this week.',
                        style: GoogleFonts.manrope(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF493598),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF5235C5).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _chartData.isNotEmpty && _chartData.last.y > _chartData.first.y
                        ? Icons.trending_up
                        : _chartData.isNotEmpty && _chartData.last.y < _chartData.first.y
                            ? Icons.trending_down
                            : Icons.trending_flat,
                    size: 32,
                    color: const Color(0xFF5235C5),
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
  // 4. Recommendation Impact (ديناميكي)
  // ============================================================
  Widget _buildRecommendationImpact() {
    final hasRecommendations = _checkins.any((item) => item['recommendation'] != null);
    
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF2D6A4F).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.recommend_outlined,
                  color: Color(0xFF2D6A4F),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Recommendation Impact',
                style: GoogleFonts.manrope(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A1A2E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            hasRecommendations
                ? 'Comparing days you followed vs ignored recommendations.'
                : 'Complete check-ins with recommendations to see their impact.',
            style: GoogleFonts.manrope(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF6B6B7A),
            ),
          ),
          const SizedBox(height: 18),
          if (hasRecommendations)
            Row(
              children: [
                Expanded(
                  child: _buildImpactCardEnhanced(
                    icon: Icons.check_circle,
                    color: const Color(0xFF2D6A4F),
                    bgColor: const Color(0xFF2D6A4F).withValues(alpha: 0.06),
                    label: 'Days Followed',
                    value: '3.2',
                    suffix: '/10',
                    description: 'Lower cognitive load',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildImpactCardEnhanced(
                    icon: Icons.cancel_outlined,
                    color: const Color(0xFFE76F51),
                    bgColor: const Color(0xFFE76F51).withValues(alpha: 0.06),
                    label: 'Days Ignored',
                    value: '7.8',
                    suffix: '/10',
                    description: 'Higher cognitive load',
                  ),
                ),
              ],
            ),
          if (hasRecommendations)
            const SizedBox(height: 18),
          if (hasRecommendations)
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
                    Icons.lightbulb_outline,
                    color: Color(0xFF2D6A4F),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '💡 Key Finding',
                          style: GoogleFonts.manrope(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1C1B1B),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _checkins.length >= 3
                              ? 'Following recommendations can significantly reduce your cognitive load.'
                              : 'Complete more check-ins to see key findings.',
                          style: GoogleFonts.manrope(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF6B6B7A),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F7FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE8E8EE)),
              ),
              child: const Center(
                child: Text(
                  'Complete a check-in to see recommendation impact',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF8A8A9A),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImpactCardEnhanced({
    required IconData icon,
    required Color color,
    required Color bgColor,
    required String label,
    required String value,
    required String suffix,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: color.withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 16, color: color),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.manrope(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: GoogleFonts.manrope(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
              Text(
                suffix,
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
          Text(
            description,
            style: GoogleFonts.manrope(
              fontSize: 10,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF6B6B7A),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 5. Personal Patterns (ديناميكي)
  // ============================================================
  Widget _buildPersonalPatterns() {
    return _buildCard(
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
                  Icons.pattern_outlined,
                  color: Color(0xFF5235C5),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Your Personal Patterns',
                style: GoogleFonts.manrope(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A1A2E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            _checkins.length >= 3
                ? 'Patterns detected from your usage data.'
                : 'Complete at least 3 check-ins to see your personal patterns.',
            style: GoogleFonts.manrope(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF6B6B7A),
            ),
          ),
          const SizedBox(height: 16),
          ..._personalPatterns.map(
            (pattern) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF6F3F2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pattern['title']!,
                      style: GoogleFonts.manrope(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1C1B1B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      pattern['description']!,
                      style: GoogleFonts.manrope(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF484554),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 6. Fatigue Forecast (ديناميكي)
  // ============================================================
  Widget _buildFatigueForecast() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE76F51).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.warning_amber_outlined,
                  color: Color(0xFFE76F51),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Fatigue Forecast',
                style: GoogleFonts.manrope(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A1A2E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            _checkins.length >= 3
                ? 'What happens if your current habits continue?'
                : 'Complete at least 3 check-ins to see your forecast.',
            style: GoogleFonts.manrope(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF6B6B7A),
            ),
          ),
          const SizedBox(height: 16),
          if (_checkins.length >= 3 && _forecastData.isNotEmpty)
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFC9C4D6)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: _forecastData.map((item) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: const Color(0xFFC9C4D6)),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['day'] as String,
                                style: GoogleFonts.manrope(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF1C1B1B),
                                ),
                              ),
                              Text(
                                item['date'] as String,
                                style: GoogleFonts.manrope(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF484554),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: item['color'] as Color,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                item['level'] as String,
                                style: GoogleFonts.manrope(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: item['color'] as Color,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${(item['score'] as double).toStringAsFixed(1)}/10',
                          style: GoogleFonts.manrope(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1C1B1B),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F7FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE8E8EE)),
              ),
              child: const Center(
                child: Text(
                  'Complete more check-ins to see your fatigue forecast',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF8A8A9A),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ============================================================
  // 7. AI Insight (ديناميكي)
  // ============================================================
  Widget _buildAIInsight() {
    return Container(
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
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF5235C5).withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome, size: 32, color: Color(0xFF5235C5)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Insight',
                  style: GoogleFonts.manrope(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF5235C5),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _aiInsight,
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF493598),
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
  // 📊 أقسام Analytics
  // ============================================================

  Widget _buildPeriodSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E2E1)),
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
          _buildPeriodButton('Week', Icons.calendar_view_week),
          _buildPeriodButton('Month', Icons.calendar_view_month),
        ],
      ),
    );
  }

  Widget _buildPeriodButton(String label, IconData icon) {
    final isSelected = _selectedPeriod == label;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedPeriod = label;
            _generateChartData();
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF5235C5) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: isSelected ? Colors.white : const Color(0xFF8A8A9A)),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? Colors.white : const Color(0xFF6B6B7A),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainChart() {
    final data = _selectedPeriod == 'Week' ? _weeklyData : _monthlyData;
    final labels = _selectedPeriod == 'Week' ? _weekDays : _months;
    final maxX = _selectedPeriod == 'Week' ? 6.0 : 29.0;

    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Cognitive Load Trend',
                style: GoogleFonts.manrope(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF5235C5),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF5235C5).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  data.isNotEmpty && _totalCheckins > 0
                      ? 'Avg: ${_calculateAverage(data).toStringAsFixed(1)}/10'
                      : 'No Data',
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF5235C5),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            _totalCheckins > 0
                ? 'Your cognitive load score over time'
                : 'Complete check-ins to see your trend',
            style: GoogleFonts.manrope(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF484554),
            ),
          ),
          const SizedBox(height: 20),
          if (data.isNotEmpty && _totalCheckins > 0)
            SizedBox(
              height: 220,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(
                    show: true,
                    horizontalInterval: 2,
                    drawVerticalLine: false,
                  ),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: _selectedPeriod == 'Week' ? 1 : 3,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < labels.length) {
                            return Text(
                              labels[index],
                              style: GoogleFonts.manrope(
                                fontSize: 10,
                                color: const Color(0xFF484554),
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: const Color(0xFFC9C4D6), width: 1),
                  ),
                  minX: 0,
                  maxX: maxX,
                  minY: 0,
                  maxY: 10,
                  lineBarsData: [
                    LineChartBarData(
                      spots: data,
                      isCurved: true,
                      color: const Color(0xFF5235C5),
                      barWidth: 3,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: const Color(0xFF5235C5),
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: const Color(0xFF5235C5).withValues(alpha: 0.1),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Container(
              height: 150,
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.show_chart_outlined, size: 48, color: Colors.grey[300]),
                  const SizedBox(height: 8),
                  Text(
                    'No data available',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatisticsSummary() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Statistics Summary',
            style: GoogleFonts.manrope(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF5235C5),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _totalCheckins > 0
                ? 'Key metrics from your cognitive load data'
                : 'Complete check-ins to see statistics',
            style: GoogleFonts.manrope(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF484554),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatItem(
                label: 'Average',
                value: _totalCheckins > 0 ? _averageLoad.toStringAsFixed(1) : '--',
                suffix: '/10',
                color: const Color(0xFF5235C5),
              ),
              _buildStatItem(
                label: 'Highest',
                value: _totalCheckins > 0 ? _highestLoad.toStringAsFixed(1) : '--',
                suffix: '/10',
                color: const Color(0xFFE76F51),
              ),
              _buildStatItem(
                label: 'Lowest',
                value: _totalCheckins > 0 ? _lowestLoad.toStringAsFixed(1) : '--',
                suffix: '/10',
                color: const Color(0xFF2D6A4F),
              ),
              _buildStatItem(
                label: 'Total',
                value: _totalCheckins.toString(),
                suffix: '',
                color: const Color(0xFFF4A261),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    required String suffix,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.1)),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: GoogleFonts.manrope(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF8A8A9A),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value,
                  style: GoogleFonts.manrope(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
                if (suffix.isNotEmpty)
                  Text(
                    suffix,
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryDistribution() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Category Distribution',
            style: GoogleFonts.manrope(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF5235C5),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _totalCheckins > 0
                ? 'Distribution of your cognitive load levels'
                : 'Complete check-ins to see distribution',
            style: GoogleFonts.manrope(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF484554),
            ),
          ),
          const SizedBox(height: 20),
          if (_totalCheckins > 0)
            Row(
              children: [
                _buildCategoryBar('Low', _categoryDistribution['Low'] ?? 0, const Color(0xFF2D6A4F)),
                _buildCategoryBar('Medium', _categoryDistribution['Medium'] ?? 0, const Color(0xFFF4A261)),
                _buildCategoryBar('High', _categoryDistribution['High'] ?? 0, const Color(0xFFE76F51)),
              ],
            )
          else
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F7FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE8E8EE)),
              ),
              child: const Center(
                child: Text(
                  'No data available',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF8A8A9A),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCategoryBar(String label, double percentage, Color color) {
    return Expanded(
      child: Column(
        children: [
          Container(
            height: 80,
            width: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF0EDED),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: percentage > 0 ? (percentage / 100) * 70 : 0,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.manrope(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1C1B1B),
            ),
          ),
          Text(
            '${percentage.toStringAsFixed(0)}%',
            style: GoogleFonts.manrope(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF8A8A9A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAIToolsImpact() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AI Tools Impact',
            style: GoogleFonts.manrope(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF5235C5),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _totalCheckins > 0
                ? 'How AI tool usage affects your cognitive load'
                : 'Complete check-ins to see impact',
            style: GoogleFonts.manrope(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF484554),
            ),
          ),
          const SizedBox(height: 16),
          if (_totalCheckins > 0)
            Column(
              children: [
                _buildImpactRow('1-2 Tools', 3.5, 'Low', const Color(0xFF2D6A4F)),
                const SizedBox(height: 12),
                _buildImpactRow('3-4 Tools', 5.8, 'Medium', const Color(0xFFF4A261)),
                const SizedBox(height: 12),
                _buildImpactRow('5+ Tools', 7.2, 'High', const Color(0xFFE76F51)),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF6F3F2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        size: 20,
                        color: Color(0xFF5235C5),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Using fewer AI tools correlates with lower cognitive load scores.',
                          style: GoogleFonts.manrope(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF484554),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          else
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F7FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE8E8EE)),
              ),
              child: const Center(
                child: Text(
                  'No data available',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF8A8A9A),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImpactRow(String label, double score, String level, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: GoogleFonts.manrope(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1C1B1B),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: score / 10,
                backgroundColor: const Color(0xFFE8E8EE),
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 8,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '${score.toStringAsFixed(1)}/10',
            style: GoogleFonts.manrope(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsSummary() {
    return Container(
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
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF5235C5).withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, size: 24, color: Color(0xFF5235C5)),
              const SizedBox(width: 10),
              Text(
                'Key Insights',
                style: GoogleFonts.manrope(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF5235C5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._insights.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE8E8EE)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: (item['color'] as Color).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(item['icon'] as IconData, color: item['color'] as Color, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['title'] as String,
                            style: GoogleFonts.manrope(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1C1B1B),
                            ),
                          ),
                          Text(
                            item['description'] as String,
                            style: GoogleFonts.manrope(
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF484554),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // Helper: Custom Card
  // ============================================================
  Widget _buildCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E2E1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  // ============================================================
  // Error State
  // ============================================================
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
            onPressed: _loadData,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5235C5),
              foregroundColor: Colors.white,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}