@echo off
REM Quick Start Script for Bingo Game Full Stack (Windows)
setlocal enabledelayedexpansion

echo ╔════════════════════════════════════════════════════════════╗
echo ║          Bingo Game - Full Stack Quick Start              ║
echo ╚════════════════════════════════════════════════════════════╝
echo.

REM Check if we're in the right directory
if not exist "SETUP_GUIDE.md" (
    echo ❌ Error: Please run this script from the BingoGame root directory
    exit /b 1
)

setlocal
set "command=%1"
if "!command!"=="" set "command=help"

goto !command!

:backend
echo 🚀 Starting Backend...
cd backend

if not exist "node_modules" (
    echo 📦 Installing backend dependencies...
    call npm install
)

if not exist ".env" (
    echo ⚠️  .env file not found!
    echo 📋 Creating .env from template...
    copy .env.example .env
    echo ✏️  Please edit backend\.env with your MongoDB URI
    exit /b 1
)

echo ✅ Starting development server...
call npm run dev
exit /b 0

:flutter
echo 🚀 Starting Flutter App...
cd app

if not exist "build" (
    echo 📦 Getting Flutter dependencies...
    call flutter pub get
)

REM Simple check if backend is running (may not work on all Windows)
for /f %%i in ('powershell -NoProfile -Command "try { $null = curl -m 1 http://localhost:5000/health -ErrorAction Stop; Write-Output 'ok' } catch { Write-Output 'error' }"') do set "backend_status=%%i"

if not "!backend_status!"=="ok" (
    echo ⚠️  Backend not running on localhost:5000
    echo Please start backend first
    exit /b 1
)

echo ✅ Launching Flutter app...
call flutter run -d web --dart-define=API_BASE_URL=http://localhost:5000/api
exit /b 0

:web
echo 🚀 Starting Web Frontend...
cd web

if not exist "node_modules" (
    echo 📦 Installing web dependencies...
    call npm install
)

echo ✅ Starting dev server...
call npm run dev
exit /b 0

:all
echo ⚠️  To run all parts, please use separate command prompts:
echo   Terminal 1: quick-start.bat backend
echo   Terminal 2: quick-start.bat flutter
echo   Terminal 3: quick-start.bat web
exit /b 1

:help
echo Usage: quick-start.bat [command]
echo.
echo Commands:
echo   backend    - Start Express backend
echo   flutter    - Start Flutter app
echo   web        - Start Web frontend
echo   all        - Show instructions for running all
echo   help       - Show this help message
echo.
echo Examples:
echo   quick-start.bat backend
echo   quick-start.bat flutter
echo   quick-start.bat web
echo.
echo For development, run in separate command prompts:
echo   Terminal 1: quick-start.bat backend
echo   Terminal 2: quick-start.bat flutter
echo   Terminal 3: quick-start.bat web
exit /b 0

:unknown
echo ❌ Unknown command: %command%
call :help
exit /b 1
