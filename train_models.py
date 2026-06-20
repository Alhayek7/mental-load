# ============================================================
# 📄 train_from_supabase.py - تدريب النموذج من بيانات المستخدمين
# 📌 ClearLoad AI Model - Training with Real User Data
# ============================================================

import pandas as pd
import numpy as np
import joblib
import pickle
import re
import os
import warnings
from datetime import datetime, timedelta
warnings.filterwarnings('ignore')

from supabase import create_client
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.ensemble import RandomForestClassifier, GradientBoostingClassifier, VotingClassifier
from sklearn.linear_model import LogisticRegression
from sklearn.preprocessing import LabelEncoder, StandardScaler
from sklearn.model_selection import train_test_split, cross_val_score
from sklearn.metrics import accuracy_score, classification_report, confusion_matrix, f1_score

# ============================================================
# 1. إعدادات Supabase
# ============================================================

SUPABASE_URL = "https://orjgxyxxuoqjyhivpifb.supabase.co"
SUPABASE_KEY = "sb_publishable_eE4xLtu7v2Aq9FCeZJnZSw_oMpqw1jJ"

# ============================================================
# 2. أدوات معالجة النصوص
# ============================================================

NEGATIVE_WORDS = [
    'tired', 'exhausted', 'overwhelmed', 'burnout', 'stressed',
    'headache', 'fatigue', 'drained', 'anxious', 'pressure',
    'distracted', 'mental', 'heavy', 'fog', 'depleted',
    'strained', 'overloaded', 'frustrated', 'helpless', 'overworked',
    'panicked', 'unable', 'struggling', 'difficult', 'hard'
]

POSITIVE_WORDS = [
    'productive', 'focused', 'great', 'energized', 'refreshed',
    'calm', 'clear', 'motivated', 'sharp', 'efficient',
    'accomplished', 'satisfied', 'good', 'happy', 'relaxed',
    'peaceful', 'balanced', 'optimistic', 'confident', 'inspired'
]

def clean_text(text):
    """تنظيف النص"""
    if not text or not isinstance(text, str):
        return ''
    text = text.lower()
    text = re.sub(r'[^\w\s]', '', text)
    text = re.sub(r'\d+', '', text)
    text = re.sub(r'\s+', ' ', text).strip()
    return text

def extract_features(text):
    """استخراج ميزات متقدمة"""
    lower = text.lower()
    words = lower.split()
    word_count = len(words)
    
    neg_count = sum(1 for w in NEGATIVE_WORDS if w in lower)
    pos_count = sum(1 for w in POSITIVE_WORDS if w in lower)
    
    return {
        'word_count': min(word_count, 50),
        'char_count': min(len(text), 500),
        'avg_word_length': len(text) / (word_count + 1),
        'negative_count': min(neg_count, 10),
        'positive_count': min(pos_count, 10),
        'net_sentiment': pos_count - neg_count,
        'sentiment_ratio': pos_count / (neg_count + 1),
        'has_negative': neg_count > 0,
        'has_positive': pos_count > 0,
        'exclamation_count': min(text.count('!'), 5),
        'question_count': min(text.count('?'), 5),
        'has_ai_tools': any(w in lower for w in ['chatgpt', 'claude', 'gemini', 'copilot', 'ai']),
        'has_work': any(w in lower for w in ['work', 'task', 'project', 'job', 'deadline']),
        'has_break': any(w in lower for w in ['break', 'rest', 'pause', 'stop']),
    }

# ============================================================
# 3. جلب البيانات من Supabase
# ============================================================

def fetch_user_data():
    """
    جلب جميع بيانات المستخدمين من Supabase
    بما في ذلك النصوص والـ Scores وتصحيحات المستخدمين
    """
    print("🔄 Connecting to Supabase...")
    
    try:
        supabase = create_client(SUPABASE_URL, SUPABASE_KEY)
        print("✅ Connected to Supabase")
    except Exception as e:
        print(f"❌ Failed to connect: {e}")
        return None
    
    # ✅ جلب جميع Check-ins
    print("📊 Fetching checkins data...")
    try:
        response = supabase.table('checkins').select(
            'id, user_id, free_text, cognitive_load_score, '
            'user_correction, user_agreement, recommendation, '
            'confidence_score, checkin_date'
        ).order('checkin_date', desc=True).execute()
        
        data = response.data
        print(f"✅ Found {len(data)} check-in records")
        
    except Exception as e:
        print(f"❌ Failed to fetch data: {e}")
        return None
    
    if not data:
        print("⚠️ No data found in checkins table")
        return None
    
    # ✅ تحويل إلى DataFrame
    df = pd.DataFrame(data)
    
    # ✅ تحويل Score إلى فئة (Level)
    def score_to_level(score):
        if score is None:
            return None
        if score <= 2:
            return 'Low'
        elif score == 3:
            return 'Moderate'
        elif score == 4:
            return 'High'
        else:
            return 'Critical'
    
    df['level'] = df['cognitive_load_score'].apply(score_to_level)
    
    # ✅ استخدام تصحيح المستخدم إذا كان متاحاً (Human-in-the-Loop)
    if 'user_correction' in df.columns:
        # ✅ إذا صحح المستخدم، استخدم تصحيحه بدلاً من الـ Score الأصلي
        correction_mask = df['user_correction'].notna()
        df.loc[correction_mask, 'level'] = df.loc[correction_mask, 'user_correction'].apply(score_to_level)
        print(f"📝 Applied {correction_mask.sum()} user corrections")
    
    # ✅ إزالة الصفوف التي لا تحتوي على نص أو فئة
    df = df.dropna(subset=['free_text', 'level'])
    df = df[df['free_text'].str.len() > 3]  # ✅ تجاهل النصوص القصيرة جداً
    
    print(f"📊 Final dataset: {len(df)} samples")
    print(f"📊 Class distribution:")
    print(df['level'].value_counts())
    
    return df

