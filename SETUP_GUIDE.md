# 🎮 Bingo Game - Full Stack Setup Guide

## Project Structure

```
BingoGame/
├── backend/                    # Node.js/Express API Server
│   ├── src/
│   │   ├── config/            # DB, Socket, Firebase config
│   │   ├── database/          # MongoDB models
│   │   ├── routes/            # API routes
│   │   └── server.js          # Entry point
│   ├── package.json
│   ├── .env.example
│   └── FLUTTER_SETUP.md
├── app/                        # Flutter Mobile App
│   ├── lib/
│   │   ├── services/          # Auth, Game, Socket services
│   │   └── main.dart
│   ├── pubspec.yaml
│   ├── android/               # Android configuration
│   ├── ios/                   # iOS configuration
│   └── BACKEND_INTEGRATION.md
├── web/                        # React Frontend
│   ├── src/
│   ├── package.json
│   └── vite.config.js
└── README.md
```

## Quick Setup (5 minutes)

### 1. Backend Setup

```bash
# Navigate to backend
cd backend

# Install dependencies
npm install

# Create .env file
cp .env.example .env
# Edit .env with your MongoDB URI and secrets

# Start backend (development)
npm run dev

# Backend running at: http://localhost:5000
```

### 2. Flutter App Setup

```bash
# Navigate to app
cd ../app

# Get dependencies
flutter pub get

# Run with backend URL
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:5000/api

# Or for web:
flutter run -d web --dart-define=API_BASE_URL=http://localhost:5000/api
```

### 3. Web Frontend Setup

```bash
# Navigate to web
cd ../web

# Install dependencies
npm install

# Start development server
npm run dev

# Web running at: http://localhost:5173
```

## Detailed Setup Instructions

### Prerequisites

- Node.js 18+
- Flutter 3.10.4+
- MongoDB Atlas account (or local MongoDB)
- Firebase project (for Google OAuth)

### Backend Setup

#### 1. Environment Variables

Create `.env` in `backend/` directory:

```bash
# Database
MONGODB_URI=mongodb+srv://username:password@cluster.mongodb.net/bingo

# Server
PORT=5000
NODE_ENV=development

# Secrets
SESSION_SECRET=use-a-strong-random-string-here-change-in-production
JWT_SECRET=use-another-strong-random-string-here-change-in-production

# CORS
CORS_ORIGINS=http://localhost:5173,http://localhost:3000

# Firebase
FIREBASE_TYPE=service_account
FIREBASE_PROJECT_ID=bingogame-ac21c
FIREBASE_PRIVATE_KEY_ID=your_key_id_here
FIREBASE_PRIVATE_KEY=your_private_key_here_with_escaped_newlines
FIREBASE_CLIENT_EMAIL=firebase-adminsdk@bingogame-ac21c.iam.gserviceaccount.com
FIREBASE_CLIENT_ID=your_client_id_here
FIREBASE_AUTH_URI=https://accounts.google.com/o/oauth2/auth
FIREBASE_TOKEN_URI=https://oauth2.googleapis.com/token
FIREBASE_AUTH_PROVIDER_X509_CERT_URL=https://www.googleapis.com/oauth2/v1/certs
```

#### 2. Install Dependencies

```bash
cd backend
npm install
```

#### 3. MongoDB Setup

Option A: MongoDB Atlas (Recommended)

1. Go to https://www.mongodb.com/cloud/atlas
2. Create a free cluster
3. Get connection string: `mongodb+srv://username:password@cluster.mongodb.net/bingo`
4. Add `0.0.0.0/0` to IP whitelist for development

Option B: Local MongoDB

```bash
# Install MongoDB (if not already installed)
# macOS:
brew install mongodb-community

# Start MongoDB
mongod

# Connection string: mongodb://localhost:27017/bingo
```

#### 4. Firebase Setup (for Google OAuth)

1. Go to https://console.firebase.google.com
2. Create new project: "Bingo Game"
3. Go to Project Settings → Service Accounts
4. Click "Generate Private Key"
5. Copy JSON and add to `.env` (escape newlines)

#### 5. Start Backend

```bash
# Development with auto-reload
npm run dev

# Or production
npm run start
```

Server starts at: `http://localhost:5000`

### Flutter App Setup

#### 1. Install Flutter Dependencies

```bash
cd app
flutter pub get
```

#### 2. Platform-Specific Setup

**Android:**

