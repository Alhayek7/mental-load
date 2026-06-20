# ============================================================
# 📄 scheduler.py - جدولة تحديث النموذج التلقائي
# 📌 ClearLoad Auto Model Updater
# ============================================================

import schedule
import time
from datetime import datetime
from train_from_supabase import update_model
import logging

# ✅ إعدادات التسجيل
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('model_update.log'),
        logging.StreamHandler()
    ]
)

def update_job():
    """وظيفة التحديث"""
    logging.info("🔄 Starting scheduled model update...")
    try:
        success = update_model()
        if success:
            logging.info("✅ Model updated successfully!")
        else:
            logging.warning("⚠️ Model update failed")
    except Exception as e:
        logging.error(f"❌ Error in update job: {e}")

def start_scheduler():
    """بدء جدولة التحديثات"""
    
    logging.info("=" * 60)
    logging.info("   🚀 ClearLoad Model Scheduler Started")
    logging.info("=" * 60)
    
    # ✅ تحديث فوري عند التشغيل
    logging.info("📊 Running initial update...")
    update_job()
    
    # ✅ جدولة التحديثات
    schedule.every().day.at("00:00").do(update_job)  # يومياً عند منتصف الليل
    schedule.every().sunday.at("00:00").do(update_job)  # أسبوعياً (أيضاً)
    
    logging.info("📅 Schedule set:")
    logging.info("   • Daily: 00:00")
    logging.info("   • Weekly: Sunday 00:00")
    
    # ✅ تشغيل الجدولة
    while True:
        schedule.run_pending()
        time.sleep(60)  # ✅ التحقق كل دقيقة

if __name__ == "__main__":
    start_scheduler()