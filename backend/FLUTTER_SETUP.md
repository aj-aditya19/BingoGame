# Bingo Game Backend - Flutter Setup Guide

## Overview

The backend is fully configured to support Flutter mobile app, web frontend (React), and web-based Flutter apps. All communication is API-first with JWT token support for mobile clients.

## Backend Architecture

### Tech Stack

- **Framework**: Express.js (Node.js)
- **Database**: MongoDB
- **Real-time**: Socket.io (WebSocket)
- **Authentication**: JWT tokens + Sessions
- **Firebase**: Google OAuth integration

### API Endpoints

#### Authentication (`/api`)

- `POST /register` - Register new user
- `POST /login` - Login with email/password
- `POST /google` - Google OAuth login
- `GET /verify-token` - Verify JWT token validity

#### Game (`/api/game`)

- `POST /game/room/create` - Create a new game room
- `POST /game/room/join` - Join existing room

#### Health Check

- `GET /` - Server status
- `GET /health` - Health check endpoint

### WebSocket Events

#### Client → Server

- `join-room` - Join game room
- `start-game` - Start the game
- `game:select-number` - Select number during game
- `game:win` - Declare win
- `leave-room` - Leave room

#### Server → Client

- `room-joined` - Player joined room
- `game-start` - Game started
- `game:update` - Number selected by opponent
- `game:turn` - Your turn
- `game:win` - Game won

## Setup Instructions

### 1. Environment Configuration

Copy `.env.example` to `.env`:

```bash
cp .env.example .env
```

Update `.env` with your values:

```bash
# MongoDB
MONGODB_URI=mongodb+srv://username:password@cluster.mongodb.net/bingo

# Server
PORT=5000
NODE_ENV=development

# Security
SESSION_SECRET=your_strong_random_secret_here
JWT_SECRET=your_jwt_secret_here

# Firebase (for Google OAuth)
FIREBASE_PRIVATE_KEY=your_firebase_key
FIREBASE_CLIENT_EMAIL=your_firebase_email@service.gserviceaccount.com
FIREBASE_PROJECT_ID=your_project_id
```

### 2. Install Dependencies

```bash
npm install
```

### 3. Run Backend

Development mode with auto-reload:

```bash
npm run dev
```

Production mode:

```bash
npm run start
```

The server will be available at: `http://localhost:5000`

## Flutter Integration

### Build Configuration

When building Flutter app, pass backend URL:

#### For Android

```bash
flutter run --dart-define=API_BASE_URL=https://your-backend.com/api
```

#### For iOS

```bash
flutter run --dart-define=API_BASE_URL=https://your-backend.com/api
```

#### For Web

```bash
flutter run -d web --dart-define=API_BASE_URL=http://localhost:5000/api
```

### Network Configuration

#### Android (`android/app/src/main/AndroidManifest.xml`)

Ensure these permissions exist:

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
```

#### iOS (`ios/Podfile`)

The app uses standard HTTP client which works with both HTTP and HTTPS.

### Certificate Pinning (Optional - Production)

For enhanced security, implement certificate pinning. Update your HTTP client in Flutter to verify SSL certificates.

## CORS & Security

### Development

- Allows all localhost origins
- Allows mobile apps (no origin header)
- Allows web origins listed in `CORS_ORIGINS` env

### Production

- Strict origin checking
- HTTPS required (`secure` cookie flag)
- `SameSite=none` for cross-origin requests

## Authentication Flow

### Token-Based (Mobile)

1. User logs in/registers
2. Server returns JWT token
3. Client stores token (SecureStorage recommended)
4. Include token in Authorization header: `Bearer <token>`
5. Use `verifyToken` to check token validity

### Session-Based (Web)

1. User logs in/registers
2. Server creates session and sets cookie
3. Browser automatically includes cookie in requests
4. Session persists for 30 days

## Deployment

### Render (Recommended)

1. Connect GitHub repository
2. Set environment variables in Render dashboard
3. Select Node environment
4. Run: `npm install && npm run start`

### Docker

```dockerfile
FROM node:18
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
EXPOSE 5000
CMD ["npm", "start"]
```

Run:

```bash
docker build -t bingo-backend .
docker run -p 5000:5000 --env-file .env bingo-backend
```

### Vercel (Not Recommended - Stateless Limitation)

Socket.io requires persistent connections; Vercel's serverless architecture may cause issues.

## Troubleshooting

### Flutter Connection Issues

```
⚠️ Connection refused
- Check backend is running
- Verify API_BASE_URL is correct
- Check firewall settings
- Ensure backend port is exposed

