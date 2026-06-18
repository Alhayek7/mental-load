-- ============================================================
-- 🗄️ CLEARLOAD - قاعدة البيانات الكاملة
-- 📌 USAII Global AI Hackathon 2026 | Undergraduate Track
-- 📌 تحدّي: Productivity: "Second Brain for Real Life"
-- ============================================================

-- ============================================================
-- 1. حذف الجداول القديمة (تنظيف شامل)
-- ============================================================
DROP TABLE IF EXISTS questionnaire_history CASCADE;
DROP TABLE IF EXISTS notifications CASCADE;
DROP TABLE IF EXISTS recommendations_history CASCADE;
DROP TABLE IF EXISTS checkins CASCADE;
DROP TABLE IF EXISTS users CASCADE;

-- ============================================================
-- 2. إنشاء جدول users (المستخدمون)
-- ============================================================
CREATE TABLE users (
  -- المعرف الأساسي (مرتبط بـ Supabase Auth)
  id UUID PRIMARY KEY,
  
  -- معلومات الحساب
  email TEXT UNIQUE NOT NULL,
  full_name TEXT NOT NULL,
  
  -- معلومات ديموغرافية
  age_group TEXT CHECK (age_group IN ('under_18', '18_25', '26_35', '36_50', '50+')),
  
  -- موافقة ولي الأمر (للقاصرين)
  parent_email TEXT,
  parent_consent BOOLEAN DEFAULT FALSE,
  
  -- حالة الاستبيان
  questionnaire_completed BOOLEAN DEFAULT FALSE,
  
  -- إحصائيات تلقائية
  created_at TIMESTAMP DEFAULT NOW(),
  last_checkin DATE,
  total_checkins INTEGER DEFAULT 0,
  avg_cognitive_score DECIMAL(3,2)
);

-- ============================================================
-- 3. إنشاء جدول checkins (سجلات الفحوصات اليومية)
-- ============================================================
CREATE TABLE checkins (
  -- المعرف الأساسي
  id SERIAL PRIMARY KEY,
  
  -- العلاقة بالمستخدم
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  
  -- التاريخ
  checkin_date DATE NOT NULL,
  
  -- المحتوى النصي
  free_text TEXT NOT NULL,
  voice_transcript TEXT,
  
  -- استخدام أدوات الذكاء الاصطناعي
  ai_tools_count INTEGER CHECK (ai_tools_count BETWEEN 0 AND 10),
  usage_pattern TEXT CHECK (usage_pattern IN ('continuous', 'intermittent')),
  
  -- الحالة الذهنية
  focus_difficulty INTEGER CHECK (focus_difficulty BETWEEN 1 AND 5),
  energy_level INTEGER CHECK (energy_level BETWEEN 1 AND 5),
  took_breaks BOOLEAN DEFAULT FALSE,
  sleep_hours INTEGER CHECK (sleep_hours BETWEEN 0 AND 12),
  
  -- نتيجة التحليل
  cognitive_load_score INTEGER CHECK (cognitive_load_score BETWEEN 1 AND 5),
  confidence_score INTEGER CHECK (confidence_score BETWEEN 0 AND 100),
  
  -- Human-in-the-Loop
  user_agreement BOOLEAN DEFAULT FALSE,
  user_correction INTEGER CHECK (user_correction BETWEEN 1 AND 5),
  
  -- التوصيات والمتابعة
  recommendation TEXT,
  followed_recommendation BOOLEAN,
  
  -- طلب المساعدة
  needs_help BOOLEAN DEFAULT FALSE,
  
  -- الطابع الزمني
  timestamp TIMESTAMP DEFAULT NOW()
);

-- ============================================================
-- 4. إنشاء جدول recommendations_history (سجل التوصيات)
-- ============================================================
CREATE TABLE recommendations_history (
  id SERIAL PRIMARY KEY,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  checkin_id INTEGER REFERENCES checkins(id) ON DELETE CASCADE,
  recommendation_text TEXT NOT NULL,
  was_followed BOOLEAN,
  effect_on_next_score INTEGER,
  created_at TIMESTAMP DEFAULT NOW()
);

-- ============================================================
-- 5. إنشاء جدول questionnaire_history (سجل الاستبيانات)
-- ============================================================
CREATE TABLE questionnaire_history (
  id SERIAL PRIMARY KEY,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  
  -- أسئلة الاستبيان
  selected_tools TEXT[],
  daily_usage TEXT,
  relies_on_ai BOOLEAN,
  focus_difficulty_general INTEGER CHECK (focus_difficulty_general BETWEEN 1 AND 5),
  mental_fatigue_frequency TEXT,
  fatigue_time TEXT,
  work_field TEXT,
  avg_sleep_hours TEXT,
  productive_time TEXT,
  experienced_burnout BOOLEAN,
  
  -- النتيجة
  cognitive_load_score INTEGER CHECK (cognitive_load_score BETWEEN 1 AND 5),
  
  -- الطابع الزمني
  created_at TIMESTAMP DEFAULT NOW()
);

