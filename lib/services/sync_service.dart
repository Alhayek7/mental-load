import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SyncService {
  static const String _pendingKey = 'pending_questionnaire';

  // ✅ حفظ محلياً كـ pending
  static Future<void> savePending(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_pendingKey, jsonEncode(data));
    debugPrint('💾 Saved locally as pending sync');
  }

  // ✅ رفع البيانات المعلقة لـ Supabase
  static Future<void> syncPending() async {
    final prefs = await SharedPreferences.getInstance();
    final pending = prefs.getString(_pendingKey);
    if (pending == null) return;

    try {
      final data = jsonDecode(pending) as Map<String, dynamic>;
      final client = Supabase.instance.client;
      final user = client.auth.currentUser;
      if (user == null) return;

      // تأكد أن user_id صحيح
      data['user_id'] = user.id;

      await client.from('questionnaire_history').insert(data);
      await client.from('users').upsert({
        'id': user.id,
        'questionnaire_completed': true,
      });

      // ✅ احذف الـ pending بعد النجاح
      await prefs.remove(_pendingKey);
      debugPrint('✅ Pending data synced to Supabase');
    } catch (e) {
      debugPrint('⚠️ Sync failed, will retry later: $e');
    }
  }

  // ✅ هل في بيانات معلقة؟
  static Future<bool> hasPending() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_pendingKey) != null;
  }
}