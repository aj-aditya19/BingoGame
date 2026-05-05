# 🎮 Bingo Game - Quick Reference

## 🚀 Quick Start (5 minutes)

### Windows PowerShell

```powershell
# Terminal 1: Backend
cd backend
npm install
cp .env.example .env
# Edit .env with MongoDB URI
npm run dev
# Runs on http://localhost:5000

# Terminal 2: Flutter App
cd app
flutter pub get
flutter run -d web --dart-define=API_BASE_URL=http://localhost:5000/api

# Terminal 3: Web Frontend (optional)
cd web
npm install
npm run dev
# Runs on http://localhost:5173
```

### macOS/Linux Bash

```bash
# Use quick-start.sh
./quick-start.sh backend
./quick-start.sh flutter
./quick-start.sh web
```

## 📱 Platform-Specific URLs

### Android Emulator

```
API_BASE_URL=http://10.0.2.2:5000/api
SOCKET_URL=http://10.0.2.2:5000
```

### iOS Simulator

```
API_BASE_URL=http://127.0.0.1:5000/api
SOCKET_URL=http://127.0.0.1:5000
```

### Physical Device

```
API_BASE_URL=http://YOUR_COMPUTER_IP:5000/api
SOCKET_URL=http://YOUR_COMPUTER_IP:5000
```

### Web (Browser)

```
API_BASE_URL=http://localhost:5000/api
SOCKET_URL=http://localhost:5000
```

## 🔌 Available Services

| Service      | URL                         | Status                 |
| ------------ | --------------------------- | ---------------------- |
| Backend API  | `http://localhost:5000/api` | Check `/` or `/health` |
| Socket.io    | `ws://localhost:5000`       | Auto-reconnect enabled |
| Web Frontend | `http://localhost:5173`     | Vite dev server        |
| MongoDB      | From `.env`                 | Connection required    |

## 📝 Key Files

```
BingoGame/
├── backend/
│   ├── .env                    ← EDIT WITH YOUR SECRETS
│   ├── src/server.js           ← Express server
│   ├── src/routes/auth.route.js
│   ├── src/routes/game.route.js
│   ├── src/config/socket.js
│   └── FLUTTER_SETUP.md        ← API documentation
├── app/
│   ├── lib/services/auth_service.dart
│   ├── lib/services/game_service.dart
│   ├── lib/services/socket_service.dart
│   └── BACKEND_INTEGRATION.md  ← Flutter integration docs
├── web/
│   └── src/services/          ← React API calls
├── SETUP_GUIDE.md             ← Full setup instructions
├── BACKEND_SUMMARY.md         ← Quick overview
└── quick-start.bat/.sh        ← Start scripts
```

## 🔐 Authentication

### Get JWT Token (for Mobile)

```bash
curl -X POST http://localhost:5000/api/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "password": "password",
    "returnToken": true
  }'
```

Response:

```json
{
  "success": true,
  "user": {
    "_id": "user_id",
    "name": "User Name",
    "email": "user@example.com"
  },
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

### Use Token in Requests

```bash
curl -H "Authorization: Bearer YOUR_TOKEN" \
  http://localhost:5000/api/verify-token
```

## 🎮 Game API

### Create Room

```bash
curl -X POST http://localhost:5000/api/game/room/create \
  -H "Content-Type: application/json"

# Response: { "success": true, "roomId": "abc1234" }
```

### Join Room

```bash
curl -X POST http://localhost:5000/api/game/room/join \
  -H "Content-Type: application/json" \
  -d '{"roomId": "abc1234"}'

# Response: { "success": true }
```

## 🔌 Socket Events

### Emit (Client → Server)

```dart
// Join room
SocketService.socket.emit('join-room', {
  'roomId': 'abc1234',
  'user': {'_id': 'user1', 'name': 'Player'}
});

// Start game
SocketService.socket.emit('start-game', {'roomId': 'abc1234'});

// Select number
SocketService.socket.emit('game:select-number', {
  'roomId': 'abc1234',
  'number': 5,
  'userId': 'user1'
});

// Win
SocketService.socket.emit('game:win', {
  'roomId': 'abc1234',
  'userId': 'user1'
});
```

### Listen (Server → Client)

```dart
// Players joined
SocketService.socket.on('room-joined', (players) { });

// Game started
SocketService.socket.on('game-start', (data) { });

