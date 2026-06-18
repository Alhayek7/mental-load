// ============================================================
// 📄 lib/screens/notifications_screen.dart
// 📌 صفحة الإشعارات - Notifications Screen
// ============================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/supabase_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;
  bool _isUpdating = false;

  // بيانات تجريبية (سيتم استبدالها ببيانات حقيقية من Supabase)
  final List<Map<String, dynamic>> _sampleNotifications = [
    {
      'id': '1',
      'title': '🌟 High Cognitive Load Detected!',
      'body': 'We noticed you\'ve been using AI tools continuously for 4 hours. Take a 15-minute break to recharge.',
      'type': 'alert',
      'is_read': false,
      'created_at': '2 minutes ago',
      'icon': Icons.warning_amber_rounded,
      'color': Color(0xFFE76F51),
    },
    {
      'id': '2',
      'title': '📊 Weekly Report Ready',
      'body': 'Your weekly cognitive load summary is now available. Check your patterns and progress.',
      'type': 'tip',
      'is_read': false,
      'created_at': '1 hour ago',
      'icon': Icons.analytics_outlined,
      'color': Color(0xFF5235C5),
    },
    {
      'id': '3',
      'title': '💡 Tip: Reduce AI Tools',
      'body': 'Using fewer AI tools simultaneously can reduce cognitive load. Try sticking to 2 tools per session.',
      'type': 'tip',
      'is_read': true,
      'created_at': '3 hours ago',
      'icon': Icons.lightbulb_outline,
      'color': Color(0xFF2D6A4F),
    },
    {
      'id': '4',
      'title': '🎯 Daily Check-in Reminder',
      'body': 'Don\'t forget to complete your daily check-in. It only takes 2 minutes!',
      'type': 'reminder',
      'is_read': true,
      'created_at': 'Yesterday',
      'icon': Icons.checklist_outlined,
      'color': Color(0xFF1A5F7A),
    },
    {
      'id': '5',
      'title': '🏆 Achievement Unlocked!',
      'body': 'You\'ve completed 10 check-ins! Keep up the great work and stay consistent.',
      'type': 'achievement',
      'is_read': true,
      'created_at': '2 days ago',
      'icon': Icons.emoji_events_outlined,
      'color': Color(0xFFF4A261),
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);

    try {
      final user = _supabaseService.currentUser;
      if (user != null) {
        // جلب الإشعارات من قاعدة البيانات
        final response = await _supabaseService.client
            .from('notifications')
            .select()
            .eq('user_id', user.id)
            .order('created_at', ascending: false);

        if (response.isNotEmpty) {
          setState(() {
            _notifications = response.map((item) {
              return {
                'id': item['id'],
                'title': item['title'],
                'body': item['body'],
                'type': item['type'],
                'is_read': item['is_read'] ?? false,
                'created_at': _formatTime(DateTime.parse(item['created_at'])),
                'icon': _getIconForType(item['type']),
                'color': _getColorForType(item['type']),
              };
            }).toList();
            _isLoading = false;
          });
        } else {
          // استخدام البيانات التجريبية
          setState(() {
            _notifications = _sampleNotifications;
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _notifications = _sampleNotifications;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Error loading notifications: $e');
      setState(() {
        _notifications = _sampleNotifications;
        _isLoading = false;
      });
    }
  }

  String _formatTime(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays > 7) {
      return '${date.day}/${date.month}/${date.year}';
    } else if (diff.inDays > 0) {
      return '${diff.inDays}d ago';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}h ago';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'alert':
        return Icons.warning_amber_rounded;
      case 'tip':
        return Icons.lightbulb_outline;
      case 'reminder':
        return Icons.checklist_outlined;
      case 'achievement':
        return Icons.emoji_events_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  Color _getColorForType(String type) {
    switch (type) {
      case 'alert':
        return const Color(0xFFE76F51);
      case 'tip':
        return const Color(0xFF2D6A4F);
      case 'reminder':
        return const Color(0xFF1A5F7A);
      case 'achievement':
        return const Color(0xFFF4A261);
      default:
        return const Color(0xFF5235C5);
    }
  }

  Future<void> _markAsRead(String id) async {
    setState(() {
      _notifications = _notifications.map((item) {
        if (item['id'] == id) {
          return {...item, 'is_read': true};
        }
        return item;
      }).toList();
    });

    try {
      final user = _supabaseService.currentUser;
      if (user != null) {
        await _supabaseService.client
            .from('notifications')
            .update({'is_read': true})
            .eq('id', int.parse(id))
            .eq('user_id', user.id);
      }
    } catch (e) {
      debugPrint('❌ Error marking notification as read: $e');
    }
  }

  Future<void> _markAllAsRead() async {
    setState(() {
      _isUpdating = true;
      _notifications = _notifications.map((item) {
        return {...item, 'is_read': true};
      }).toList();
    });

    try {
      final user = _supabaseService.currentUser;
      if (user != null) {
        await _supabaseService.client
            .from('notifications')
            .update({'is_read': true})
            .eq('user_id', user.id);
      }
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      debugPrint('❌ Error marking all as read: $e');
    }

    setState(() => _isUpdating = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All notifications marked as read'),
        backgroundColor: Color(0xFF2D6A4F),
      ),
    );
  }

  int get _unreadCount {
    return _notifications.where((item) => item['is_read'] == false).length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FF),
      appBar: _buildAppBar(),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF5235C5)),
            )
          : Column(
              children: [
                // ============================================================
                // Actions Bar
                // ============================================================
                _buildActionsBar(),

                const SizedBox(height: 8),

                // ============================================================
                // Notifications List
                // ============================================================
                Expanded(
                  child: _notifications.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          physics: const BouncingScrollPhysics(),
                          itemCount: _notifications.length,
                          itemBuilder: (context, index) {
                            final notification = _notifications[index];
                            return _buildNotificationItem(notification, index);
                          },
                        ),
                ),
              ],
            ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Color(0xFF5235C5)),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          Text(
            'Notifications',
            style: GoogleFonts.manrope(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(width: 12),
          if (_unreadCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFE76F51),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${_unreadCount} new',
                style: GoogleFonts.manrope(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionsBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${_notifications.length} notifications',
            style: GoogleFonts.manrope(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF8A8A9A),
            ),
          ),
          if (_unreadCount > 0)
            GestureDetector(
              onTap: _isUpdating ? null : _markAllAsRead,
              child: Row(
                children: [
                  if (_isUpdating)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF5235C5),
                      ),
                    )
                  else
                    const Icon(
                      Icons.done_all_outlined,
                      color: Color(0xFF5235C5),
                      size: 18,
                    ),
                  const SizedBox(width: 4),
                  Text(
                    'Mark all read',
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
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

  Widget _buildNotificationItem(Map<String, dynamic> notification, int index) {
    final isRead = notification['is_read'] as bool;

    return GestureDetector(
      onTap: () {
        if (!isRead) {
          _markAsRead(notification['id']);
        }
        // عرض تفاصيل الإشعار
        _showNotificationDetails(notification);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isRead ? Colors.white : const Color(0xFFF0EDFF),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isRead ? const Color(0xFFE8E8EE) : const Color(0xFF5235C5).withValues(alpha: 0.2),
            width: isRead ? 1 : 2,
          ),
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
            // ============================================================
            // Icon
            // ============================================================
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: (notification['color'] as Color).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                notification['icon'] as IconData,
                color: notification['color'] as Color,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),

            // ============================================================
            // Content
            // ============================================================
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification['title'],
                          style: GoogleFonts.manrope(
                            fontSize: 15,
                            fontWeight: isRead ? FontWeight.w600 : FontWeight.w700,
                            color: isRead ? const Color(0xFF1A1A2E) : const Color(0xFF5235C5),
                          ),
                        ),
                      ),
                      if (!isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFF5235C5),
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification['body'],
                    style: GoogleFonts.manrope(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF6B6B7A),
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    notification['created_at'],
                    style: GoogleFonts.manrope(
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFFB0B0BA),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: (50 + index * 30).ms).slideX(
      begin: 0.05,
      end: 0,
      duration: 400.ms,
      delay: (50 + index * 30).ms,
    );
  }

  void _showNotificationDetails(Map<String, dynamic> notification) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ========== Header ==========
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: (notification['color'] as Color).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        notification['icon'] as IconData,
                        color: notification['color'] as Color,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      notification['title'],
                      style: GoogleFonts.manrope(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1A1A2E),
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            Text(
              notification['body'],
              style: GoogleFonts.manrope(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF484554),
                height: 1.6,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.access_time_outlined,
                    color: Color(0xFF8A8A9A),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Received: ${notification['created_at']}',
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF8A8A9A),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5235C5),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text('Close'),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'No notifications yet',
            style: GoogleFonts.manrope(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF6B6B7A),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'We\'ll notify you when important updates arrive.',
            style: GoogleFonts.manrope(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF8A8A9A),
            ),
          ),
        ],
      ),
    );
  }
}