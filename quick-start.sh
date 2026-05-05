#!/bin/bash
# Quick Start Script for Bingo Game Full Stack

echo "╔════════════════════════════════════════════════════════════╗"
echo "║          Bingo Game - Full Stack Quick Start              ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# Check if we're in the right directory
if [ ! -f "SETUP_GUIDE.md" ]; then
    echo "❌ Error: Please run this script from the BingoGame root directory"
    exit 1
fi

# Function to start backend
start_backend() {
    echo "🚀 Starting Backend..."
    cd backend
    
    if [ ! -d "node_modules" ]; then
        echo "📦 Installing backend dependencies..."
        npm install
    fi
    
    if [ ! -f ".env" ]; then
        echo "⚠️  .env file not found!"
        echo "📋 Creating .env from template..."
        cp .env.example .env
        echo "✏️  Please edit backend/.env with your MongoDB URI"
        exit 1
    fi
    
    echo "✅ Starting development server..."
    npm run dev
}

# Function to start Flutter
start_flutter() {
    echo "🚀 Starting Flutter App..."
    cd app
    
    if [ ! -d "build" ]; then
        echo "📦 Getting Flutter dependencies..."
        flutter pub get
    fi
    
    # Check if backend is running
    if ! curl -s http://localhost:5000/health > /dev/null; then
        echo "⚠️  Backend not running on localhost:5000"
        echo "Please start backend first (run this script with 'backend' argument)"
        exit 1
    fi
    
    echo "✅ Launching Flutter app..."
    # Default to web, can be changed
    flutter run -d web --dart-define=API_BASE_URL=http://localhost:5000/api
}

# Function to start Web
start_web() {
    echo "🚀 Starting Web Frontend..."
    cd web
    
    if [ ! -d "node_modules" ]; then
        echo "📦 Installing web dependencies..."
        npm install
    fi
    
    echo "✅ Starting dev server..."
    npm run dev
}

# Function to show usage
show_usage() {
    echo "Usage: ./quick-start.sh [command]"
    echo ""
    echo "Commands:"
    echo "  backend    - Start Express backend"
    echo "  flutter    - Start Flutter app"
    echo "  web        - Start Web frontend"
    echo "  all        - Start all (requires multiple terminals)"
    echo "  help       - Show this help message"
    echo ""
    echo "Examples:"
    echo "  ./quick-start.sh backend"
    echo "  ./quick-start.sh flutter"
    echo "  ./quick-start.sh web"
    echo ""
    echo "For development, run in separate terminals:"
    echo "  Terminal 1: ./quick-start.sh backend"
    echo "  Terminal 2: ./quick-start.sh flutter"
    echo "  Terminal 3: ./quick-start.sh web"
}

# Main logic
case "${1:-help}" in
    backend)
        start_backend
        ;;
    flutter)
        start_flutter
        ;;
    web)
        start_web
        ;;
    all)
        echo "⚠️  To run all parts, please use separate terminals:"
        echo "  Terminal 1: ./quick-start.sh backend"
        echo "  Terminal 2: ./quick-start.sh flutter"
        echo "  Terminal 3: ./quick-start.sh web"
        exit 1
        ;;
    help)
        show_usage
        ;;
    *)
        echo "❌ Unknown command: $1"
        show_usage
        exit 1
        ;;
esac
