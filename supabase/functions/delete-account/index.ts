// ============================================================
// 📄 supabase/functions/delete-account/index.ts
// ============================================================
// هذا الملف يُنشر على Supabase (وليس داخل مشروع Flutter)
// طريقة النشر: supabase functions deploy delete-account
// ============================================================

import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

Deno.serve(async (req) => {
  try {
    // ✅ التحقق من أن الطلب يحتوي على Authorization Header صحيح
    const authHeader = req.headers.get('Authorization')
    if (!authHeader) {
      return new Response(
        JSON.stringify({ error: 'Missing Authorization header' }),
        { status: 401, headers: { 'Content-Type': 'application/json' } },
      )
    }

    // ✅ Client بصلاحيات المستخدم نفسه (anon key + Authorization)
    // يُستخدم فقط للتحقق من هوية المستخدم المرسل للطلب
    const userClient = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_ANON_KEY')!,
      { global: { headers: { Authorization: authHeader } } },
    )

    const {
      data: { user },
      error: userError,
    } = await userClient.auth.getUser()

    if (userError || !user) {
      return new Response(
        JSON.stringify({ error: 'Invalid or expired session' }),
        { status: 401, headers: { 'Content-Type': 'application/json' } },
      )
    }

    // ✅ Client بصلاحيات service_role (موجود فقط على الخادم، أبداً في التطبيق)
    const adminClient = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
    )

    // ✅ حذف بيانات المستخدم من الجداول المرتبطة أولاً (لتجنّب أخطاء foreign key)
    await adminClient.from('questionnaire_history').delete().eq('user_id', user.id)
    await adminClient.from('recommendations_history').delete().eq('user_id', user.id)
    await adminClient.from('checkins').delete().eq('user_id', user.id)
    await adminClient.from('users').delete().eq('id', user.id)

    // ✅ حذف حساب المصادقة نفسه (يتطلب service_role)
    const { error: deleteError } = await adminClient.auth.admin.deleteUser(user.id)

    if (deleteError) {
      return new Response(
        JSON.stringify({ error: deleteError.message }),
        { status: 500, headers: { 'Content-Type': 'application/json' } },
      )
    }

    return new Response(
      JSON.stringify({ success: true }),
      { status: 200, headers: { 'Content-Type': 'application/json' } },
    )
  } catch (e) {
    return new Response(
      JSON.stringify({ error: String(e) }),
      { status: 500, headers: { 'Content-Type': 'application/json' } },
    )
  }
})