-- ============================================================
-- 6. إنشاء جدول notifications (الإشعارات)
-- ============================================================
CREATE TABLE notifications (
  id SERIAL PRIMARY KEY,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  type TEXT CHECK (type IN ('reminder', 'alert', 'tip', 'achievement')),
  is_read BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT NOW()
);

-- ============================================================
-- 7. تفعيل Row Level Security (RLS)
-- ============================================================
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE checkins ENABLE ROW LEVEL SECURITY;
ALTER TABLE recommendations_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE questionnaire_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

-- ============================================================
-- 8. سياسات الأمان - users
-- ============================================================
DROP POLICY IF EXISTS "Users can view own data" ON users;
DROP POLICY IF EXISTS "Users can update own data" ON users;
DROP POLICY IF EXISTS "Users can insert own data" ON users;

CREATE POLICY "Users can view own data" ON users 
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own data" ON users 
  FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can insert own data" ON users 
  FOR INSERT WITH CHECK (auth.uid() = id);

-- ============================================================
-- 9. سياسات الأمان - checkins
-- ============================================================
DROP POLICY IF EXISTS "Users can view own checkins" ON checkins;
DROP POLICY IF EXISTS "Users can insert own checkins" ON checkins;
DROP POLICY IF EXISTS "Users can update own checkins" ON checkins;

CREATE POLICY "Users can view own checkins" ON checkins 
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own checkins" ON checkins 
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own checkins" ON checkins 
  FOR UPDATE USING (auth.uid() = user_id);

-- ============================================================
-- 10. سياسات الأمان - recommendations_history
-- ============================================================
DROP POLICY IF EXISTS "Users can view own recommendations" ON recommendations_history;
DROP POLICY IF EXISTS "Users can insert own recommendations" ON recommendations_history;

CREATE POLICY "Users can view own recommendations" ON recommendations_history 
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own recommendations" ON recommendations_history 
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- ============================================================
-- 11. سياسات الأمان - questionnaire_history
-- ============================================================
DROP POLICY IF EXISTS "Users can view own questionnaire history" ON questionnaire_history;
DROP POLICY IF EXISTS "Users can insert own questionnaire history" ON questionnaire_history;
DROP POLICY IF EXISTS "Users can delete own questionnaire history" ON questionnaire_history;

CREATE POLICY "Users can view own questionnaire history" ON questionnaire_history 
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own questionnaire history" ON questionnaire_history 
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own questionnaire history" ON questionnaire_history 
  FOR DELETE USING (auth.uid() = user_id);

-- ============================================================
-- 12. سياسات الأمان - notifications
-- ============================================================
DROP POLICY IF EXISTS "Users can view own notifications" ON notifications;
DROP POLICY IF EXISTS "Users can update own notifications" ON notifications;

CREATE POLICY "Users can view own notifications" ON notifications 
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can update own notifications" ON notifications 
  FOR UPDATE USING (auth.uid() = user_id);

-- ============================================================
-- 13. الفهارس (Indexes) - تحسين الأداء
-- ============================================================

-- فهارس checkins
CREATE INDEX IF NOT EXISTS idx_checkins_user_id ON checkins(user_id);
CREATE INDEX IF NOT EXISTS idx_checkins_date ON checkins(checkin_date);
CREATE INDEX IF NOT EXISTS idx_checkins_user_date ON checkins(user_id, checkin_date DESC);
CREATE INDEX IF NOT EXISTS idx_checkins_high_score ON checkins(cognitive_load_score) WHERE cognitive_load_score >= 4;
CREATE INDEX IF NOT EXISTS idx_checkins_needs_help ON checkins(needs_help) WHERE needs_help = TRUE;

-- فهارس recommendations_history
CREATE INDEX IF NOT EXISTS idx_recommendations_checkin ON recommendations_history(checkin_id);
CREATE INDEX IF NOT EXISTS idx_recommendations_user ON recommendations_history(user_id);

-- فهارس notifications
CREATE INDEX IF NOT EXISTS idx_notifications_user_read ON notifications(user_id, is_read);

-- فهارس questionnaire_history
CREATE INDEX IF NOT EXISTS idx_questionnaire_user_date ON questionnaire_history(user_id, created_at DESC);

-- ============================================================
-- 14. Trigger: إنشاء المستخدم تلقائياً في جدول users
-- ============================================================

