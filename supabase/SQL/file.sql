-- =====================================================
-- 1. حذف الجداول القديمة (إذا وجدت)
-- =====================================================
DROP TABLE IF EXISTS questionnaire_history CASCADE;
DROP TABLE IF EXISTS recommendations_history CASCADE;
DROP TABLE IF EXISTS checkins CASCADE;
DROP TABLE IF EXISTS notifications CASCADE;
DROP TABLE IF EXISTS users CASCADE;

-- =====================================================
-- 2. إنشاء جدول users (بدون FOREIGN KEY)
-- =====================================================
CREATE TABLE users (
  id UUID PRIMARY KEY,
  email TEXT UNIQUE NOT NULL,
  full_name TEXT NOT NULL,
  age_group TEXT CHECK (age_group IN ('under_18', '18_25', '26_35', '36_50', '50+')),
  parent_email TEXT,
  parent_consent BOOLEAN DEFAULT FALSE,
  questionnaire_completed BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT NOW(),
  last_checkin DATE,
  total_checkins INTEGER DEFAULT 0,
  avg_cognitive_score DECIMAL(3,2)
);

-- =====================================================
-- 3. إنشاء باقي الجداول
-- =====================================================

-- جدول Check-ins
CREATE TABLE checkins (
  id SERIAL PRIMARY KEY,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  checkin_date DATE NOT NULL,
  free_text TEXT NOT NULL,
  voice_transcript TEXT,
  ai_tools_count INTEGER CHECK (ai_tools_count BETWEEN 0 AND 10),
  usage_pattern TEXT CHECK (usage_pattern IN ('continuous', 'intermittent')),
  focus_difficulty INTEGER CHECK (focus_difficulty BETWEEN 1 AND 5),
  energy_level INTEGER CHECK (energy_level BETWEEN 1 AND 5),
  took_breaks BOOLEAN DEFAULT FALSE,
  sleep_hours INTEGER CHECK (sleep_hours BETWEEN 0 AND 12),
  cognitive_load_score INTEGER CHECK (cognitive_load_score BETWEEN 1 AND 5),
  user_agreement BOOLEAN DEFAULT FALSE,
  user_correction INTEGER CHECK (user_correction BETWEEN 1 AND 5),
  recommendation TEXT,
  followed_recommendation BOOLEAN,
  needs_help BOOLEAN DEFAULT FALSE,
  confidence_score INTEGER CHECK (confidence_score BETWEEN 0 AND 100),
  timestamp TIMESTAMP DEFAULT NOW()
);

-- جدول سجل التوصيات
CREATE TABLE recommendations_history (
  id SERIAL PRIMARY KEY,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  checkin_id INTEGER REFERENCES checkins(id) ON DELETE CASCADE,
  recommendation_text TEXT NOT NULL,
  was_followed BOOLEAN,
  effect_on_next_score INTEGER,
  created_at TIMESTAMP DEFAULT NOW()
);

-- جدول سجل الاستبيانات
CREATE TABLE questionnaire_history (
  id SERIAL PRIMARY KEY,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
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
  cognitive_load_score INTEGER CHECK (cognitive_load_score BETWEEN 1 AND 5),
  created_at TIMESTAMP DEFAULT NOW()
);

-- جدول الإشعارات
CREATE TABLE notifications (
  id SERIAL PRIMARY KEY,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  type TEXT CHECK (type IN ('reminder', 'alert', 'tip', 'achievement')),
  is_read BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT NOW()
);

-- =====================================================
-- 4. تفعيل RLS
-- =====================================================
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE checkins ENABLE ROW LEVEL SECURITY;
ALTER TABLE recommendations_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE questionnaire_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- 5. سياسات الأمان
-- =====================================================

-- users
DROP POLICY IF EXISTS "Users can view own data" ON users;
DROP POLICY IF EXISTS "Users can update own data" ON users;
DROP POLICY IF EXISTS "Users can insert own data" ON users;

CREATE POLICY "Users can view own data" ON users FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users can update own data" ON users FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "Users can insert own data" ON users FOR INSERT WITH CHECK (auth.uid() = id);

-- checkins
DROP POLICY IF EXISTS "Users can view own checkins" ON checkins;
DROP POLICY IF EXISTS "Users can insert own checkins" ON checkins;
DROP POLICY IF EXISTS "Users can update own checkins" ON checkins;

CREATE POLICY "Users can view own checkins" ON checkins FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own checkins" ON checkins FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own checkins" ON checkins FOR UPDATE USING (auth.uid() = user_id);

-- recommendations_history
DROP POLICY IF EXISTS "Users can view own recommendations" ON recommendations_history;
DROP POLICY IF EXISTS "Users can insert own recommendations" ON recommendations_history;

CREATE POLICY "Users can view own recommendations" ON recommendations_history FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own recommendations" ON recommendations_history FOR INSERT WITH CHECK (auth.uid() = user_id);

-- questionnaire_history
DROP POLICY IF EXISTS "Users can view own questionnaire history" ON questionnaire_history;
DROP POLICY IF EXISTS "Users can insert own questionnaire history" ON questionnaire_history;
DROP POLICY IF EXISTS "Users can delete own questionnaire history" ON questionnaire_history;

CREATE POLICY "Users can view own questionnaire history" ON questionnaire_history FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own questionnaire history" ON questionnaire_history FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can delete own questionnaire history" ON questionnaire_history FOR DELETE USING (auth.uid() = user_id);

-- notifications
DROP POLICY IF EXISTS "Users can view own notifications" ON notifications;
CREATE POLICY "Users can view own notifications" ON notifications FOR SELECT USING (auth.uid() = user_id);

-- =====================================================
-- 6. الفهارس
-- =====================================================
CREATE INDEX IF NOT EXISTS idx_checkins_user_id ON checkins(user_id);
CREATE INDEX IF NOT EXISTS idx_checkins_date ON checkins(checkin_date);
CREATE INDEX IF NOT EXISTS idx_checkins_user_date ON checkins(user_id, checkin_date DESC);
CREATE INDEX IF NOT EXISTS idx_checkins_high_score ON checkins(cognitive_load_score) WHERE cognitive_load_score >= 4;
CREATE INDEX IF NOT EXISTS idx_checkins_needs_help ON checkins(needs_help) WHERE needs_help = TRUE;
CREATE INDEX IF NOT EXISTS idx_recommendations_checkin ON recommendations_history(checkin_id);
CREATE INDEX IF NOT EXISTS idx_notifications_user_read ON notifications(user_id, is_read);
CREATE INDEX IF NOT EXISTS idx_questionnaire_user_date ON questionnaire_history(user_id, created_at DESC);

-- =====================================================
-- 7. Trigger لإنشاء المستخدم تلقائياً في جدول users
-- =====================================================

-- دالة لإنشاء مستخدم جديد في جدول users
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

-- Trigger لإنشاء المستخدم عند التسجيل
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();

-- =====================================================
-- 8. دالة تحديث متوسط Score
-- =====================================================
CREATE OR REPLACE FUNCTION update_user_avg_score()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE users
  SET avg_cognitive_score = (
    SELECT AVG(cognitive_load_score) 
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

DROP TRIGGER IF EXISTS trigger_update_user_avg ON checkins;
CREATE TRIGGER trigger_update_user_avg
  AFTER INSERT ON checkins
  FOR EACH ROW
  EXECUTE FUNCTION update_user_avg_score();

-- =====================================================
-- 9. التحقق
-- =====================================================
SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' ORDER BY table_name;