- Ensure `android/app/src/main/AndroidManifest.xml` has internet permission
- Minimum SDK 21+
- Build with: `flutter run --dart-define=API_BASE_URL=http://10.0.2.2:5000/api`

**iOS:**

- Ensure `ios/Podfile` has minimum platform iOS 11.0
- Build with: `flutter run --dart-define=API_BASE_URL=http://10.0.2.2:5000/api`

**Web:**

- Build with: `flutter run -d web --dart-define=API_BASE_URL=http://localhost:5000/api`

#### 3. Run App

```bash
# Android Emulator
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:5000/api

# iOS Simulator
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:5000/api

# Physical Device (Android)
flutter run --dart-define=API_BASE_URL=http://YOUR_BACKEND_IP:5000/api

# Web
flutter run -d web --dart-define=API_BASE_URL=http://localhost:5000/api
```

### Web Frontend Setup

#### 1. Install Dependencies

```bash
cd web
npm install
```

#### 2. Configure Backend URL

Edit `src/services/` files to point to your backend:

```javascript
const API_BASE_URL = process.env.VITE_API_URL || "http://localhost:5000/api";
```

#### 3. Start Development Server

```bash
npm run dev
```

Web runs at: `http://localhost:5173`

## API Documentation

### Authentication Endpoints

#### Register

```
POST /api/register
Content-Type: application/json

{
  "name": "John Doe",
  "email": "john@example.com",
  "password": "secure_password"
}

Response:
{
  "success": true,
  "user": { "_id": "...", "name": "...", "email": "..." },
  "token": "eyJhbGc..."
}
```

#### Login

```
POST /api/login
Content-Type: application/json

{
  "email": "john@example.com",
  "password": "secure_password",
  "returnToken": true
}

Response: Same as Register
```

#### Google OAuth

```
POST /api/google
Content-Type: application/json

{
  "token": "google_id_token"
}

Response: Same as Register
```

### Game Endpoints

#### Create Room

```
POST /api/game/room/create

Response:
{
  "success": true,
  "roomId": "abc1234"
}
```

#### Join Room

```
POST /api/game/room/join
Content-Type: application/json

{
  "roomId": "abc1234"
}

Response:
{
  "success": true
}
```

### WebSocket Events

