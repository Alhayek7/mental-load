# ============================================================
# 📄 app.py - النسخة النهائية مع faster-whisper
# ✅ تحليل النص + تحويل الصوت إلى نص
# ============================================================

from flask import Flask, request, jsonify
from flask_cors import CORS
import joblib
import numpy as np
import re
import os
import tempfile
import uuid
from faster_whisper import WhisperModel
from pydub import AudioSegment
import time
import warnings
warnings.filterwarnings('ignore')

app = Flask(__name__)
CORS(app)

# ============================================================
# 1. تحميل نموذج تحليل النص
# ============================================================

print("🔄 Loading AI Models...")
tfidf = joblib.load('tfidf_vectorizer.joblib')
model = joblib.load('model.joblib')
label_encoder = joblib.load('level_label_encoder.joblib')
print("✅ All models loaded successfully!")

# ============================================================
# 2. تحميل faster-whisper
# ============================================================

MODEL_SIZE = "base"  # ✅ "tiny", "base", "small", "medium", "large"
DEVICE = "cpu"       # ✅ "cpu" أو "cuda" (إذا كان لديك GPU)

print(f"\n🔄 Loading faster-whisper model ({MODEL_SIZE})...")
whisper_model = WhisperModel(MODEL_SIZE, device=DEVICE, compute_type="int8")
print(f"✅ faster-whisper model loaded successfully!")

# ============================================================
# 3. دوال معالجة النص (للتحليل)
# ============================================================

NEGATIVE_WORDS = [
    'tired', 'exhausted', 'overwhelmed', 'burnout', 'stressed',
    'headache', 'fatigue', 'drained', 'anxious', 'pressure',
    "can't focus", 'distracted', 'mental', 'heavy', 'fog'
]

POSITIVE_WORDS = [
    'productive', 'focused', 'great', 'energized', 'refreshed',
    'calm', 'clear', 'motivated', 'sharp', 'efficient'
]

def extract_features(text):
    """استخراج ميزات إضافية"""
    lower = text.lower()
    words = lower.split()
    return {
        'word_count': len(words),
        'char_count': len(text),
        'negative_count': sum(1 for w in NEGATIVE_WORDS if w in lower),
        'positive_count': sum(1 for w in POSITIVE_WORDS if w in lower),
        'exclamation_count': text.count('!'),
        'question_count': text.count('?'),
    }

def preprocess_text(text):
    """تطبيع النص"""
    text = text.lower()
    text = re.sub(r'[^\w\s]', '', text)
    text = re.sub(r'\d+', '', text)
    words = text.split()
    words = [w for w in words if len(w) > 2]
    return ' '.join(words)

# ============================================================
# 4. دوال معالجة الصوت (لـ faster-whisper)
# ============================================================

def convert_to_wav(input_path):
    """تحويل أي ملف صوتي إلى WAV (16kHz, Mono)"""
    try:
        audio = AudioSegment.from_file(input_path)
        audio = audio.set_channels(1).set_frame_rate(16000)
        
        wav_path = input_path.replace('.m4a', '.wav').replace('.mp3', '.wav')
        if wav_path == input_path:
            wav_path = input_path + '.wav'
        
        audio.export(wav_path, format="wav")
        return wav_path
    except Exception as e:
        print(f"❌ Error converting audio: {e}")
        return None

def transcribe_audio(audio_path):
    """تحويل الصوت إلى نص باستخدام faster-whisper"""
    try:
        if not audio_path.endswith('.wav'):
            audio_path = convert_to_wav(audio_path)
            if audio_path is None:
                return None, 0, 0
        
        print(f"🎤 Transcribing: {audio_path}")
        
        start_time = time.time()
        segments, info = whisper_model.transcribe(
            audio_path,
            beam_size=5,
            language="en",
            vad_filter=True,
            vad_parameters=dict(
                min_silence_duration_ms=500,
                threshold=0.5,
            ),
        )
        
        full_text = " ".join([seg.text for seg in segments])
        end_time = time.time()
        duration = end_time - start_time
        
        # ✅ حذف الملفات المؤقتة
        try:
            if audio_path.endswith('.wav') and audio_path != audio_path.replace('.wav', ''):
                os.remove(audio_path)
        except:
            pass
        
        return full_text, info.language_probability, duration
        
    except Exception as e:
        print(f"❌ Transcription error: {e}")
        return None, 0, 0

# ============================================================
# 5. Endpoints
# ============================================================

@app.route('/health', methods=['GET'])
def health():
    return jsonify({
        'status': 'healthy',
        'model': MODEL_SIZE,
        'device': DEVICE
    }), 200