# ============================================================
# 4. تدريب النموذج المحسّن
# ============================================================

def train_optimized_model(df):
    """
    تدريب النموذج على بيانات المستخدمين مع تحسينات متقدمة
    """
    
    print("\n" + "=" * 80)
    print("   🚀 Training Model with User Data")
    print("=" * 80)
    
    # ✅ معالجة النصوص
    print("\n🔄 Preprocessing text...")
    df['clean_text'] = df['free_text'].apply(clean_text)
    
    # ✅ استخراج الميزات
    print("🔄 Extracting features...")
    df['features'] = df['free_text'].apply(extract_features)
    features_df = pd.DataFrame(df['features'].tolist())
    print(f"✅ Features extracted: {len(features_df.columns)} features")
    
    # ✅ TF-IDF Vectorizer (محسّن)
    print("\n🔄 Training TF-IDF Vectorizer...")
    tfidf = TfidfVectorizer(
        max_features=1000,
        ngram_range=(1, 3),
        min_df=2,
        max_df=0.85,
        stop_words='english',
        sublinear_tf=True,
        use_idf=True,
        smooth_idf=True
    )
    X_text = tfidf.fit_transform(df['clean_text']).toarray()
    print(f"✅ TF-IDF vocabulary size: {len(tfidf.vocabulary_)}")
    
    # ✅ دمج الميزات
    X_extra = features_df.values
    X = np.hstack([X_text, X_extra])
    print(f"✅ Feature matrix shape: {X.shape}")
    
    # ✅ Scaling
    print("🔄 Scaling features...")
    scaler = StandardScaler()
    X_scaled = scaler.fit_transform(X)
    
    # ✅ Label Encoder
    print("🔄 Training Label Encoder...")
    label_encoder = LabelEncoder()
    y = label_encoder.fit_transform(df['level'])
    print(f"✅ Label Encoder classes: {label_encoder.classes_.tolist()}")
    
    # ✅ تقسيم البيانات
    X_train, X_test, y_train, y_test = train_test_split(
        X_scaled, y, test_size=0.2, random_state=42, stratify=y
    )
    
    # ============================================================
    # 5. النماذج المتعددة
    # ============================================================
    
    print("\n🔄 Training Multiple Models...")
    
    models = {
        'Random Forest': RandomForestClassifier(
            n_estimators=200,
            max_depth=15,
            min_samples_split=3,
            min_samples_leaf=1,
            random_state=42,
            n_jobs=-1,
            class_weight='balanced'
        ),
        'Gradient Boosting': GradientBoostingClassifier(
            n_estimators=100,
            max_depth=8,
            learning_rate=0.1,
            random_state=42
        ),
        'Logistic Regression': LogisticRegression(
            max_iter=1000,
            random_state=42,
            class_weight='balanced'
        )
    }
    
    best_model = None
    best_accuracy = 0
    best_f1 = 0
    
    for name, model in models.items():
        model.fit(X_train, y_train)
        y_pred = model.predict(X_test)
        accuracy = accuracy_score(y_test, y_pred)
        f1 = f1_score(y_test, y_pred, average='weighted')
        print(f"  ✅ {name}: Accuracy={accuracy:.2%}, F1={f1:.2%}")
        
        if accuracy > best_accuracy:
            best_accuracy = accuracy
            best_f1 = f1
            best_model = model
    
    # ✅ Voting Classifier (تحسين إضافي)
    print("\n🔄 Creating Voting Ensemble...")
    voting_model = VotingClassifier(
        estimators=[
            ('rf', models['Random Forest']),
            ('gb', models['Gradient Boosting']),
            ('lr', models['Logistic Regression'])
        ],
        voting='soft',
        weights=[2, 1, 1]
    )
    voting_model.fit(X_train, y_train)
    y_pred_voting = voting_model.predict(X_test)
    voting_accuracy = accuracy_score(y_test, y_pred_voting)
    voting_f1 = f1_score(y_test, y_pred_voting, average='weighted')
    print(f"  ✅ Voting Ensemble: Accuracy={voting_accuracy:.2%}, F1={voting_f1:.2%}")
    
    if voting_accuracy > best_accuracy:
        best_model = voting_model
        best_accuracy = voting_accuracy
        best_f1 = voting_f1
    
    # ============================================================
    # 6. التقييم النهائي
    # ============================================================
    
    print("\n📊 Final Evaluation:")
    print("-" * 50)
    
    y_pred = best_model.predict(X_test)
    
    print(f"✅ Best Model Accuracy: {best_accuracy:.2%}")
    print(f"✅ Weighted F1 Score: {best_f1:.2%}")
    
    # ✅ Cross Validation
    cv_scores = cross_val_score(best_model, X_scaled, y, cv=5)
    print(f"✅ Cross-validation scores: {cv_scores}")
    print(f"✅ Mean CV score: {cv_scores.mean():.2%}")
    
    # ✅ Classification Report
    print("\n📊 Classification Report:")
    print(classification_report(y_test, y_pred, target_names=label_encoder.classes_))
    
    # ✅ Confusion Matrix
    print("\n📊 Confusion Matrix:")
    print(confusion_matrix(y_test, y_pred))
    
    # ✅ Feature Importance
    if hasattr(best_model, 'feature_importances_'):
        print("\n📊 Top 15 Most Important Features:")
        feature_names = list(tfidf.get_feature_names_out()) + list(features_df.columns)
        importances = best_model.feature_importances_
        indices = np.argsort(importances)[::-1][:15]
        for i, idx in enumerate(indices):
            print(f"  {i+1:2d}. {feature_names[idx]}: {importances[idx]:.4f}")
    
    # ============================================================
    # 7. حفظ النماذج
    # ============================================================
    
    print("\n💾 Saving models...")
    
    # ✅ إنشاء مجلد للنماذج
    models_dir = 'models'
    if not os.path.exists(models_dir):
        os.makedirs(models_dir)
    
    # ✅ حفظ النماذج
    joblib.dump(tfidf, f'{models_dir}/tfidf_vectorizer.joblib')
    joblib.dump(best_model, f'{models_dir}/model.joblib')
    joblib.dump(label_encoder, f'{models_dir}/level_label_encoder.joblib')
    joblib.dump(scaler, f'{models_dir}/scaler.joblib')
    
    # ✅ نسخ إلى المجلد الرئيسي للاستخدام في app.py
    joblib.dump(tfidf, 'tfidf_vectorizer.joblib')
    joblib.dump(best_model, 'model.joblib')
    joblib.dump(label_encoder, 'level_label_encoder.joblib')
    joblib.dump(scaler, 'scaler.joblib')
    
    print("\n✅ All models saved successfully!")
    print(f"📁 Location: {models_dir}/")
    print("📁 Also saved in root directory for app.py")
    
    # ✅ حفظ معلومات التدريب
    training_info = {
        'model_type': type(best_model).__name__,
        'accuracy': float(best_accuracy),
        'f1_score': float(best_f1),
        'cv_score': float(cv_scores.mean()),
        'samples': len(df),
        'features': X.shape[1],
        'classes': label_encoder.classes_.tolist(),
        'training_date': datetime.now().isoformat(),
    }
    
    with open(f'{models_dir}/training_info.json', 'w') as f:
        import json
        json.dump(training_info, f, indent=2)
    
    print("\n📊 Training Info Saved:")
    print(f"   Accuracy: {best_accuracy:.2%}")
    print(f"   Samples: {len(df)}")
    print(f"   Features: {X.shape[1]}")
    print(f"   Date: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    
    print("\n" + "=" * 80)
    print("   ✅ Training Complete!")
    print("   🚀 Model is ready for production!")
    print("=" * 80)
    
    return best_model, tfidf, label_encoder, scaler, best_accuracy

# ============================================================
# 8. تحديث النموذج (دالة رئيسية)
# ============================================================

def update_model():
    """الدالة الرئيسية لتحديث النموذج من بيانات المستخدمين"""
    
    print("\n" + "=" * 80)
    print("   🔄 ClearLoad Model Update Service")
    print("=" * 80)
    print(f"   📅 {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    
    # ✅ جلب البيانات
    df = fetch_user_data()
    
    if df is None or len(df) < 10:
        print("❌ Not enough data for training (need at least 10 samples)")
        return False
    
    # ✅ تدريب النموذج
    try:
        model, tfidf, label_encoder, scaler, accuracy = train_optimized_model(df)
        print(f"✅ Model updated successfully! New accuracy: {accuracy:.2%}")
        return True
    except Exception as e:
        print(f"❌ Training failed: {e}")
        return False

# ============================================================
# 9. تشغيل التحديث
# ============================================================

if __name__ == "__main__":
    update_model()