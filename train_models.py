# ============================================================
# 📄 train_models.py - إعادة تدريب النماذج من الصفر
# ============================================================

import numpy as np
import pandas as pd
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.preprocessing import LabelEncoder, OrdinalEncoder
import joblib
import pickle

print('🔄 Starting model training...')

# ============================================================
# 1. بيانات التدريب
# ============================================================

training_data = [
    # إرهاق عالٍ (High)
    {"text": "I used ChatGPT for 4 hours straight today. I have a headache and can't focus at all. I feel completely exhausted and overwhelmed.", "label": "High"},
    {"text": "Working with multiple AI tools simultaneously is draining me mentally. I can't think clearly anymore.", "label": "High"},
    {"text": "This is brutal. I've been using AI for 6 hours nonstop and my brain feels fried.", "label": "High"},
    {"text": "I'm so tired after using AI tools all day. My mind is foggy and I can't concentrate.", "label": "High"},
    {"text": "The cognitive load today was overwhelming. I feel completely drained and exhausted.", "label": "High"},
    {"text": "I can't stop using AI tools even though I'm exhausted. My head is pounding.", "label": "High"},
    {"text": "After 5 hours of ChatGPT and Claude, I feel mentally drained and can't think straight.", "label": "High"},
    
    # إرهاق متوسط (Moderate)
    {"text": "I used ChatGPT and Claude for about 3 hours today. Feeling somewhat tired but manageable.", "label": "Moderate"},
    {"text": "Moderate cognitive load today. Used AI for research and writing. Need a short break.", "label": "Moderate"},
    {"text": "Balanced day with AI tools. Switched between tasks and took breaks.", "label": "Moderate"},
    {"text": "Felt some fatigue after 3 hours of AI usage. Took a break and felt better.", "label": "Moderate"},
    {"text": "Mixed day. Some moments of high focus, some moments of fatigue.", "label": "Moderate"},
    {"text": "Used AI for 2 hours in the morning and 2 in the afternoon. Felt okay overall.", "label": "Moderate"},
    
    # إرهاق منخفض (Low)
    {"text": "Great day! Used AI tools productively without feeling overwhelmed. Took regular breaks.", "label": "Low"},
    {"text": "Felt energized and focused today. AI tools helped me work efficiently.", "label": "Low"},
    {"text": "Productive day with AI. Managed to finish all tasks without mental strain.", "label": "Low"},
    {"text": "Good balance today. Used AI for specific tasks and felt in control.", "label": "Low"},
    {"text": "Excellent day! AI tools enhanced my productivity without causing fatigue.", "label": "Low"},
    {"text": "I used ChatGPT for 1 hour and felt great. Very productive session.", "label": "Low"},
]

# ============================================================
# 2. إعداد البيانات
# ============================================================

texts = [item['text'] for item in training_data]
labels = [item['label'] for item in training_data]

print(f'📊 Training data: {len(texts)} samples')

# ============================================================
# 3. تدريب النماذج
# ============================================================

# TF-IDF Vectorizer
print('🔄 Training TF-IDF Vectorizer...')
tfidf = TfidfVectorizer(
    max_features=100,
    stop_words='english',
    ngram_range=(1, 2)
)
tfidf.fit(texts)
print(f'✅ TF-IDF vocabulary size: {len(tfidf.vocabulary_)}')

# Label Encoder
print('🔄 Training Label Encoder...')
label_encoder = LabelEncoder()
label_encoder.fit(labels)
print(f'✅ Label Encoder classes: {label_encoder.classes_}')

# Ordinal Encoder
print('🔄 Training Ordinal Encoder...')
hours_data = pd.DataFrame({
    'hours': ['1-3', '3-5', '5-7', '7+']
})
ordinal_encoder = OrdinalEncoder(categories=[['1-3', '3-5', '5-7', '7+']])
ordinal_encoder.fit(hours_data)
print(f'✅ Ordinal Encoder categories: {ordinal_encoder.categories_}')

# ============================================================
# 4. حفظ النماذج
# ============================================================

print('💾 Saving models...')

# حفظ باستخدام joblib
joblib.dump(tfidf, 'tfidf_vectorizer.joblib')
joblib.dump(label_encoder, 'level_label_encoder.joblib')
joblib.dump(ordinal_encoder, 'hours_ordinal_encoder.joblib')

# حفظ باستخدام pickle (نسخة احتياطية)
with open('tfidf_vectorizer.pkl', 'wb') as f:
    pickle.dump(tfidf, f, protocol=pickle.HIGHEST_PROTOCOL)

with open('level_label_encoder.pkl', 'wb') as f:
    pickle.dump(label_encoder, f, protocol=pickle.HIGHEST_PROTOCOL)

with open('hours_ordinal_encoder.pkl', 'wb') as f:
    pickle.dump(ordinal_encoder, f, protocol=pickle.HIGHEST_PROTOCOL)

print('✅ Models saved successfully!')
print('''
╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║   ✅ Training Complete!                                     ║
║                                                              ║
║   📁 Files created:                                         ║
║   • tfidf_vectorizer.joblib                                 ║
║   • level_label_encoder.joblib                              ║
║   • hours_ordinal_encoder.joblib                            ║
║   • tfidf_vectorizer.pkl (backup)                           ║
║   • level_label_encoder.pkl (backup)                        ║
║   • hours_ordinal_encoder.pkl (backup)                      ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝
''')