// // lib/screens/checkin_screen.dart
// import 'package:flutter/material.dart';
// import 'package:flutter_animate/flutter_animate.dart';
// import '../services/supabase_service.dart';
// import 'result_screen.dart';

// class CheckinScreen extends StatefulWidget {
//   const CheckinScreen({super.key});

//   @override
//   State<CheckinScreen> createState() => _CheckinScreenState();
// }

// class _CheckinScreenState extends State<CheckinScreen> {
//   final SupabaseService _supabaseService = SupabaseService();
//   final TextEditingController _textController = TextEditingController();

//   // ========== الصفحة الحالية ==========
//   int _currentPage = 0;
//   bool _isLoading = false;

//   // ========== بيانات الصفحة 1 (Daily Reflection) ==========
//   String _freeText = '';
//   bool _isRecording = false;

//   // ========== بيانات الصفحة 2 (AI Usage Overview) ==========
//   int _aiToolsCount = 0;
//   String _usageTime = '';
//   String _usagePattern = 'Mostly Continuous';

//   // ========== بيانات الصفحة 3 (Well-Being Check) ==========
//   int _focusLevel = 3;
//   int _distractionLevel = 3;
//   String _breaksTaken = 'Yes';

//   @override
//   void dispose() {
//     _textController.dispose();
//     super.dispose();
//   }

//   // ========== حساب Score ==========
//   int _calculateCognitiveLoadScore() {
//     int score = 2;

//     // عدد الأدوات
//     if (_aiToolsCount >= 4)
//       score += 2;
//     else if (_aiToolsCount >= 2)
//       score += 1;

//     // نمط الاستخدام
//     if (_usagePattern == 'Mostly Continuous') score += 1;

//     // مستوى التركيز (كلما كان أقل، كلما زاد الإرهاق)
//     if (_focusLevel <= 2)
//       score += 1;
//     else if (_focusLevel == 1)
//       score += 2;

//     // مستوى التشتت (كلما كان أعلى، كلما زاد الإرهاق)
//     if (_distractionLevel >= 4)
//       score += 1;
//     else if (_distractionLevel == 5)
//       score += 2;

//     // الفواصل
//     if (_breaksTaken == 'No') score += 1;

//     // تحليل النص
//     final text = _freeText.toLowerCase();
//     if (text.contains('tired') ||
//         text.contains('exhausted') ||
//         text.contains('headache') ||
//         text.contains('can\'t focus')) {
//       score += 1;
//     }
//     if (text.contains('productive') ||
//         text.contains('focused') ||
//         text.contains('great') ||
//         text.contains('good')) {
//       score -= 1;
//     }

//     return score.clamp(1, 5);
//   }

//   String _generateRecommendation(int score) {
//     if (score <= 2) {
//       return '🌟 You\'re doing great! Keep up your current habits. Try to maintain this balance.';
//     } else if (score == 3) {
//       return '📊 Moderate cognitive load detected. Consider taking a 10-minute break and reducing AI tools to 2 per session.';
//     } else {
//       return '⚠️ High cognitive load detected. Take a 20-minute break, reduce AI tools to 1-2, and practice deep breathing.';
//     }
//   }

// Future<void> _analyzeDay() async {
//   try {
//     final user = _supabaseService.currentUser;
//     if (user == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('⚠️ Please login first'),
//           backgroundColor: Color(0xFFE76F51),
//         ),
//       );
//       return;
//     }

//     final textToAnalyze = _freeText.trim();
//     if (textToAnalyze.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('⚠️ Please write or record your day'),
//           backgroundColor: Color(0xFFE76F51),
//         ),
//       );
//       return;
//     }

//     setState(() => _isLoading = true);

//     try {
//       final score = _calculateCognitiveLoadScore();
//       final recommendation = _generateRecommendation(score);

//       debugPrint('📝 Saving checkin for user: ${user.id}');
//       debugPrint('📊 Score: $score');
//       debugPrint('💡 Recommendation: $recommendation');
//       debugPrint('📌 AI Tools: $_aiToolsCount');
//       debugPrint('📌 Usage Pattern: $_usagePattern');
//       debugPrint('📌 Focus Level: $_focusLevel');
//       debugPrint('📌 Breaks: $_breaksTaken');

//       await _supabaseService.saveCheckin(
//         userId: user.id,
//         freeText: textToAnalyze,
//         voiceTranscript: null,
//         aiToolsCount: _aiToolsCount,
//         usagePattern: _usagePattern == 'Mostly Continuous' ? 'continuous' : 'intermittent',
//         focusDifficulty: _focusLevel,
//         energyLevel: 3,
//         tookBreaks: _breaksTaken == 'Yes',
//         sleepHours: 7,
//         cognitiveLoadScore: score,
//         recommendation: recommendation,
//         confidenceScore: 85,
//       );

//       debugPrint('✅ Checkin saved successfully!');

