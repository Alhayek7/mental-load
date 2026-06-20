# ============================================================
# 📄 train_from_backup.py - تدريب من نسخة احتياطية
# ============================================================

import pandas as pd
import joblib
import json
from datetime import datetime

def load_backup_data(file_path='training_data_backup.csv'):
    """تحميل بيانات التدريب من ملف CSV"""
    try:
        df = pd.read_csv(file_path)
        print(f"✅ Loaded {len(df)} samples from {file_path}")
        return df
    except FileNotFoundError:
        print(f"❌ File not found: {file_path}")
        return None

def save_training_data(df, file_path='training_data_backup.csv'):
    """حفظ بيانات التدريب كنسخة احتياطية"""
    df.to_csv(file_path, index=False)
    print(f"✅ Saved {len(df)} samples to {file_path}")
    return True

def train_from_backup():
    """تدريب النموذج من النسخة الاحتياطية"""
    from train_from_supabase import train_optimized_model
    
    df = load_backup_data()
    if df is None:
        return False
    
    # ✅ إضافة معلومات إضافية
    print(f"📊 Data shape: {df.shape}")
    print(f"📊 Classes: {df['level'].value_counts().to_dict()}")
    
    # ✅ تدريب النموذج
    model, tfidf, label_encoder, scaler, accuracy = train_optimized_model(df)
    
    print(f"✅ Model trained with accuracy: {accuracy:.2%}")
    return True

if __name__ == "__main__":
    train_from_backup()