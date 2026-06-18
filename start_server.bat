@echo off
echo ====================================
echo 🚀 Starting ClearLoad AI Server
echo ====================================
echo.

cd /d "%~dp0"

echo 📦 Installing requirements...
pip install -r requirements.txt

echo.
echo 🔥 Starting Flask server...
python app.py

pause