//       if (mounted) {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(
//             builder: (context) => ResultScreen(
//               cognitiveLoadScore: score,
//               recommendation: recommendation,
//               freeText: textToAnalyze,
//               aiToolsCount: _aiToolsCount,
//               usagePattern: _usagePattern == 'Mostly Continuous' ? 'continuous' : 'intermittent',
//               focusScore: _focusLevel,
//             ),
//           ),
//         );
//       }
//     } catch (e) {
//       debugPrint('❌ Error saving checkin: $e');
//       setState(() => _isLoading = false);
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('❌ Failed to save: ${e.toString()}'),
//           backgroundColor: Color(0xFFE76F51),
//           duration: const Duration(seconds: 4),
//         ),
//       );
//     }
//   } catch (e) {
//     debugPrint('❌ Unexpected error: $e');
//     setState(() => _isLoading = false);
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text('❌ Error: ${e.toString()}'),
//         backgroundColor: Color(0xFFE76F51),
//       ),
//     );
//   }
// }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF8F7FF),
//       appBar: AppBar(
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Color(0xFF5E35B1)),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: const Text(
//           'Daily Check-in',
//           style: TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.w600,
//             color: Color(0xFF1A1A2E),
//           ),
//         ),
//         centerTitle: true,
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         actions: [
//           if (_currentPage > 0)
//             TextButton(
//               onPressed: () {
//                 if (_currentPage == 1) {
//                   // حفظ البيانات والانتقال إلى النتيجة
//                   _analyzeDay();
//                 } else {
//                   setState(() => _currentPage++);
//                 }
//               },
//               child: Text(
//                 _currentPage == 1 ? 'Analyze' : 'Skip',
//                 style: const TextStyle(
//                   color: Color(0xFF5E35B1),
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),
//         ],
//       ),
//       body: _isLoading
//           ? const Center(
//               child: CircularProgressIndicator(color: Color(0xFF5E35B1)),
//             )
//           : _currentPage == 0
//           ? _buildPage1()
//           : _currentPage == 1
//           ? _buildPage2()
//           : _buildPage3(),
//     );
//   }

//   // ========== الصفحة 1: Daily Reflection ==========
//   Widget _buildPage1() {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(24),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // العنوان
//           const Text(
//             'Daily Check-in',
//             style: TextStyle(
//               fontSize: 24,
//               fontWeight: FontWeight.bold,
//               color: Color(0xFF5E35B1),
//             ),
//           ),
//           const SizedBox(height: 8),
//           // النص الوصفي
//           const Text(
//             "Let's Reflect on Your Day",
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.w500,
//               color: Color(0xFF1A1A2E),
//             ),
//           ),
//           const SizedBox(height: 8),
//           const Text(
//             'Share your experience with AI tools today to receive personalized insights and recommendations.',
//             style: TextStyle(
//               fontSize: 14,
//               color: Color(0xFF8A8A9A),
//               height: 1.4,
//             ),
//           ),
//           const SizedBox(height: 24),
//           const Divider(color: Color(0xFFE8E8EE), thickness: 1),
//           const SizedBox(height: 24),

//           // ========== 1. Daily Reflection ==========
//           Row(
//             children: [
//               Container(
//                 width: 28,
//                 height: 28,
//                 decoration: BoxDecoration(
//                   color: const Color(0xFF5E35B1),
//                   shape: BoxShape.circle,
//                 ),
//                 child: const Center(
//                   child: Text(
//                     '1',
//                     style: TextStyle(
//                       fontSize: 12,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 12),
//               const Text(
//                 'Daily Reflection',
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                   color: Color(0xFF1A1A2E),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 8),
//           const Text(
//             'Tell us about your day',
//             style: TextStyle(
//               fontSize: 14,
//               fontWeight: FontWeight.w600,
//               color: Color(0xFF1A1A2E),
//             ),
//           ),
//           const SizedBox(height: 8),
//           const Text(
//             'How was your experience using AI tools today?\nWhat tasks did you use them for?\nDid you feel focused, distracted, or mentally tired?',
//             style: TextStyle(
//               fontSize: 13,
//               color: Color(0xFF6B6B7A),
//               height: 1.5,
//             ),
//           ),
//           const SizedBox(height: 16),
//           // حقل النص
//           Container(
//             height: 150,
//             decoration: BoxDecoration(
//               color: const Color.fromARGB(206, 211, 207, 247),
//               borderRadius: BorderRadius.circular(16),
//               border: Border.all(
//                 color: const Color.fromARGB(255, 222, 220, 255),
//               ),
//             ),
//             child: TextField(
//               controller: _textController,
//               maxLines: null,
//               expands: true,
//               style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A2E)),
//               onChanged: (value) => setState(() => _freeText = value),
//               decoration: InputDecoration(
//                 hintText: 'Tell us about your day',
//                 hintStyle: const TextStyle(
//                   color: Color(0xFFBDBDBD),
//                   fontSize: 14,
//                 ),
//                 border: InputBorder.none,
//                 contentPadding: const EdgeInsets.all(16),
//                 counterText: '${_freeText.length}/1000',
//                 counterStyle: const TextStyle(
//                   fontSize: 12,
//                   color: Color(0xFF8A8A9A),
//                 ),
//               ),
//               maxLength: 1000,
//             ),
//           ),
//           const SizedBox(height: 24),
//           // تسجيل صوتي
//           // ========== تسجيل صوتي ==========
//           Container(
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: const Color(0xFF5E35B1).withValues(alpha: 0.06),
//               borderRadius: BorderRadius.circular(16),
//               border: Border.all(
//                 color: const Color(0xFF5E35B1).withValues(alpha: 0.15),
//               ),
//             ),
//             child: Row(
//               children: [
//                 const Expanded(
//                   flex: 1,
//                   child: Text(
//                     'Record Your voice instead',
//                     style: TextStyle(
//                       fontSize: 13,
//                       fontWeight: FontWeight.w600,
//                       color: Color(0xFF1A1A2E),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   flex: 1,
//                   child: GestureDetector(
//                     onTap: () {
//                       setState(() => _isRecording = !_isRecording);
//                       if (_isRecording) {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(
//                             content: Text('🎙️ Recording started...'),
//                             backgroundColor: Color(0xFF5E35B1),
//                           ),
//                         );
//                       } else {
//                         setState(() {
//                           _freeText =
//                               'I used ChatGPT and felt productive today.';
//                           _textController.text = _freeText;
//                         });
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(
//                             content: Text('✅ Recording saved!'),
//                             backgroundColor: Color(0xFF2D6A4F),
//                           ),
//                         );
//                       }
//                     },
//                     child: Container(
//                       width: double.infinity,
//                       padding: const EdgeInsets.symmetric(
//                         vertical: 10,
//                         horizontal: 12,
//                       ),
//                       decoration: BoxDecoration(
//                         color: _isRecording
//                             ? const Color(0xFFE76F51)
//                             : const Color(0xFF5E35B1),
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Icon(
//                             _isRecording ? Icons.stop : Icons.mic,
//                             color: Colors.white,
//                             size: 18,
//                           ),
//                           const SizedBox(width: 6),
//                           Text(
//                             _isRecording ? 'Stop' : 'Record',
//                             style: const TextStyle(
//                               color: Colors.white,
//                               fontSize: 13,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           if (_isRecording)
//             const Padding(
//               padding: EdgeInsets.only(top: 8),
//               child: Center(
//                 child: Text(
//                   'Recording...',
//                   style: TextStyle(fontSize: 12, color: Color(0xFFE76F51)),
//                 ),
//               ),
//             ),
//           const SizedBox(height: 32),
//           // ========== زر Next ==========
//           SizedBox(
//             width: double.infinity,
//             child: ElevatedButton(
//               onPressed: () {
//                 if (_freeText.trim().isEmpty) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(
//                       content: Text('Please write or record your day'),
//                       backgroundColor: Color(0xFFE76F51),
//                     ),
//                   );
//                   return;
//                 }
//                 setState(() => _currentPage = 1);
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFF5E35B1),
//                 foregroundColor: Colors.white,
//                 padding: const EdgeInsets.symmetric(vertical: 22),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(16),
//                 ),
//                 elevation: 0,
//               ),
//               child: const Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text(
//                     'Next',
//                     style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//                   ),
//                   SizedBox(width: 8),
//                   Icon(Icons.arrow_forward, size: 18),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ===================== الصفحة 2: AI Usage Overview =====================
//   Widget _buildPage2() {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(24),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // العنوان
//           const Text(
//             'Daily Check-in',
//             style: TextStyle(
//               fontSize: 24,
//               fontWeight: FontWeight.bold,
//               color: Color(0xFF5E35B1),
//             ),
//           ),
//           const SizedBox(height: 8),
//           // 2. AI Usage Overview
//           Row(
//             children: [
//               Container(
//                 width: 28,
//                 height: 28,
//                 decoration: BoxDecoration(
//                   color: const Color(0xFF5E35B1),
//                   shape: BoxShape.circle,
//                 ),
//                 child: const Center(
//                   child: Text(
//                     '2',
//                     style: TextStyle(
//                       fontSize: 14,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 12),
//               const Text(
//                 'AI Usage Overview',
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                   color: Color(0xFF1A1A2E),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 4),
//           const Text(
//             'Help us understand your AI usage today',
//             style: TextStyle(fontSize: 14, color: Color(0xFF8A8A9A)),
//           ),
//           const SizedBox(height: 24),
//           const Divider(color: Color(0xFFE8E8EE), thickness: 1),
//           const SizedBox(height: 24),
//           // السؤال 1: عدد الأدوات
//           Container(
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(16),
//               border: Border.all(color: const Color(0xFFDEDCFF)),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   'How many AI tools did you use today?',
//                   style: TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w600,
//                     color: Color(0xFF1A1A2E),
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 12),
//                   decoration: BoxDecoration(
//                     color: const Color(0xFFF8F7FF),
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(color: const Color(0xFFDEDCFF)),
//                   ),
//                   child: DropdownButtonHideUnderline(
//                     child: DropdownButton<int>(
//                       value: _aiToolsCount > 0 ? _aiToolsCount : null,
//                       hint: const Text(
//                         'Select an option',
//                         style: TextStyle(color: Color(0xFF8A8A9A)),
//                       ),
//                       isExpanded: true,
//                       icon: const Icon(
//                         Icons.keyboard_arrow_down,
//                         color: Color(0xFF5E35B1),
//                       ),
//                       dropdownColor: Colors.white,
//                       items: List.generate(11, (index) {
//                         final isSelected = _aiToolsCount == index;
//                         return DropdownMenuItem(
//                           value: index,
//                           child: Container(
//                             width: double.infinity,
//                             padding: const EdgeInsets.symmetric(
//                               vertical: 10,
//                               horizontal: 12,
//                             ),
//                             decoration: BoxDecoration(
//                               color: isSelected
//                                   ? const Color(
//                                       0xFF5E35B1,
//                                     ).withValues(alpha: 0.08)
//                                   : Colors.transparent,
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                             child: Text(
//                               index == 0 ? 'None' : index.toString(),
//                               style: TextStyle(
//                                 color: isSelected
//                                     ? const Color(0xFF5E35B1)
//                                     : const Color(0xFF1A1A2E),
//                                 fontWeight: isSelected
//                                     ? FontWeight.w600
//                                     : FontWeight.normal,
//                               ),
//                             ),
//                           ),
//                         );
//                       }),
//                       onChanged: (value) =>
//                           setState(() => _aiToolsCount = value ?? 0),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 16),
//           // السؤال 2: وقت الاستخدام
//           Container(
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(16),
//               border: Border.all(color: const Color(0xFFDEDCFF)),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   'How long did you use AI tools today?',
//                   style: TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w600,
//                     color: Color(0xFF1A1A2E),
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 12),
//                   decoration: BoxDecoration(
//                     color: const Color(0xFFF8F7FF),
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(color: const Color(0xFFDEDCFF)),
//                   ),
//                   child: DropdownButtonHideUnderline(
//                     child: DropdownButton<String>(
//                       value: _usageTime.isNotEmpty ? _usageTime : null,
//                       hint: const Text(
//                         'Select an option',
//                         style: TextStyle(color: Color(0xFF8A8A9A)),
//                       ),
//                       isExpanded: true,
//                       icon: const Icon(
//                         Icons.keyboard_arrow_down,
//                         color: Color(0xFF5E35B1),
//                       ),
//                       dropdownColor: Colors.white,
//                       items:
//                           [
//                             'Less than 1 hour',
//                             '1-2 hours',
//                             '2-4 hours',
//                             '4-6 hours',
//                             '6-8 hours',
//                             'More than 8 hours',
//                           ].map((e) {
//                             final isSelected = _usageTime == e;
//                             return DropdownMenuItem(
//                               value: e,
//                               child: Container(
//                                 width: double.infinity,
//                                 padding: const EdgeInsets.symmetric(
//                                   vertical: 10,
//                                   horizontal: 12,
//                                 ),
//                                 decoration: BoxDecoration(
//                                   color: isSelected
//                                       ? const Color(
//                                           0xFF5E35B1,
//                                         ).withValues(alpha: 0.08)
//                                       : Colors.transparent,
//                                   borderRadius: BorderRadius.circular(8),
//                                 ),
//                                 child: Text(
//                                   e,
//                                   style: TextStyle(
//                                     color: isSelected
//                                         ? const Color(0xFF5E35B1)
//                                         : const Color(0xFF1A1A2E),
//                                     fontWeight: isSelected
//                                         ? FontWeight.w600
//                                         : FontWeight.normal,
//                                   ),
//                                 ),
//                               ),
//                             );
//                           }).toList(),
//                       onChanged: (value) =>
//                           setState(() => _usageTime = value ?? ''),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 16),
//           // السؤال 3: نمط الاستخدام
//           Container(
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(16),
//               border: Border.all(color: const Color(0xFFDEDCFF)),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   'What best describes your usage pattern?',
//                   style: TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w600,
//                     color: Color(0xFF1A1A2E),
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 _buildRadioOption('Mostly Continuous'),
//                 _buildRadioOption('Mostly Interrupted'),
//                 _buildRadioOption('Balanced'),
//               ],
//             ),
//           ),
//           const SizedBox(height: 32),
//           // أزرار التنقل
//           Row(
//             children: [
//               Expanded(
//                 child: OutlinedButton(
//                   onPressed: () => setState(() => _currentPage = 0),
//                   style: OutlinedButton.styleFrom(
//                     foregroundColor: const Color(0xFF5E35B1),
//                     side: const BorderSide(color: Color(0xFF5E35B1)),
//                     padding: const EdgeInsets.symmetric(vertical: 14),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(16),
//                     ),
//                   ),
//                   child: const Text(
//                     'Back',
//                     style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: ElevatedButton(
//                   onPressed: () {
//                     if (_aiToolsCount == 0 ||
//                         _usageTime.isEmpty ||
//                         _usagePattern.isEmpty) {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(
//                           content: Text('Please fill all fields'),
//                           backgroundColor: Color(0xFFE76F51),
//                         ),
//                       );
//                       return;
//                     }
//                     setState(() => _currentPage = 2);
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFF5E35B1),
//                     foregroundColor: Colors.white,
//                     padding: const EdgeInsets.symmetric(vertical: 14),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(16),
//                     ),
//                   ),
//                   child: const Text(
//                     'Next',
//                     style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 8),
//           Center(
//             child: Text(
//               'Step 2 of 3',
//               style: TextStyle(fontSize: 12, color: const Color(0xFF8A8A9A)),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildRadioOption(String label) {
//     return GestureDetector(
//       onTap: () => setState(() => _usagePattern = label),
//       child: Container(
//         margin: const EdgeInsets.only(bottom: 8),
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//         decoration: BoxDecoration(
//           color: _usagePattern == label
//               ? const Color(0xFF5E35B1).withValues(alpha: 0.08)
//               : Colors.white,
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(
//             color: _usagePattern == label
//                 ? const Color(0xFF5E35B1)
//                 : const Color(0xFFDEDCFF),
//             width: _usagePattern == label ? 2 : 1,
//           ),
//         ),
//         child: Row(
//           children: [
//             Container(
//               width: 20,
//               height: 20,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: _usagePattern == label
//                     ? const Color(0xFF5E35B1)
//                     : Colors.transparent,
//                 border: Border.all(
//                   color: _usagePattern == label
//                       ? const Color(0xFF5E35B1)
//                       : const Color(0xFFB0B0BA),
//                   width: 2,
//                 ),
//               ),
//               child: _usagePattern == label
//                   ? const Icon(Icons.check, color: Colors.white, size: 12)
//                   : null,
//             ),
//             const SizedBox(width: 12),
//             Text(
//               label,
//               style: TextStyle(
//                 fontSize: 14,
//                 fontWeight: _usagePattern == label
//                     ? FontWeight.w600
//                     : FontWeight.normal,
//                 color: _usagePattern == label
//                     ? const Color(0xFF5E35B1)
//                     : const Color(0xFF1A1A2E),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ===================== الصفحة 3: Well-Being Check =====================
//   Widget _buildPage3() {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(24),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // العنوان
//           const Text(
//             'Daily Check-in',
//             style: TextStyle(
//               fontSize: 24,
//               fontWeight: FontWeight.bold,
//               color: Color(0xFF5E35B1),
//             ),
//           ),
//           const SizedBox(height: 8),
//           // 3. Well-Being Check
//           Row(
//             children: [
//               Container(
//                 width: 28,
//                 height: 28,
//                 decoration: BoxDecoration(
//                   color: const Color(0xFF5E35B1),
//                   shape: BoxShape.circle,
//                 ),
//                 child: const Center(
//                   child: Text(
//                     '3',
//                     style: TextStyle(
//                       fontSize: 14,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 12),
//               const Text(
//                 'Well-Being Check',
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                   color: Color(0xFF1A1A2E),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 4),
//           const Text(
//             'Tell us how you felt during AI sessions',
//             style: TextStyle(fontSize: 14, color: Color(0xFF8A8A9A)),
//           ),
//           const SizedBox(height: 24),
//           const Divider(color: Color(0xFFE8E8EE), thickness: 1),
//           const SizedBox(height: 24),
//           // السؤال 1: مستوى التركيز
//           Container(
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(16),
//               border: Border.all(color: const Color(0xFFDEDCFF)),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   'How focused did you feel today?',
//                   style: TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w600,
//                     color: Color(0xFF1A1A2E),
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 const Text(
//                   'Rate from 1 to 5',
//                   style: TextStyle(fontSize: 12, color: Color(0xFF8A8A9A)),
//                 ),
//                 const SizedBox(height: 12),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: List.generate(5, (index) {
//                     final value = index + 1;
//                     final isSelected = _focusLevel == value;
//                     return GestureDetector(
//                       onTap: () => setState(() => _focusLevel = value),
//                       child: Container(
//                         width: 50,
//                         height: 50,
//                         decoration: BoxDecoration(
//                           shape: BoxShape.circle,
//                           color: isSelected
//                               ? const Color(0xFF5E35B1)
//                               : Colors.white,
//                           border: Border.all(
//                             color: isSelected
//                                 ? const Color(0xFF5E35B1)
//                                 : const Color(0xFFDEDCFF),
//                             width: isSelected ? 2 : 1,
//                           ),
//                         ),
//                         child: Center(
//                           child: Text(
//                             value.toString(),
//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: isSelected
//                                   ? FontWeight.bold
//                                   : FontWeight.normal,
//                               color: isSelected
//                                   ? Colors.white
//                                   : const Color(0xFF1A1A2E),
//                             ),
//                           ),
//                         ),
//                       ),
//                     );
//                   }),
//                 ),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: const [
//                     Text(
//                       'Very Low',
//                       style: TextStyle(fontSize: 12, color: Color(0xFF8A8A9A)),
//                     ),
//                     Text(
//                       'Very High',
//                       style: TextStyle(fontSize: 12, color: Color(0xFF8A8A9A)),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 16),
//           // السؤال 2: مستوى التشتت
//           Container(
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(16),
//               border: Border.all(color: const Color(0xFFDEDCFF)),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   'How distracted did you feel today?',
//                   style: TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w600,
//                     color: Color(0xFF1A1A2E),
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 const Text(
//                   'Rate from 1 to 5',
//                   style: TextStyle(fontSize: 12, color: Color(0xFF8A8A9A)),
//                 ),
//                 const SizedBox(height: 12),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: List.generate(5, (index) {
//                     final value = index + 1;
//                     final isSelected = _distractionLevel == value;
//                     return GestureDetector(
//                       onTap: () => setState(() => _distractionLevel = value),
//                       child: Container(
//                         width: 50,
//                         height: 50,
//                         decoration: BoxDecoration(
//                           shape: BoxShape.circle,
//                           color: isSelected
//                               ? const Color(0xFF5E35B1)
//                               : Colors.white,
//                           border: Border.all(
//                             color: isSelected
//                                 ? const Color(0xFF5E35B1)
//                                 : const Color(0xFFDEDCFF),
//                             width: isSelected ? 2 : 1,
//                           ),
//                         ),
//                         child: Center(
//                           child: Text(
//                             value.toString(),
//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: isSelected
//                                   ? FontWeight.bold
//                                   : FontWeight.normal,
//                               color: isSelected
//                                   ? Colors.white
//                                   : const Color(0xFF1A1A2E),
//                             ),
//                           ),
//                         ),
//                       ),
//                     );
//                   }),
//                 ),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: const [
//                     Text(
//                       'Not at All',
//                       style: TextStyle(fontSize: 12, color: Color(0xFF8A8A9A)),
//                     ),
//                     Text(
//                       'Very Distracted',
//                       style: TextStyle(fontSize: 12, color: Color(0xFF8A8A9A)),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 16),
//           // السؤال 3: الفواصل
//           Container(
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(16),
//               border: Border.all(color: const Color(0xFFDEDCFF)),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   'Did you take regular breaks during your AI sessions?',
//                   style: TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w600,
//                     color: Color(0xFF1A1A2E),
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 _buildBreakOption('Yes'),
//                 _buildBreakOption('Sometimes'),
//                 _buildBreakOption('No'),
//               ],
//             ),
//           ),
//           const SizedBox(height: 32),
          
// // ========== Analyze Today's Load Card ==========
// GestureDetector(
//   onTap: _analyzeDay,
//   child: Container(
//     width: double.infinity,
//     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//     decoration: BoxDecoration(
//       color: const Color(0xFF5E35B1),
//       borderRadius: BorderRadius.circular(16),
//       border: Border.all(
//         color: const Color(0xFF5E35B1).withValues(alpha: 0.3),
//       ),
//     ),
//     child: Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         // الصورة على اليسار
//         Image.asset(
//           'assets/images/Vector.png',
//           width: 56,
//           height: 56,
//           fit: BoxFit.contain,
//           errorBuilder: (context, error, stackTrace) {
//             return Container(
//               width: 56,
//               height: 56,
//               decoration: BoxDecoration(
//                 color: Colors.white.withValues(alpha: 0.2),
//                 borderRadius: BorderRadius.circular(14),
//               ),
//               child: const Icon(
//                 Icons.analytics,
//                 color: Colors.white,
//                 size: 32,
//               ),
//             );
//           },
//         ),
//         const SizedBox(width: 16),
//         // النصوص في المنتصف
//         Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             const Text(
//               'Analyze Today\'s Load',
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w600,
//                 color: Colors.white,
//               ),
//             ),
//             const SizedBox(height: 2),
//             Text(
//               'Generate your daily report',
//               style: TextStyle(
//                 fontSize: 13,
//                 color: Colors.white.withValues(alpha: 0.8),
//               ),
//             ),
//           ],
//         ),
//       ],
//     ),
//   ),
// ),
//         ],
//       ),
//     );
//   }

//   Widget _buildBreakOption(String label) {
//     return GestureDetector(
//       onTap: () => setState(() => _breaksTaken = label),
//       child: Container(
//         margin: const EdgeInsets.only(bottom: 8),
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//         decoration: BoxDecoration(
//           color: _breaksTaken == label
//               ? const Color(0xFF5E35B1).withValues(alpha: 0.08)
//               : Colors.white,
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(
//             color: _breaksTaken == label
//                 ? const Color(0xFF5E35B1)
//                 : const Color(0xFFDEDCFF),
//             width: _breaksTaken == label ? 2 : 1,
//           ),
//         ),
//         child: Row(
//           children: [
//             Container(
//               width: 20,
//               height: 20,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: _breaksTaken == label
//                     ? const Color(0xFF5E35B1)
//                     : Colors.transparent,
//                 border: Border.all(
//                   color: _breaksTaken == label
//                       ? const Color(0xFF5E35B1)
//                       : const Color(0xFFB0B0BA),
//                   width: 2,
//                 ),
//               ),
//               child: _breaksTaken == label
//                   ? const Icon(Icons.check, color: Colors.white, size: 12)
//                   : null,
//             ),
//             const SizedBox(width: 12),
//             Text(
//               label,
//               style: TextStyle(
//                 fontSize: 14,
//                 fontWeight: _breaksTaken == label
//                     ? FontWeight.w600
//                     : FontWeight.normal,
//                 color: _breaksTaken == label
//                     ? const Color(0xFF5E35B1)
//                     : const Color(0xFF1A1A2E),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// ============================================================
// 📄 lib/screens/checkin_screen.dart
// 📌 شاشة Check-in - مع دمج الذكاء الاصطناعي
// ============================================================

import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../services/ai_service.dart';  // ✅ أضف هذا
import 'result_screen.dart';

class CheckinScreen extends StatefulWidget {
  const CheckinScreen({super.key});

  @override
  State<CheckinScreen> createState() => _CheckinScreenState();
}

class _CheckinScreenState extends State<CheckinScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  final AIService _aiService = AIService();  // ✅ أضف هذا
  final TextEditingController _textController = TextEditingController();

  // ========== الصفحة الحالية ==========
  int _currentPage = 0;
  bool _isLoading = false;

  // ========== بيانات الصفحة 1 (Daily Reflection) ==========
  String _freeText = '';
  bool _isRecording = false;

  // ========== بيانات الصفحة 2 (AI Usage Overview) ==========
  int _aiToolsCount = 0;
  String _usageTime = '';
  String _usagePattern = 'Mostly Continuous';

  // ========== بيانات الصفحة 3 (Well-Being Check) ==========
  int _focusLevel = 3;
  int _distractionLevel = 3;
  String _breaksTaken = 'Yes';

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  // ============================================================
  // ✅ دالة التحليل الرئيسية (باستخدام AI)
  // ============================================================
  Future<void> _analyzeDay() async {
    try {
      final user = _supabaseService.currentUser;
      if (user == null) {
        _showMessage('⚠️ Please login first', isError: true);
        return;
      }

      final textToAnalyze = _freeText.trim();
      if (textToAnalyze.isEmpty) {
        _showMessage('⚠️ Please write or record your day', isError: true);
        return;
      }

      setState(() => _isLoading = true);

      // ============================================================
      // 1. استخدام AI Service للتحليل
      // ============================================================
      Map<String, dynamic> aiResult;
      
      try {
        aiResult = await _aiService.analyzeText(textToAnalyze);
        debugPrint('✅ AI Analysis Result: $aiResult');
      } catch (e) {
        debugPrint('❌ AI Service error: $e');
        // في حالة فشل AI، استخدم الحساب المحلي
        final localScore = _calculateCognitiveLoadScore();
        aiResult = {
          'score': localScore,
          'category': _getCategory(localScore),
          'confidence': 70,
          'recommendation': _generateRecommendation(localScore),
          'mode': 'local_fallback',
        };
      }

      // ============================================================
      // 2. استخراج النتائج
      // ============================================================
      final int score = aiResult['score'] ?? _calculateCognitiveLoadScore();
      final String recommendation = aiResult['recommendation'] ?? _generateRecommendation(score);
      final int confidence = aiResult['confidence'] ?? 85;
      final String mode = aiResult['mode'] ?? 'local';

      debugPrint('📊 Final Score: $score');
      debugPrint('💡 Recommendation: $recommendation');
      debugPrint('🎯 Confidence: $confidence%');
      debugPrint('📌 Mode: $mode');

      // ============================================================
      // 3. حفظ في قاعدة البيانات
      // ============================================================
      await _supabaseService.saveCheckin(
        userId: user.id,
        freeText: textToAnalyze,
        voiceTranscript: null,
        aiToolsCount: _aiToolsCount,
        usagePattern: _usagePattern == 'Mostly Continuous' ? 'continuous' : 'intermittent',
        focusDifficulty: _focusLevel,
        energyLevel: 3,
        tookBreaks: _breaksTaken == 'Yes',
        sleepHours: 7,
        cognitiveLoadScore: score,
        recommendation: recommendation,
        confidenceScore: confidence,
      );

      debugPrint('✅ Checkin saved successfully!');

      // ============================================================
      // 4. الانتقال إلى صفحة النتيجة
      // ============================================================
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ResultScreen(
              cognitiveLoadScore: score,
              recommendation: recommendation,
              freeText: textToAnalyze,
              aiToolsCount: _aiToolsCount,
              usagePattern: _usagePattern == 'Mostly Continuous' ? 'continuous' : 'intermittent',
              focusScore: _focusLevel,
              confidenceScore: confidence,
              analysisMode: mode,  // ✅ أضف هذا إلى ResultScreen
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Error: $e');
      setState(() => _isLoading = false);
      _showMessage('❌ Error: ${e.toString()}', isError: true);
    }
  }

  // ============================================================
  // دوال مساعدة
  // ============================================================
  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? const Color(0xFFE76F51) : const Color(0xFF2D6A4F),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  String _getCategory(int score) {
    if (score <= 2) return 'Low';
    if (score == 3) return 'Moderate';
    return 'High';
  }

  // ============================================================
  // حساب Score (بدون AI)
  // ============================================================
int _calculateCognitiveLoadScore() {
  double score = 2.0;

  // عدد الأدوات
  if (_aiToolsCount >= 4) {
    score += 2.0;
  } else if (_aiToolsCount >= 2) {
    score += 1.0;
  }

  // نمط الاستخدام
  if (_usagePattern == 'Mostly Continuous') {
    score += 1.0;
  }

  // مستوى التركيز
  if (_focusLevel <= 2) {
    score += 1.0;
  } else if (_focusLevel == 1) {
    score += 2.0;
  }

  // مستوى التشتت
  if (_distractionLevel >= 4) {
    score += 1.0;
  } else if (_distractionLevel == 5) {
    score += 2.0;
  }

  // الفواصل
  if (_breaksTaken == 'No') {
    score += 1.0;
  }

  // تحليل النص
  final text = _freeText.toLowerCase();
  if (text.contains('tired') || text.contains('exhausted') || 
      text.contains('headache') || text.contains('can\'t focus')) {
    score += 1.0;
  }
  if (text.contains('productive') || text.contains('focused') || 
      text.contains('great') || text.contains('good')) {
    score -= 1.0;
  }

  return score.round().clamp(1, 5);
}
  String _generateRecommendation(int score) {
    if (score <= 2) {
      return '🌟 You\'re doing great! Keep up your current habits. Try to maintain this balance.';
    } else if (score == 3) {
      return '📊 Moderate cognitive load detected. Consider taking a 10-minute break and reducing AI tools to 2 per session.';
    } else {
      return '⚠️ High cognitive load detected. Take a 20-minute break, reduce AI tools to 1-2, and practice deep breathing.';
    }
  }

  // ============================================================
  // البناء الرئيسي
  // ============================================================
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
          'Daily Check-in',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A2E),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (_currentPage > 0)
            TextButton(
              onPressed: () {
                if (_currentPage == 1) {
                  _analyzeDay();
                } else {
                  setState(() => _currentPage++);
                }
              },
              child: Text(
                _currentPage == 1 ? 'Analyze' : 'Skip',
                style: const TextStyle(
                  color: Color(0xFF5E35B1),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xFF5E35B1)),
                  SizedBox(height: 16),
                  Text(
                    'Analyzing with AI...',
                    style: TextStyle(
                      color: Color(0xFF8A8A9A),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )
          : _currentPage == 0
              ? _buildPage1()
              : _currentPage == 1
                  ? _buildPage2()
                  : _buildPage3(),
    );
  }

  // ========== الصفحة 1: Daily Reflection ==========
  Widget _buildPage1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // العنوان
          const Text(
            'Daily Check-in',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF5E35B1),
            ),
          ),
          const SizedBox(height: 8),
          // النص الوصفي
          const Text(
            "Let's Reflect on Your Day",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Share your experience with AI tools today to receive personalized insights and recommendations.',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF8A8A9A),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          const Divider(color: Color(0xFFE8E8EE), thickness: 1),
          const SizedBox(height: 24),

          // ========== 1. Daily Reflection ==========
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: const Color(0xFF5E35B1),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text(
                    '1',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Daily Reflection',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A2E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Tell us about your day',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'How was your experience using AI tools today?\nWhat tasks did you use them for?\nDid you feel focused, distracted, or mentally tired?',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF6B6B7A),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          // حقل النص
          Container(
            height: 150,
            decoration: BoxDecoration(
              color: const Color.fromARGB(206, 211, 207, 247),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color.fromARGB(255, 222, 220, 255),
              ),
            ),
            child: TextField(
              controller: _textController,
              maxLines: null,
              expands: true,
              style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A2E)),
              onChanged: (value) => setState(() => _freeText = value),
              decoration: InputDecoration(
                hintText: 'Tell us about your day',
                hintStyle: const TextStyle(
                  color: Color(0xFFBDBDBD),
                  fontSize: 14,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16),
                counterText: '${_freeText.length}/1000',
                counterStyle: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF8A8A9A),
                ),
              ),
              maxLength: 1000,
            ),
          ),
          const SizedBox(height: 24),
          // تسجيل صوتي
          // ========== تسجيل صوتي ==========
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF5E35B1).withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF5E35B1).withValues(alpha: 0.15),
              ),
            ),
            child: Row(
              children: [
                const Expanded(
                  flex: 1,
                  child: Text(
                    'Record Your voice instead',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 1,
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _isRecording = !_isRecording);
                      if (_isRecording) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('🎙️ Recording started...'),
                            backgroundColor: Color(0xFF5E35B1),
                          ),
                        );
                      } else {
                        setState(() {
                          _freeText =
                              'I used ChatGPT and felt productive today.';
                          _textController.text = _freeText;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('✅ Recording saved!'),
                            backgroundColor: Color(0xFF2D6A4F),
                          ),
                        );
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 12,
                      ),
                      decoration: BoxDecoration(
                        color: _isRecording
                            ? const Color(0xFFE76F51)
                            : const Color(0xFF5E35B1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _isRecording ? Icons.stop : Icons.mic,
                            color: Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _isRecording ? 'Stop' : 'Record',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_isRecording)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Center(
                child: Text(
                  'Recording...',
                  style: TextStyle(fontSize: 12, color: Color(0xFFE76F51)),
                ),
              ),
            ),
          const SizedBox(height: 32),
          // ========== زر Next ==========
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (_freeText.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please write or record your day'),
                      backgroundColor: Color(0xFFE76F51),
                    ),
                  );
                  return;
                }
                setState(() => _currentPage = 1);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5E35B1),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 22),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Next',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward, size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===================== الصفحة 2: AI Usage Overview =====================
  Widget _buildPage2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // العنوان
          const Text(
            'Daily Check-in',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF5E35B1),
            ),
          ),
          const SizedBox(height: 8),
          // 2. AI Usage Overview
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: const Color(0xFF5E35B1),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text(
                    '2',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'AI Usage Overview',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A2E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Help us understand your AI usage today',
            style: TextStyle(fontSize: 14, color: Color(0xFF8A8A9A)),
          ),
          const SizedBox(height: 24),
          const Divider(color: Color(0xFFE8E8EE), thickness: 1),
          const SizedBox(height: 24),
          // السؤال 1: عدد الأدوات
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFDEDCFF)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'How many AI tools did you use today?',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F7FF),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFDEDCFF)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: _aiToolsCount > 0 ? _aiToolsCount : null,
                      hint: const Text(
                        'Select an option',
                        style: TextStyle(color: Color(0xFF8A8A9A)),
                      ),
                      isExpanded: true,
                      icon: const Icon(
                        Icons.keyboard_arrow_down,
                        color: Color(0xFF5E35B1),
                      ),
                      dropdownColor: Colors.white,
                      items: List.generate(11, (index) {
                        final isSelected = _aiToolsCount == index;
                        return DropdownMenuItem(
                          value: index,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 12,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(
                                      0xFF5E35B1,
                                    ).withValues(alpha: 0.08)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              index == 0 ? 'None' : index.toString(),
                              style: TextStyle(
                                color: isSelected
                                    ? const Color(0xFF5E35B1)
                                    : const Color(0xFF1A1A2E),
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        );
                      }),
                      onChanged: (value) =>
                          setState(() => _aiToolsCount = value ?? 0),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // السؤال 2: وقت الاستخدام
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFDEDCFF)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'How long did you use AI tools today?',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F7FF),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFDEDCFF)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _usageTime.isNotEmpty ? _usageTime : null,
                      hint: const Text(
                        'Select an option',
                        style: TextStyle(color: Color(0xFF8A8A9A)),
                      ),
                      isExpanded: true,
                      icon: const Icon(
                        Icons.keyboard_arrow_down,
                        color: Color(0xFF5E35B1),
                      ),
                      dropdownColor: Colors.white,
                      items:
                          [
                            'Less than 1 hour',
                            '1-2 hours',
                            '2-4 hours',
                            '4-6 hours',
                            '6-8 hours',
                            'More than 8 hours',
                          ].map((e) {
                            final isSelected = _usageTime == e;
                            return DropdownMenuItem(
                              value: e,
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                  horizontal: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(
                                          0xFF5E35B1,
                                        ).withValues(alpha: 0.08)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  e,
                                  style: TextStyle(
                                    color: isSelected
                                        ? const Color(0xFF5E35B1)
                                        : const Color(0xFF1A1A2E),
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                      onChanged: (value) =>
                          setState(() => _usageTime = value ?? ''),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // السؤال 3: نمط الاستخدام
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFDEDCFF)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'What best describes your usage pattern?',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 8),
                _buildRadioOption('Mostly Continuous'),
                _buildRadioOption('Mostly Interrupted'),
                _buildRadioOption('Balanced'),
              ],
            ),
          ),
          const SizedBox(height: 32),
          // أزرار التنقل
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() => _currentPage = 0),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF5E35B1),
                    side: const BorderSide(color: Color(0xFF5E35B1)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Back',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    if (_aiToolsCount == 0 ||
                        _usageTime.isEmpty ||
                        _usagePattern.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please fill all fields'),
                          backgroundColor: Color(0xFFE76F51),
                        ),
                      );
                      return;
                    }
                    setState(() => _currentPage = 2);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5E35B1),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Next',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'Step 2 of 3',
              style: TextStyle(fontSize: 12, color: const Color(0xFF8A8A9A)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRadioOption(String label) {
    return GestureDetector(
      onTap: () => setState(() => _usagePattern = label),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: _usagePattern == label
              ? const Color(0xFF5E35B1).withValues(alpha: 0.08)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _usagePattern == label
                ? const Color(0xFF5E35B1)
                : const Color(0xFFDEDCFF),
            width: _usagePattern == label ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _usagePattern == label
                    ? const Color(0xFF5E35B1)
                    : Colors.transparent,
                border: Border.all(
                  color: _usagePattern == label
                      ? const Color(0xFF5E35B1)
                      : const Color(0xFFB0B0BA),
                  width: 2,
                ),
              ),
              child: _usagePattern == label
                  ? const Icon(Icons.check, color: Colors.white, size: 12)
                  : null,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: _usagePattern == label
                    ? FontWeight.w600
                    : FontWeight.normal,
                color: _usagePattern == label
                    ? const Color(0xFF5E35B1)
                    : const Color(0xFF1A1A2E),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===================== الصفحة 3: Well-Being Check =====================
  Widget _buildPage3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // العنوان
          const Text(
            'Daily Check-in',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF5E35B1),
            ),
          ),
          const SizedBox(height: 8),
          // 3. Well-Being Check
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: const Color(0xFF5E35B1),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text(
                    '3',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Well-Being Check',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A2E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Tell us how you felt during AI sessions',
            style: TextStyle(fontSize: 14, color: Color(0xFF8A8A9A)),
          ),
          const SizedBox(height: 24),
          const Divider(color: Color(0xFFE8E8EE), thickness: 1),
          const SizedBox(height: 24),
          // السؤال 1: مستوى التركيز
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFDEDCFF)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'How focused did you feel today?',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Rate from 1 to 5',
                  style: TextStyle(fontSize: 12, color: Color(0xFF8A8A9A)),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(5, (index) {
                    final value = index + 1;
                    final isSelected = _focusLevel == value;
                    return GestureDetector(
                      onTap: () => setState(() => _focusLevel = value),
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected
                              ? const Color(0xFF5E35B1)
                              : Colors.white,
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF5E35B1)
                                : const Color(0xFFDEDCFF),
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            value.toString(),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFF1A1A2E),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      'Very Low',
                      style: TextStyle(fontSize: 12, color: Color(0xFF8A8A9A)),
                    ),
                    Text(
                      'Very High',
                      style: TextStyle(fontSize: 12, color: Color(0xFF8A8A9A)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // السؤال 2: مستوى التشتت
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFDEDCFF)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'How distracted did you feel today?',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Rate from 1 to 5',
                  style: TextStyle(fontSize: 12, color: Color(0xFF8A8A9A)),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(5, (index) {
                    final value = index + 1;
                    final isSelected = _distractionLevel == value;
                    return GestureDetector(
                      onTap: () => setState(() => _distractionLevel = value),
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected
                              ? const Color(0xFF5E35B1)
                              : Colors.white,
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF5E35B1)
                                : const Color(0xFFDEDCFF),
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            value.toString(),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFF1A1A2E),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      'Not at All',
                      style: TextStyle(fontSize: 12, color: Color(0xFF8A8A9A)),
                    ),
                    Text(
                      'Very Distracted',
                      style: TextStyle(fontSize: 12, color: Color(0xFF8A8A9A)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // السؤال 3: الفواصل
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFDEDCFF)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Did you take regular breaks during your AI sessions?',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 8),
                _buildBreakOption('Yes'),
                _buildBreakOption('Sometimes'),
                _buildBreakOption('No'),
              ],
            ),
          ),
          const SizedBox(height: 32),
          
