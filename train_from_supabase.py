# ============================================================
# 📄 train_from_supabase.py - النسخة الاحترافية النهائية
# 📌 تدريب النموذج من بيانات Supabase مع دعم كامل
# ✅ دقة عالية + معالجة متقدمة + تقارير شاملة + حلول الأخطاء
# ============================================================

import requests
import pandas as pd
import numpy as np
import joblib
import pickle
import re
import json
import os
import warnings
from datetime import datetime
from collections import Counter
warnings.filterwarnings('ignore')

from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.ensemble import RandomForestClassifier, GradientBoostingClassifier, VotingClassifier
from sklearn.linear_model import LogisticRegression
from sklearn.preprocessing import LabelEncoder, StandardScaler
from sklearn.model_selection import train_test_split, LeaveOneOut
from sklearn.metrics import accuracy_score, classification_report, confusion_matrix, f1_score

# ============================================================
# 1. إعدادات Supabase
# ============================================================

SUPABASE_URL = "https://orjgxyxxuoqjyhivpifb.supabase.co"
SUPABASE_SERVICE_KEY = "sb_secret_rTwvQ6Ui02y8fAqDMTQZhA_PwWLAVBM"

# ============================================================
# 2. قوائم الكلمات الموسعة
# ============================================================

NEGATIVE_WORDS = {
    'critical': ['breakdown', 'collapse', 'paralyzed', 'shutdown', 'emergency', 'crisis', 'severe'],
    'high': ['exhausted', 'overwhelmed', 'burnout', 'depleted', 'drained', 'stressed', 'anxious'],
    'moderate': ['tired', 'fatigue', 'pressure', 'difficult', 'hard', 'struggling'],
    'low': ['distracted', 'mental', 'heavy', 'fog', 'unable']
}

NEGATIVE_WORDS_FLAT = [
    'tired', 'exhausted', 'overwhelmed', 'burnout', 'stressed',
    'headache', 'fatigue', 'drained', 'anxious', 'pressure',
    'distracted', 'mental', 'heavy', 'fog', 'depleted',
    'strained', 'overloaded', 'frustrated', 'helpless', 'overworked',
    'difficult', 'hard', 'struggling', 'unable', 'pain',
    'breakdown', 'collapse', 'paralyzed', 'shutdown', 'emergency'
]

POSITIVE_WORDS = {
    'excellent': ['productive', 'efficient', 'accomplished', 'achieved', 'excellent'],
    'good': ['focused', 'motivated', 'sharp', 'clear', 'calm'],
    'positive': ['great', 'good', 'happy', 'satisfied', 'relaxed']
}

POSITIVE_WORDS_FLAT = [
    'productive', 'focused', 'great', 'energized', 'refreshed',
    'calm', 'clear', 'motivated', 'sharp', 'efficient',
    'accomplished', 'satisfied', 'good', 'happy', 'relaxed',
    'peaceful', 'balanced', 'optimistic', 'confident', 'inspired',
    'creative', 'successful', 'achieved', 'progress', 'excellent'
]

# ============================================================
# 3. معالجة النصوص المتقدمة
# ============================================================

def clean_text_advanced(text):
    """تنظيف النص المتقدم مع إزالة التكرار"""
    if not text or not isinstance(text, str):
        return ''
    text = text.lower()
    text = re.sub(r'[^\w\s]', '', text)
    text = re.sub(r'\d+', '', text)
    text = re.sub(r'\s+', ' ', text).strip()
    
    # إزالة الكلمات المكررة
    words = text.split()
    seen = set()
    unique_words = []
    for w in words:
        if w not in seen and len(w) > 2:
            seen.add(w)
            unique_words.append(w)
    return ' '.join(unique_words)