@app.route('/analyze', methods=['POST'])
def analyze():
    """تحليل النص"""
    try:
        data = request.get_json()
        text = data.get('text', '')
        
        if not text or len(text.strip()) < 3:
            return jsonify({
                'score': 3,
                'confidence': 70,
                'recommendation': 'Please provide more details for better analysis.',
                'category': 'Moderate',
                'factors': 'Insufficient data for analysis.'
            }), 200
        
        processed = preprocess_text(text)
        X_text = tfidf.transform([processed]).toarray()
        features = extract_features(text)
        X_extra = np.array([[features['word_count'], features['char_count'],
                            features['negative_count'], features['positive_count'],
                            features['exclamation_count'], features['question_count']]])
        X = np.hstack([X_text, X_extra])
        
        pred = model.predict(X)[0]
        level = label_encoder.inverse_transform([pred])[0]
        proba = model.predict_proba(X)[0]
        confidence = max(proba) * 100
        
        score_map = {'Low': 2, 'Moderate': 3, 'High': 4, 'Critical': 5}
        score = score_map.get(level, 3)
        
        recommendations = {
            'Low': "🌟 Excellent! You're managing your cognitive load perfectly!",
            'Moderate': "📊 Moderate cognitive load. Consider a short break.",
            'High': "⚠️ High cognitive load. Take a 20-minute break.",
            'Critical': "🚨 Critical cognitive overload! Rest for 30+ minutes."
        }
        
        return jsonify({
            'score': score,
            'confidence': round(confidence, 2),
            'recommendation': recommendations.get(level, "Keep monitoring your cognitive load."),
            'category': level,
            'factors': 'AI model analysis with TF-IDF and Random Forest.',
            'details': {
                'word_count': len(text.split()),
                'sentiment': 'Positive' if score <= 2 else 'Needs Attention'
            }
        }), 200
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/transcribe', methods=['POST'])
def transcribe():
    """تحويل الصوت إلى نص باستخدام faster-whisper"""
    try:
        if 'audio' not in request.files:
            return jsonify({'error': 'No audio file provided'}), 400
        
        file = request.files['audio']
        if file.filename == '':
            return jsonify({'error': 'Empty filename'}), 400
        
        # ✅ حفظ الملف مؤقتاً
        temp_dir = tempfile.gettempdir()
        ext = os.path.splitext(file.filename)[1] or '.m4a'
        temp_path = os.path.join(temp_dir, f"audio_{uuid.uuid4().hex}{ext}")
        file.save(temp_path)
        
        print(f"📁 Saved audio to: {temp_path}")
        
        # ✅ تحويل الصوت إلى نص
        text, confidence, duration = transcribe_audio(temp_path)
        
        # ✅ حذف الملف المؤقت
        try:
            os.remove(temp_path)
        except:
            pass
        
        if text:
            # ✅ حساب الـ Score من النص (باستخدام النموذج الحالي)
            score_result = analyze_text(text)
            
            return jsonify({
                'success': True,
                'text': text,
                'confidence': confidence,
                'duration': duration,
                'score': score_result.get('score', 3),
                'word_count': len(text.split()),
            }), 200
        else:
            return jsonify({
                'success': False,
                'error': 'Failed to transcribe audio'
            }), 500
        
    except Exception as e:
        print(f"❌ Error: {e}")
        return jsonify({'error': str(e)}), 500

def analyze_text(text):
    """تحليل النص (دالة مساعدة)"""
    try:
        processed = preprocess_text(text)
        X_text = tfidf.transform([processed]).toarray()
        features = extract_features(text)
        X_extra = np.array([[features['word_count'], features['char_count'],
                            features['negative_count'], features['positive_count'],
                            features['exclamation_count'], features['question_count']]])
        X = np.hstack([X_text, X_extra])
        
        pred = model.predict(X)[0]
        level = label_encoder.inverse_transform([pred])[0]
        
        score_map = {'Low': 2, 'Moderate': 3, 'High': 4, 'Critical': 5}
        score = score_map.get(level, 3)
        
        return {'score': score, 'level': level}
    except:
        return {'score': 3, 'level': 'Moderate'}

# ============================================================
# 6. تشغيل الخادم
# ============================================================

if __name__ == '__main__':
    print("\n" + "=" * 60)
    print("   🚀 ClearLoad AI Server")
    print("   📍 Running on http://localhost:5000")
    print("   📊 Model: faster-whisper + TF-IDF + Random Forest")
    print("   📌 Endpoints:")
    print("   • POST /analyze     → Analyze text")
    print("   • POST /transcribe  → Convert audio to text")
    print("   • GET  /health      → Check server status")
    print("=" * 60)
    app.run(host='0.0.0.0', port=5000, debug=True)