-- دالة لإنشاء مستخدم جديد
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.users (id, email, full_name, created_at)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'full_name', 'User'),
    NEW.created_at
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;


CREATE TABLE notifications (
  id SERIAL PRIMARY KEY,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  type TEXT CHECK (type IN ('reminder', 'alert', 'tip', 'achievement')),
  is_read BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Trigger
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();

-- ============================================================
-- 15. Trigger: تحديث متوسط Score تلقائياً
-- ============================================================

-- دالة تحديث الإحصائيات
CREATE OR REPLACE FUNCTION update_user_avg_score()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE users
  SET 
    avg_cognitive_score = (
      SELECT ROUND(AVG(cognitive_load_score)::numeric, 2)
      FROM checkins 
      WHERE user_id = NEW.user_id
    ),
    total_checkins = (
      SELECT COUNT(*) 
      FROM checkins 
      WHERE user_id = NEW.user_id
    ),
    last_checkin = NEW.checkin_date
  WHERE id = NEW.user_id;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger
DROP TRIGGER IF EXISTS trigger_update_user_avg ON checkins;
CREATE TRIGGER trigger_update_user_avg
  AFTER INSERT ON checkins
  FOR EACH ROW
  EXECUTE FUNCTION update_user_avg_score();

-- ============================================================
-- 16. التحقق من إنشاء الجداول
-- ============================================================
SELECT 
  table_name, 
  table_type 
FROM information_schema.tables 
WHERE table_schema = 'public' 
ORDER BY table_name;

-- ============================================================
-- 17. عرض هيكل الجداول (للتحقق)
-- ============================================================
SELECT 
  column_name, 
  data_type, 
  is_nullable,
  column_default
FROM information_schema.columns 
WHERE table_schema = 'public' 
ORDER BY table_name, ordinal_position;

-- ============================================================
-- 18. عرض سياسات RLS (للتحقق)
-- ============================================================
SELECT 
  schemaname,
  tablename,
  policyname,
  permissive,
  cmd,
  qual
FROM pg_policies 
WHERE schemaname = 'public'
ORDER BY tablename, policyname;

-- ============================================================
-- 19. بيانات اختبارية (للاختبار فقط - علّقها في الإنتاج)
-- ============================================================

-- ملاحظة: هذه البيانات للاختبار فقط
-- يجب أن يكون المستخدم موجوداً في auth.users أولاً

-- إدراج مستخدم اختباري
-- INSERT INTO users (id, email, full_name, age_group, questionnaire_completed)
-- VALUES (
--   '00000000-0000-0000-0000-000000000000',
--   'test@example.com',
--   'Test User',
--   '26_35',
--   TRUE
-- );

-- إدراج Check-in اختباري
-- INSERT INTO checkins (
--   user_id, 
--   checkin_date, 
--   free_text, 
--   ai_tools_count, 
--   usage_pattern, 
--   focus_difficulty, 
--   energy_level, 
--   cognitive_load_score, 
--   confidence_score,
--   recommendation
-- ) VALUES (
--   '00000000-0000-0000-0000-000000000000',
--   CURRENT_DATE,
--   'Used ChatGPT for 3 hours and Claude for 2 hours. Feeling mentally tired and struggling to focus.',
--   2,
--   'continuous',
--   4,
--   3,
--   4,
--   92,
--   'Reduce AI tools to 2 per session and take a 10-minute break'
-- );

-- ============================================================
-- 20. استعلامات مفيدة للتحليل (للاستخدام المستقبلي)
-- ============================================================

-- عرض آخر 7 أيام من Check-ins لمستخدم معين
-- SELECT * FROM checkins 
-- WHERE user_id = 'your-user-id' 
-- ORDER BY checkin_date DESC 
-- LIMIT 7;

-- حساب متوسط Score لآخر 7 أيام
-- SELECT 
--   ROUND(AVG(cognitive_load_score)::numeric, 2) AS avg_score,
--   MIN(cognitive_load_score) AS min_score,
--   MAX(cognitive_load_score) AS max_score
-- FROM checkins 
-- WHERE user_id = 'your-user-id'
-- AND checkin_date >= CURRENT_DATE - INTERVAL '7 days';

-- عرض أكثر التوصيات فعالية
-- SELECT 
--   recommendation_text,
--   COUNT(*) AS times_given,
--   ROUND(AVG(effect_on_next_score)::numeric, 2) AS avg_effect
-- FROM recommendations_history
-- WHERE effect_on_next_score IS NOT NULL
-- GROUP BY recommendation_text
-- ORDER BY avg_effect DESC;

-- ============================================================
-- ✅ نهاية الكود
-- ============================================================