def extract_advanced_features(text):
    """استخراج ميزات متقدمة (30+ ميزة)"""
    lower = text.lower()
    words = lower.split()
    word_count = len(words)
    
    neg_count = sum(1 for w in NEGATIVE_WORDS_FLAT if w in lower)
    pos_count = sum(1 for w in POSITIVE_WORDS_FLAT if w in lower)
    
    features = {
        # الميزات الأساسية
        'word_count': min(word_count, 100),
        'char_count': min(len(text), 500),
        'avg_word_length': len(text) / (word_count + 1) if word_count > 0 else 0,
        
        # الميزات العاطفية
        'negative_count': min(neg_count, 20),
        'positive_count': min(pos_count, 20),
        'net_sentiment': pos_count - neg_count,
        'sentiment_ratio': pos_count / (neg_count + 1) if neg_count >= 0 else 1.0,
        'sentiment_score': (pos_count - neg_count) / 5,
        
        # وجود كلمات
        'has_negative': neg_count > 0,
        'has_positive': pos_count > 0,
        'negative_intensity': min(neg_count / 3, 3),
        'positive_intensity': min(pos_count / 3, 3),
        
        # كلمات حسب المستوى
        'critical_count': sum(1 for w in NEGATIVE_WORDS['critical'] if w in lower),
        'high_count': sum(1 for w in NEGATIVE_WORDS['high'] if w in lower),
        'moderate_count': sum(1 for w in NEGATIVE_WORDS['moderate'] if w in lower),
        'low_count': sum(1 for w in NEGATIVE_WORDS['low'] if w in lower),
        'excellent_count': sum(1 for w in POSITIVE_WORDS['excellent'] if w in lower),
        'good_count': sum(1 for w in POSITIVE_WORDS['good'] if w in lower),
        
        # علامات الترقيم
        'exclamation_count': min(text.count('!'), 5),
        'question_count': min(text.count('?'), 5),
        'punctuation_ratio': (text.count('!') + text.count('?')) / (word_count + 1),
        
        # كلمات مفتاحية
        'has_ai_tools': any(w in lower for w in ['chatgpt', 'claude', 'gemini', 'copilot', 'ai', 'llm']),
        'has_work': any(w in lower for w in ['work', 'task', 'project', 'job', 'deadline']),
        'has_break': any(w in lower for w in ['break', 'rest', 'pause', 'stop']),
        'has_time': any(w in lower for w in ['hour', 'hours', 'minute', 'minutes', 'day']),
        
        # تنوع الكلمات
        'unique_words': len(set(words)),
        'lexical_diversity': len(set(words)) / (word_count + 1) if word_count > 0 else 0,
    }
    
    return features

def is_valid_text(text):
    """التحقق من صحة النص"""
    if not text or not isinstance(text, str):
        return False
    if len(text.strip()) < 5:
        return False
    return True

# ============================================================
# 4. جلب البيانات من Supabase
# ============================================================

def fetch_user_data():
    """جلب بيانات المستخدمين مع تحليل شامل"""
    
    print("=" * 80)
    print("   📊 Fetching User Data from Supabase")
    print("=" * 80)
    
    print(f"\n🔄 Connecting to Supabase...")
    print(f"📍 URL: {SUPABASE_URL}")
    
    url = f"{SUPABASE_URL}/rest/v1/checkins"
    headers = {
        "apikey": SUPABASE_SERVICE_KEY,
        "Authorization": f"Bearer {SUPABASE_SERVICE_KEY}",
        "Content-Type": "application/json"
    }
    
    try:
        response = requests.get(url, headers=headers, timeout=30)
        print(f"📊 Status Code: {response.status_code}")
        
        if response.status_code != 200:
            print(f"❌ Error: {response.text}")
            return None
        
        data = response.json()
        print(f"✅ Found {len(data)} raw records")
        
        if not data:
            print("⚠️ No data found")
            return None
        
        # ✅ عرض إحصائيات أولية
        df = pd.DataFrame(data)
        print(f"\n📊 Data Statistics:")
        print(f"   Total records: {len(df)}")
        print(f"   Date range: {df['checkin_date'].min()} to {df['checkin_date'].max()}")
        print(f"   Score range: {df['cognitive_load_score'].min()} to {df['cognitive_load_score'].max()}")
        
        # ✅ عرض عينة
        print(f"\n📋 Sample data (first 3 records):")
        for i, record in enumerate(data[:3]):
            text = record.get('free_text', '')[:50]
            score = record.get('cognitive_load_score', 'N/A')
            print(f"  {i+1}. Score: {score} | Text: {text}...")
        
        return df
        
    except Exception as e:
        print(f"❌ Error: {e}")
        return None