See [backend/FLUTTER_SETUP.md](backend/FLUTTER_SETUP.md#websocket-events) for complete event documentation.

## Testing

### Test Backend API with cURL

```bash
# Register
curl -X POST http://localhost:5000/api/register \
  -H "Content-Type: application/json" \
  -d '{"name":"Test","email":"test@test.com","password":"password"}'

# Login
curl -X POST http://localhost:5000/api/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@test.com","password":"password","returnToken":true}'

# Create Room
curl -X POST http://localhost:5000/api/game/room/create \
  -H "Content-Type: application/json"
```

### Test with Postman

1. Import the following requests:
   - Register: POST `{{baseUrl}}/register`
   - Login: POST `{{baseUrl}}/login`
   - Create Room: POST `{{baseUrl}}/game/room/create`
   - Join Room: POST `{{baseUrl}}/game/room/join`

2. Set Postman variable: `baseUrl = http://localhost:5000/api`

## Deployment

### Backend Deployment (Render.com)

1. Push code to GitHub
2. Go to https://render.com
3. Create new Web Service
4. Connect GitHub repository
5. Add environment variables from `.env`
6. Deploy

### Flutter App Deployment

#### Android (Google Play Store)

```bash
# Generate signing key
keytool -genkey -v -keystore ~/bingo-release.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias bingo-release

# Build App Bundle
flutter build appbundle \
  --dart-define=API_BASE_URL=https://your-backend.com/api \
  --release

# Upload build/app/outputs/bundle/release/app-release.aab to Play Console
```

#### iOS (App Store)

```bash
# Build IPA
flutter build ipa \
  --dart-define=API_BASE_URL=https://your-backend.com/api \
  --release

# Open Xcode and upload to App Store Connect
open ios/Runner.xcworkspace
```

#### Web

```bash
# Build web
flutter build web \
  --dart-define=API_BASE_URL=https://your-backend.com/api

# Deploy to Firebase Hosting
firebase deploy --only hosting

# Or deploy to any static hosting (Netlify, Vercel, etc.)
```

## Troubleshooting

### Backend Issues

| Issue                       | Solution                                                  |
| --------------------------- | --------------------------------------------------------- |
| `MONGODB_URI not found`     | Create `.env` file with `MONGODB_URI`                     |
| `Cannot connect to MongoDB` | Check network access in MongoDB Atlas, verify credentials |
| `Port 5000 already in use`  | Change `PORT` in `.env` or kill process on port 5000      |
| `CORS error in browser`     | Ensure origin is in `CORS_ORIGINS` env variable           |
| `Socket connection fails`   | Verify WebSocket is not blocked by firewall               |

### Flutter Issues

| Issue                                    | Solution                                                |
| ---------------------------------------- | ------------------------------------------------------- |
| `Connection refused`                     | Ensure backend is running, check `API_BASE_URL`         |
| `Android emulator can't reach localhost` | Use `10.0.2.2:5000` instead of `localhost:5000`         |
| `iOS simulator timeout`                  | Check network, increase timeout in `auth_service.dart`  |
| `Socket connection fails`                | Verify `SOCKET_URL` matches backend, check transports   |
| `CORS or origin error`                   | Flutter mobile apps send no origin; backend allows this |

### Web Issues

| Issue                | Solution                                    |
| -------------------- | ------------------------------------------- |
| `API 404 errors`     | Check backend routes, verify `API_BASE_URL` |
| `CORS errors`        | Ensure origin in backend `CORS_ORIGINS`     |
| `Socket disconnects` | Check network, verify WebSocket support     |

## Performance Tips

1. **Database**: Add indexes on frequently queried fields
2. **Caching**: Use Redis for session store in production
3. **Load Balancing**: Use PM2 or Docker for multiple instances
4. **Monitoring**: Add error logging (Sentry, LogRocket, etc.)
5. **CDN**: Serve static assets through CDN

## Security Checklist

- [ ] Change `SESSION_SECRET` to random string
- [ ] Change `JWT_SECRET` to random string
- [ ] Enable HTTPS in production
- [ ] Configure `CORS_ORIGINS` strictly in production
- [ ] Use strong MongoDB password
- [ ] Enable Firebase authentication
- [ ] Add rate limiting to API endpoints
- [ ] Add request validation
- [ ] Enable security headers
- [ ] Regularly update dependencies

## Development Workflow

### Local Development

```bash
# Terminal 1 - Backend
cd backend
npm run dev

# Terminal 2 - Flutter
cd app
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:5000/api

# Terminal 3 - Web
cd web
npm run dev
```

### Making Changes

**Backend**: Changes auto-reload with `nodemon`
**Flutter**: Use hot reload (`r` in terminal)
**Web**: Changes auto-reload with Vite

## Useful Commands

```bash
# Backend
npm install              # Install dependencies
npm run dev             # Start with auto-reload
npm run start           # Start production

# Flutter
flutter pub get         # Get dependencies
flutter run             # Run on default device
flutter run -d web      # Run on web
flutter build apk       # Build Android APK
flutter build ipa       # Build iOS IPA
flutter build web       # Build web

# Web
npm install             # Install dependencies
npm run dev             # Start dev server
npm run build           # Build for production
npm run preview         # Preview production build
```

## Environment Variables Reference

### Backend (.env)

- `MONGODB_URI` - MongoDB connection string
- `PORT` - Server port (default: 5000)
- `NODE_ENV` - Environment (development/production)
- `SESSION_SECRET` - Session encryption secret
- `JWT_SECRET` - JWT signing secret
- `CORS_ORIGINS` - Allowed CORS origins
- `FIREBASE_*` - Firebase credentials

### Flutter (dart-define)

- `API_BASE_URL` - Backend API URL
- `SOCKET_URL` - WebSocket URL (if different from API)

### Web (Vite env)

- `VITE_API_URL` - Backend API URL

## Additional Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Express.js Guide](https://expressjs.com/)
- [Socket.io Documentation](https://socket.io/)
- [MongoDB Documentation](https://docs.mongodb.com/)
- [Firebase Documentation](https://firebase.google.com/docs)

## Support & Debugging

1. **Check logs**: `npm run dev` output, Flutter console, browser console
2. **Test endpoints**: Use cURL or Postman
3. **Verify connections**: Check `http://localhost:5000` and `ws://localhost:5000`
4. **Check network**: Ensure backend is accessible from app's network
5. **Read error messages**: They usually indicate the exact problem

## Contributing

When making changes:

1. Create a feature branch
2. Make your changes
3. Test locally (all three parts)
4. Commit with clear messages
5. Push and create PR

## License

MIT

---

**Last Updated**: 2024  
**Maintained By**: [Your Name]  
**Status**: Active Development
