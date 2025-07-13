@echo off
echo 🎮 Starting Nexumi MongoDB Database...
echo.

REM Check if Docker is running
docker version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Docker is not running or not installed!
    echo Please install Docker Desktop: https://www.docker.com/products/docker-desktop
    pause
    exit /b 1
)

echo ✅ Docker is running
echo.

REM Start MongoDB services
echo 🚀 Starting MongoDB and web interface...
docker-compose up -d

if %errorlevel% neq 0 (
    echo ❌ Failed to start database services
    pause
    exit /b 1
)

echo.
echo 🎉 Nexumi Database Started Successfully!
echo.
echo 📊 Services Running:
echo    💾 MongoDB:     mongodb://localhost:27017
echo    🌐 Web UI:      http://localhost:8081
echo    🗄️  Database:    nexumi_game
echo    👤 Username:    admin
echo    🔑 Password:    nexumi123
echo.
echo 💡 Tips:
echo    - Use the Web UI to browse your database
echo    - Your game will automatically connect to MongoDB
echo    - Run 'stop-database.bat' to stop the database
echo.
echo ✨ Ready for epic adventures! Open Godot and run your game.
echo.
pause 