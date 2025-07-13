@echo off
echo 🛑 Stopping Nexumi MongoDB Database...
echo.

REM Stop MongoDB services
docker-compose down

if %errorlevel% neq 0 (
    echo ❌ Failed to stop database services
    pause
    exit /b 1
)

echo.
echo ✅ Nexumi Database Stopped Successfully!
echo.
echo 💾 Your data is safely stored and will be available when you restart.
echo.
pause 