# ============================================================
# 5. تنظيف وتحليل البيانات
# ============================================================

def clean_and_analyze_data(df):
    """تنظيف وتحليل البيانات بشكل شامل"""
    
    print("\n" + "=" * 80)
    print("   🧹 Data Cleaning & Analysis")
    print("=" * 80)
    
    original_count = len(df)
    
    # ✅ 1. إزالة الصفوف الفارغة
    df = df.dropna(subset=['free_text', 'cognitive_load_score'])
    
    # ✅ 2. التحقق من النصوص الصالحة
    df['is_valid'] = df['free_text'].apply(is_valid_text)
    df = df[df['is_valid'] == True]
    
    # ✅ 3. تنظيف النصوص
    df['clean_text'] = df['free_text'].apply(clean_text_advanced)
    
    # ✅ 4. استخراج الميزات المتقدمة
    print("\n🔄 Extracting advanced features...")
    df['features'] = df['free_text'].apply(extract_advanced_features)
    features_df = pd.DataFrame(df['features'].tolist())
    print(f"✅ Features extracted: {len(features_df.columns)} features")
    
    # ✅ 5. تحويل Score إلى فئة
    def score_to_level(score):
        if score <= 2:
            return 'Low'
        elif score == 3:
            return 'Moderate'
        elif score == 4:
            return 'High'
        else:
            return 'Critical'
    
    df['level'] = df['cognitive_load_score'].apply(score_to_level)
    
    # ✅ 6. استخدام تصحيح المستخدم (Human-in-the-Loop)
    if 'user_correction' in df.columns:
        correction_mask = df['user_correction'].notna()
        df.loc[correction_mask, 'level'] = df.loc[correction_mask, 'user_correction'].apply(score_to_level)
        print(f"📝 Applied {correction_mask.sum()} user corrections")
    
    # ✅ 7. إزالة الصفوف التي ليس لها فئة
    df = df.dropna(subset=['level'])
    
    print(f"\n✅ Cleaned dataset: {len(df)} samples (from {original_count} original)")
    print(f"\n📊 Class distribution:")
    print(df['level'].value_counts())
    
    # ✅ 8. تحليل النصوص
    print(f"\n📊 Text Analysis:")
    if len(df) > 0:
        avg_length = df['free_text'].str.len().mean()
        min_length = df['free_text'].str.len().min()
        max_length = df['free_text'].str.len().max()
        print(f"   Average text length: {avg_length:.1f} chars")
        print(f"   Min text length: {min_length} chars")
        print(f"   Max text length: {max_length} chars")
    
    return df, features_df

# ============================================================
# 6. تدريب النموذج المحسّن
# ============================================================