⚠️ CORS error
- Verify origin is in CORS_ORIGINS
- Check Access-Control headers
- Try from localhost first

⚠️ Socket connection fails
- Ensure WebSocket is supported
- Check transports: ['websocket', 'polling']
- Verify no firewall blocking WebSocket
```

### MongoDB Connection

```
⚠️ MongooseError: Cannot connect
- Check MONGODB_URI syntax
- Verify network access in MongoDB Atlas
- Check IP whitelist
- Ensure credentials are correct
```

### JWT Token Issues

```
⚠️ Token verification failed
- Ensure JWT_SECRET is same on all instances
- Check token hasn't expired (30 days)
- Verify Authorization header format
```

## API Response Format

All endpoints return JSON with this structure:

```json
{
  "success": true|false,
  "message": "Optional message",
  "user": { /* user object */ },
  "token": "jwt-token",
  "roomId": "room-id"
}
```

## Testing with Postman

### Login (Get Token)

```
POST http://localhost:5000/api/login
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "password",
  "returnToken": true
}
```

Response:

```json
{
  "success": true,
  "user": { "_id": "...", "name": "...", "email": "..." },
  "token": "eyJhbGc..."
}
```

### Create Room

```
POST http://localhost:5000/api/game/room/create
Content-Type: application/json
```

Response:

```json
{
  "success": true,
  "roomId": "abc1234"
}
```

## Flutter App Services

### AuthService

```dart
// Login
final result = await AuthService.login(email, password);
if (result['success']) {
  String token = result['token'];
  // Save token securely
}

// Verify token
bool isValid = await AuthService.verifyToken(token);
```

### GameService

```dart
// Create room
final result = await GameService.createRoom();
String roomId = result['roomId'];

// Join room
final result = await GameService.joinRoom(roomId);
```

### SocketService

```dart
// Initialize socket
SocketService.init();

// Listen to events
SocketService.socket.on('room-joined', (data) {
  // Handle players joined
});

// Emit events
SocketService.socket.emit('join-room', {
  'roomId': roomId,
  'user': userObject
});
```

## Production Checklist

- [ ] Environment variables configured
- [ ] MongoDB connection verified
- [ ] Firebase credentials set up
- [ ] JWT secret changed
- [ ] SESSION_SECRET changed
- [ ] CORS origins configured
- [ ] HTTPS enabled
- [ ] Docker image built and tested
- [ ] Error logging implemented
- [ ] Rate limiting configured (optional)
- [ ] Request validation implemented
- [ ] Security headers added (optional)

## Performance Tips

1. **Database Indexing**: Add indexes on frequently queried fields

```javascript
db.users.createIndex({ email: 1 }, { unique: true });
```

2. **Connection Pooling**: MongoDB driver handles this automatically

3. **Caching**: Use Redis for session store in production

4. **Load Balancing**: Use PM2 or Docker Swarm

## Support

For issues or questions:

1. Check backend logs: `npm run dev` output
2. Verify environment variables
3. Check MongoDB connection
4. Review CORS configuration
5. Test endpoints with Postman

---

**Last Updated**: 2024
**Compatible With**: Flutter 3.x+, Express 5.x, Node 18.x+