// Number selected by opponent
SocketService.socket.on('game:update', (data) { });

// Your turn
SocketService.socket.on('game:turn', (data) { });

// Game ended
SocketService.socket.on('game:win', (winner) { });
```

## 📊 Database Schema

### User Model

```javascript
{
  _id: ObjectId,
  name: String,
  email: String (unique),
  password: String,
  provider: String (local/google),
  gamesPlayed: Number,
  win: Number,
  loss: Number,
  draw: Number,
  lastLogin: Date,
  createdAt: Date,
  updatedAt: Date
}
```

## 🛠️ Useful Commands

```bash
# Backend
npm install              # Install dependencies
npm run dev             # Dev with hot-reload
npm run start           # Production

# Flutter
flutter pub get         # Get dependencies
flutter run             # Run on device/emulator
flutter run -d web      # Run on web
flutter build apk       # Build APK for Play Store
flutter build ipa       # Build IPA for App Store
flutter build web       # Build web

# Web (React)
npm install             # Install dependencies
npm run dev             # Dev server
npm run build           # Production build
npm run preview         # Preview production

# Testing
curl http://localhost:5000              # Check if backend running
curl http://localhost:5000/health       # Health check
curl http://localhost:5173             # Check web frontend
```

## ⚠️ Troubleshooting

| Issue                              | Solution                                                    |
| ---------------------------------- | ----------------------------------------------------------- |
| Backend won't start                | Check `.env` exists with `MONGODB_URI`                      |
| MongoDB connection fails           | Verify IP whitelist in MongoDB Atlas, check credentials     |
| Flutter can't connect to localhost | Use `10.0.2.2` on Android emulator instead                  |
| CORS errors                        | Verify origin in backend `CORS_ORIGINS` env var             |
| Socket disconnects                 | Check network, verify WebSocket not blocked                 |
| Token invalid                      | Check `JWT_SECRET` same in all instances, token not expired |

## 🔑 Environment Variables

### Backend (.env)

```
MONGODB_URI=mongodb+srv://user:pass@cluster.mongodb.net/bingo
PORT=5000
NODE_ENV=development
SESSION_SECRET=random-string-here
JWT_SECRET=another-random-string-here
CORS_ORIGINS=http://localhost:5173,http://localhost:3000
```

### Flutter (dart-define)

```
--dart-define=API_BASE_URL=http://localhost:5000/api
--dart-define=SOCKET_URL=http://localhost:5000
```

## 📱 Build Commands

### Android

```bash
# Development
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:5000/api

# Release APK
flutter build apk --release \
  --dart-define=API_BASE_URL=https://your-backend.com/api
```

### iOS

```bash
# Development
flutter run --dart-define=API_BASE_URL=http://127.0.0.1:5000/api

# Release IPA
flutter build ipa --release \
  --dart-define=API_BASE_URL=https://your-backend.com/api
```

### Web

```bash
# Development
flutter run -d web --dart-define=API_BASE_URL=http://localhost:5000/api

# Production
flutter build web --dart-define=API_BASE_URL=https://your-backend.com/api
```

## 🚀 Production Deployment

### Backend (Render.com)

1. Push to GitHub
2. Connect repo to Render
3. Add env vars from `.env`
4. Deploy

### Flutter App

- Android: Google Play Store
- iOS: Apple App Store
- Web: Firebase Hosting / Netlify / Vercel

## 📚 Documentation

| Doc                          | Purpose                          |
| ---------------------------- | -------------------------------- |
| `SETUP_GUIDE.md`             | Complete setup for all platforms |
| `BACKEND_SUMMARY.md`         | Backend overview                 |
| `backend/FLUTTER_SETUP.md`   | Backend API reference            |
| `app/BACKEND_INTEGRATION.md` | Flutter integration guide        |

## ✅ Checklist

- [ ] Backend running: `npm run dev` in `backend/`
- [ ] `.env` created with `MONGODB_URI`
- [ ] Flutter pub get: `flutter pub get` in `app/`
- [ ] Can login successfully
- [ ] Can create room
- [ ] Socket connection works
- [ ] Game events flowing in real-time

---

**Quick Links**:

- [Full Setup](SETUP_GUIDE.md)
- [Backend API](backend/FLUTTER_SETUP.md)
- [Flutter Integration](app/BACKEND_INTEGRATION.md)
- [Backend Summary](BACKEND_SUMMARY.md)