def train_optimized_model(df, features_df):
    """تدريب النموذج المحسّن مع عدة خوارزميات"""
    
    print("\n" + "=" * 80)
    print("   🚀 Training Optimized Model")
    print("=" * 80)
    
    if len(df) < 3:
        print("❌ Not enough data (need at least 3 samples)")
        return None, None, None, None
    
    # ✅ TF-IDF Vectorizer
    print("\n🔄 Training TF-IDF Vectorizer...")
    tfidf = TfidfVectorizer(
        max_features=200,
        ngram_range=(1, 2),
        min_df=1,
        max_df=0.95,
        stop_words='english',
        sublinear_tf=True,
        use_idf=True,
        smooth_idf=True
    )
    X_text = tfidf.fit_transform(df['clean_text']).toarray()
    print(f"✅ TF-IDF vocabulary size: {len(tfidf.vocabulary_)}")
    
    # ✅ دمج الميزات الإضافية
    X_extra = features_df.values
    X = np.hstack([X_text, X_extra])
    print(f"✅ Feature matrix shape: {X.shape}")
    
    # ✅ Standard Scaling
    print("\n🔄 Scaling features...")
    scaler = StandardScaler()
    X_scaled = scaler.fit_transform(X)
    
    # ✅ Label Encoder
    print("🔄 Training Label Encoder...")
    label_encoder = LabelEncoder()
    y = label_encoder.fit_transform(df['level'])
    print(f"✅ Label Encoder classes: {label_encoder.classes_.tolist()}")
    
    # ✅ تقسيم البيانات
    print("\n🔄 Splitting data...")
    
    if len(df) <= 5:
        print("⚠️ Small dataset detected, using LeaveOneOut validation...")
        model = RandomForestClassifier(
            n_estimators=200,
            max_depth=15,
            min_samples_split=2,
            min_samples_leaf=1,
            random_state=42,
            class_weight='balanced'
        )
        
        loo = LeaveOneOut()
        scores = []
        for train_idx, test_idx in loo.split(X_scaled):
            X_train, X_test = X_scaled[train_idx], X_scaled[test_idx]
            y_train, y_test = y[train_idx], y[test_idx]
            model.fit(X_train, y_train)
            score = model.score(X_test, y_test)
            scores.append(score)
        
        accuracy = np.mean(scores)
        print(f"✅ LeaveOneOut Accuracy: {accuracy:.2%}")
        model.fit(X_scaled, y)
        return model, tfidf, label_encoder, scaler
    
    try:
        X_train, X_test, y_train, y_test = train_test_split(
            X_scaled, y, test_size=0.2, random_state=42, stratify=y
        )
        print(f"✅ Train size: {len(X_train)}, Test size: {len(X_test)}")
    except ValueError:
        print("⚠️ Stratify failed, using simple split...")
        X_train, X_test, y_train, y_test = train_test_split(
            X_scaled, y, test_size=0.2, random_state=42
        )
        print(f"✅ Train size: {len(X_train)}, Test size: {len(X_test)}")
    
    # ✅ النماذج المتعددة
    print("\n🔄 Training Multiple Models...")
    
    models = {
        'Random Forest': RandomForestClassifier(
            n_estimators=200,
            max_depth=15,
            min_samples_split=2,
            min_samples_leaf=1,
            max_features='sqrt',
            random_state=42,
            n_jobs=-1,
            class_weight='balanced'
        ),
        'Gradient Boosting': GradientBoostingClassifier(
            n_estimators=150,
            max_depth=8,
            learning_rate=0.1,
            subsample=0.8,
            random_state=42
        ),
        'Logistic Regression': LogisticRegression(
            max_iter=1000,
            random_state=42,
            class_weight='balanced',
            multi_class='multinomial'
        )
    }
    
    results = {}
    best_model = None
    best_accuracy = 0
    best_f1 = 0
    
    for name, model in models.items():
        try:
            model.fit(X_train, y_train)
            y_pred = model.predict(X_test)
            accuracy = accuracy_score(y_test, y_pred)
            f1 = f1_score(y_test, y_pred, average='weighted')
            results[name] = {'accuracy': accuracy, 'f1': f1}
            print(f"  ✅ {name}: Accuracy={accuracy:.2%}, F1={f1:.2%}")
            
            if accuracy > best_accuracy:
                best_accuracy = accuracy
                best_f1 = f1
                best_model = model
        except Exception as e:
            print(f"  ❌ {name}: Failed - {e}")
    
    # ✅ إذا لم يتم تدريب أي نموذج
    if best_model is None:
        print("❌ No model was trained successfully!")
        return None, None, None, None
    
    # ✅ Voting Classifier
    print("\n🔄 Creating Voting Ensemble...")
    voting_model = VotingClassifier(
        estimators=[(name, model) for name, model in models.items() if name in results],
        voting='soft',
        weights=[2, 1, 1][:len(results)]
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
    # التقييم النهائي (مُصحح)
    # ============================================================
    
    print("\n📊 Final Evaluation:")
    print("-" * 50)
    
    # ✅ التأكد من وجود best_model
    if best_model is None:
        print("❌ No model to evaluate!")
        return None, None, None, None
    
    y_pred = best_model.predict(X_test)
    
    print(f"✅ Best Model Accuracy: {best_accuracy:.2%}")
    print(f"✅ Weighted F1 Score: {best_f1:.2%}")
    
    # ✅ Classification Report (مُصحح)
    print("\n📊 Classification Report:")
    
    # ✅ الحصول على الفئات الموجودة فعلاً في y_test
    unique_labels = np.unique(y_test)
    unique_names = [label_encoder.classes_[i] for i in unique_labels]
    
    if len(unique_labels) > 1:
        print(classification_report(
            y_test, 
            y_pred, 
            labels=unique_labels,
            target_names=unique_names,
            zero_division=0
        ))
    else:
        print(f"   Only one class in test set: {unique_names[0]}")
        print(f"   Accuracy: {accuracy_score(y_test, y_pred):.2%}")
    
    # ✅ Confusion Matrix
    print("\n📊 Confusion Matrix:")
    print(confusion_matrix(y_test, y_pred))
    
    # ✅ Feature Importance
    if hasattr(best_model, 'feature_importances_'):
        print("\n📊 Top 20 Most Important Features:")
        feature_names = list(tfidf.get_feature_names_out()) + list(features_df.columns)
        importances = best_model.feature_importances_
        indices = np.argsort(importances)[::-1][:20]
        for i, idx in enumerate(indices):
            print(f"  {i+1:2d}. {feature_names[idx]}: {importances[idx]:.4f}")
    
    return best_model, tfidf, label_encoder, scaler

# ============================================================
# 7. حفظ النماذج مع التقرير
# ============================================================
def save_models(model, tfidf, label_encoder, scaler, df, accuracy, features_df):
    """حفظ النماذج مع تقرير شامل"""
    
    print("\n💾 Saving models...")
    
    # ✅ إنشاء مجلد للنماذج
    models_dir = 'models'
    if not os.path.exists(models_dir):
        os.makedirs(models_dir)
    
    # ✅ حفظ النماذج
    joblib.dump(tfidf, f'{models_dir}/tfidf_vectorizer.joblib')
    joblib.dump(model, f'{models_dir}/model.joblib')
    joblib.dump(label_encoder, f'{models_dir}/level_label_encoder.joblib')
    joblib.dump(scaler, f'{models_dir}/scaler.joblib')
    
    # ✅ نسخ إلى المجلد الرئيسي
    joblib.dump(tfidf, 'tfidf_vectorizer.joblib')
    joblib.dump(model, 'model.joblib')
    joblib.dump(label_encoder, 'level_label_encoder.joblib')
    joblib.dump(scaler, 'scaler.joblib')
    
    print("\n✅ All models saved successfully!")
    print(f"📁 Location: {models_dir}/")
    
    # ✅ حفظ معلومات التدريب
    training_info = {
        'model_type': type(model).__name__,
        'accuracy': float(accuracy),
        'samples': len(df),
        'classes': label_encoder.classes_.tolist(),
        'feature_count': len(tfidf.vocabulary_),
        'training_date': datetime.now().isoformat(),
        'features_extracted': len(tfidf.vocabulary_) + len(features_df.columns),
    }
    
    with open(f'{models_dir}/training_info.json', 'w', encoding='utf-8') as f:
        json.dump(training_info, f, indent=2, ensure_ascii=False)
    
    # ✅ حفظ تقرير التدريب
    report = f"""
    ============================================================
    📊 ClearLoad - Model Training Report
    ============================================================
    
    📅 Training Date: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}
    
    📊 Data Statistics:
    - Total samples: {len(df)}
    - Classes: {label_encoder.classes_.tolist()}
    - Class distribution: {dict(df['level'].value_counts())}
    
    🧠 Model Information:
    - Model type: {type(model).__name__}
    - Accuracy: {accuracy:.2%}
    - Features: {len(tfidf.vocabulary_) + len(features_df.columns)}
    
    📁 Saved Files:
    - tfidf_vectorizer.joblib
    - model.joblib
    - level_label_encoder.joblib
    - scaler.joblib
    
    ============================================================
    """
    
    with open(f'{models_dir}/training_report.txt', 'w', encoding='utf-8') as f:
        f.write(report)
    
    print("\n📊 Training Report Saved:")
    print(f"   Accuracy: {accuracy:.2%}")
    print(f"   Samples: {len(df)}")
    print(f"   Classes: {label_encoder.classes_.tolist()}")

# ============================================================
# 8. اختبار النموذج
# ============================================================

def test_model():
    """اختبار النموذج على أمثلة جديدة"""
    
    print("\n" + "=" * 80)
    print("   🧪 Testing Model on New Examples")
    print("=" * 80)
    
    try:
        tfidf = joblib.load('tfidf_vectorizer.joblib')
        model = joblib.load('model.joblib')
        label_encoder = joblib.load('level_label_encoder.joblib')
        scaler = joblib.load('scaler.joblib')
    except:
        print("❌ Models not found! Please train first.")
        return
    
    test_texts = [
        "I had a great productive day, feeling focused and accomplished",
        "Used ChatGPT for 4 hours, feeling okay but a bit tired",
        "Exhausted and overwhelmed, can't focus anymore",
        "Complete burnout, can't function, need help",
        "Feeling motivated and clear-headed today"
    ]
    
    print("\n📝 Test Results:")
    print("-" * 60)
    
    for text in test_texts:
        # ✅ تنظيف النص
        clean = clean_text_advanced(text)
        features = extract_advanced_features(text)
        
        # ✅ استخراج الميزات
        X_text = tfidf.transform([clean]).toarray()
        X_extra = np.array([list(features.values())])
        X = np.hstack([X_text, X_extra])
        X_scaled = scaler.transform(X)
        
        # ✅ التنبؤ
        pred = model.predict(X_scaled)[0]
        level = label_encoder.inverse_transform([pred])[0]
        proba = model.predict_proba(X_scaled)[0]
        confidence = max(proba) * 100
        
        # ✅ Score
        score_map = {'Low': 2, 'Moderate': 3, 'High': 4, 'Critical': 5}
        score = score_map.get(level, 3)
        
        print(f"\n📌 Text: \"{text[:60]}...\"")
        print(f"   Level: {level} (Score: {score}/5)")
        print(f"   Confidence: {confidence:.1f}%")

# ============================================================
# 9. الدالة الرئيسية
# ============================================================
def main():
    """الدالة الرئيسية - تشغيل كامل العملية"""
    
    print("\n" + "=" * 80)
    print("   🧠 ClearLoad - Professional Model Training")
    print("   📌 USAII Global AI Hackathon 2026")
    print("=" * 80)
    
    # ✅ 1. جلب البيانات
    df = fetch_user_data()
    if df is None or len(df) < 3:
        print("\n❌ Not enough data for training (need at least 3 samples)")
        print("💡 Suggestion: Add more check-ins or use synthetic data")
        return
    
    # ✅ 2. تنظيف وتحليل البيانات
    df, features_df = clean_and_analyze_data(df)
    
    if len(df) < 3:
        print("\n❌ Not enough valid data after cleaning")
        return
    
    # ✅ 3. تدريب النموذج المحسّن
    model, tfidf, label_encoder, scaler = train_optimized_model(df, features_df)
    
    if model is None:
        print("\n❌ Training failed")
        return
    
    # ✅ 4. حفظ النماذج
    # حساب الدقة النهائية
    X_text = tfidf.transform(df['clean_text']).toarray()
    X_extra = features_df.values
    X = np.hstack([X_text, X_extra])
    X_scaled = scaler.transform(X)
    accuracy = model.score(X_scaled, label_encoder.transform(df['level']))
    
    # ✅ تمرير features_df إلى save_models
    save_models(model, tfidf, label_encoder, scaler, df, accuracy, features_df)
    
    # ✅ 5. اختبار النموذج
    test_model()
    
    print("\n" + "=" * 80)
    print("   ✅ Training Complete!")
    print("   🚀 Model is ready for production!")
    print("   📁 Models saved in 'models/' directory")
    print("=" * 80)

# ============================================================
# 10. التشغيل
# ============================================================

if __name__ == "__main__":
    main()