// lib/services/supabase_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  SupabaseClient get client => Supabase.instance.client;
  User? get currentUser => client.auth.currentUser;

  // ========== المصادقة ==========

  Future<AuthResponse> signIn(String email, String password) async {
    return await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    return await client.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': fullName,
      },
    );
  }

  Future<void> signOut() async {
    await client.auth.signOut();
  }

  // ========== إدارة المستخدمين ==========

  Future<void> saveUserData({
    required String userId,
    required String email,
    required String fullName,
    String? ageGroup,
    String? parentEmail,
    bool parentConsent = false,
  }) async {
    try {
      await client.from('users').insert({
        'id': userId,
        'email': email,
        'full_name': fullName,
        'age_group': ageGroup,
        'parent_email': parentEmail,
        'parent_consent': parentConsent,
      });
    } catch (e) {
      // إذا فشل الإدراج، جرب upsert
      await client.from('users').upsert({
        'id': userId,
        'email': email,
        'full_name': fullName,
        'age_group': ageGroup,
        'parent_email': parentEmail,
        'parent_consent': parentConsent,
      });
    }
  }

  Future<Map<String, dynamic>?> getUserData(String userId) async {
    final response = await client
        .from('users')
        .select()
        .eq('id', userId)
        .maybeSingle();
    return response;
  }

  // ========== إدارة Check-ins ==========

  Future<int> saveCheckin({
    required String userId,
    required String freeText,
    String? voiceTranscript,
    required int aiToolsCount,
    required String usagePattern,
    required int focusDifficulty,
    required int energyLevel,
    required bool tookBreaks,
    required int sleepHours,
    required int cognitiveLoadScore,
    String? recommendation,
    required int confidenceScore,
  }) async {
    final response = await client.from('checkins').insert({
      'user_id': userId,
      'checkin_date': DateTime.now().toIso8601String().split('T')[0],
      'free_text': freeText,
      'voice_transcript': voiceTranscript,
      'ai_tools_count': aiToolsCount,
      'usage_pattern': usagePattern,
      'focus_difficulty': focusDifficulty,
      'energy_level': energyLevel,
      'took_breaks': tookBreaks,
      'sleep_hours': sleepHours,
      'cognitive_load_score': cognitiveLoadScore,
      'recommendation': recommendation,
      'confidence_score': confidenceScore,
    }).select();

    final checkinId = response[0]['id'] as int;

    if (recommendation != null) {
      await saveRecommendation(
        userId: userId,
        checkinId: checkinId,
        recommendationText: recommendation,
      );
    }

    return checkinId;
  }

  Future<List<Map<String, dynamic>>> getRecentCheckins(String userId, {int limit = 7}) async {
    final response = await client
        .from('checkins')
        .select()
        .eq('user_id', userId)
        .order('checkin_date', ascending: false)
        .limit(limit);
    return response;
  }

  Future<void> updateCheckinCorrection({
    required int checkinId,
    required int userCorrection,
    required bool userAgreement,
  }) async {
    await client
        .from('checkins')
        .update({
          'user_correction': userCorrection,
          'user_agreement': userAgreement,
        })
        .eq('id', checkinId);
  }

  // ========== إدارة التوصيات ==========

  Future<void> saveRecommendation({
    required String userId,
    required int checkinId,
    required String recommendationText,
  }) async {
    await client.from('recommendations_history').insert({
      'user_id': userId,
      'checkin_id': checkinId,
      'recommendation_text': recommendationText,
    });
  }

  // ========== إدارة الاستبيانات ==========

  Future<void> saveQuestionnaire({
    required String userId,
    required List<String> selectedTools,
    required String dailyUsage,
    required bool reliesOnAI,
    required int focusDifficultyGeneral,
    required String mentalFatigueFrequency,
    required String fatigueTime,
    String? workField,
    String? avgSleepHours,
    String? productiveTime,
    bool? experiencedBurnout,
    required int cognitiveLoadScore,
  }) async {
    await client.from('questionnaire_history').insert({
      'user_id': userId,
      'selected_tools': selectedTools,
      'daily_usage': dailyUsage,
      'relies_on_ai': reliesOnAI,
      'focus_difficulty_general': focusDifficultyGeneral,
      'mental_fatigue_frequency': mentalFatigueFrequency,
      'fatigue_time': fatigueTime,
      'work_field': workField,
      'avg_sleep_hours': avgSleepHours,
      'productive_time': productiveTime,
      'experienced_burnout': experiencedBurnout,
      'cognitive_load_score': cognitiveLoadScore,
    });
  }

  Future<List<Map<String, dynamic>>> getQuestionnaireHistory(String userId) async {
    final response = await client
        .from('questionnaire_history')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return response;
  }

  Future<void> deleteAllQuestionnaireHistory(String userId) async {
    await client
        .from('questionnaire_history')
        .delete()
        .eq('user_id', userId);
  }

  // ========== حذف الحساب ==========
  // ✅ تم التعديل: لا يمكن استدعاء auth.admin.* مباشرة من التطبيق
  // (يتطلب service_role key وهو ممنوع داخل تطبيق الموبايل).
  // بدلاً من ذلك، نستدعي Edge Function تعمل على الخادم بصلاحيات admin.
  // يجب نشرها أولاً: supabase functions deploy delete-account
  Future<void> deleteAccount() async {
    final userId = currentUser?.id;
    if (userId == null) {
      throw Exception('No user is currently signed in');
    }

    final response = await client.functions.invoke('delete-account');

    if (response.status != 200) {
      throw Exception(
        'Failed to delete account: ${response.data?['error'] ?? 'Unknown error'}',
      );
    }

    // ✅ تسجيل الخروج محلياً بعد نجاح الحذف على الخادم
    await client.auth.signOut();
  }
}