// ========== Analyze Today's Load Card ==========
GestureDetector(
  onTap: _analyzeDay,
  child: Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
      color: const Color(0xFF5E35B1),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: const Color(0xFF5E35B1).withValues(alpha: 0.3),
      ),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // الصورة على اليسار
        Image.asset(
          'assets/images/Vector.png',
          width: 56,
          height: 56,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.analytics,
                color: Colors.white,
                size: 32,
              ),
            );
          },
        ),
        const SizedBox(width: 16),
        // النصوص في المنتصف
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Analyze Today\'s Load',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Generate your daily report',
              style: TextStyle(
                fontSize: 13,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ],
    ),
  ),
),
        ],
      ),
    );
  }

  Widget _buildBreakOption(String label) {
    return GestureDetector(
      onTap: () => setState(() => _breaksTaken = label),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: _breaksTaken == label
              ? const Color(0xFF5E35B1).withValues(alpha: 0.08)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _breaksTaken == label
                ? const Color(0xFF5E35B1)
                : const Color(0xFFDEDCFF),
            width: _breaksTaken == label ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _breaksTaken == label
                    ? const Color(0xFF5E35B1)
                    : Colors.transparent,
                border: Border.all(
                  color: _breaksTaken == label
                      ? const Color(0xFF5E35B1)
                      : const Color(0xFFB0B0BA),
                  width: 2,
                ),
              ),
              child: _breaksTaken == label
                  ? const Icon(Icons.check, color: Colors.white, size: 12)
                  : null,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: _breaksTaken == label
                    ? FontWeight.w600
                    : FontWeight.normal,
                color: _breaksTaken == label
                    ? const Color(0xFF5E35B1)
                    : const Color(0xFF1A1A2E),
              ),
            ),
          ],
        ),
      ),
    );
  }

}