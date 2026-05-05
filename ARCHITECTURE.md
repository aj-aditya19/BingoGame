# 🎮 Bingo Game - Architecture Overview

## System Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                          CLIENTS                                    │
├──────────────┬──────────────┬──────────────────────────────────────┤
│              │              │                                      │
│   Flutter    │   Flutter    │         React Web                    │
│   Mobile     │   Web        │         Frontend                     │
│   (Android   │   (Browser)  │         (Browser)                    │
│   /iOS)      │              │                                      │
└──────┬───────┴──────┬───────┴─────────────────────┬────────────────┘
       │              │                            │
       │ HTTP + JWT   │ HTTP + Session             │ HTTP + Session
       │ WebSocket    │ WebSocket (polling)        │ WebSocket
       │              │                            │
       └──────────────┴────────────────┬───────────┘
                                      │
                         ┌────────────▼──────────┐
                         │                       │
                         │   Express Backend     │
                         │   (Node.js)           │
                         │                       │
                         │  Port: 5000           │
                         │                       │
                         ├────────────┬──────────┤
                         │            │          │
                         │ HTTP API   │ Socket   │
                         │            │ WebSocket│
                         │            │          │
                         └────────────┼──────────┘
                                      │
                    ┌─────────────────┼─────────────────┐
                    │                 │                 │
         ┌──────────▼──────────┐  ┌───▼────────┐  ┌────▼──────────┐
         │   MongoDB           │  │  Socket    │  │  Firebase     │
         │   (Database)        │  │  Rooms     │  │  Auth         │
         │                     │  │  (Memory)  │  │  (Google)     │
         │   Collections:      │  │            │  │               │
         │   - users           │  │ Real-time  │  │ For Google    │
         │   - game_stats      │  │ Events     │  │ OAuth tokens  │
         └─────────────────────┘  └────────────┘  └───────────────┘
```

## Data Flow Diagram

### Authentication Flow (JWT for Mobile)

```
┌──────────────┐                          ┌──────────────┐
│ Mobile App   │                          │   Backend    │
│ (Flutter)    │                          │  (Express)   │
└──────┬───────┘                          └──────┬───────┘
       │                                         │
       │─── POST /login ─────────────────────────>
       │   { email, password, returnToken: true}│
       │                                         │
       │              ← JWT Token returned ──────│
       │           { success, user, token }     │
       │                                         │
       │ Stores token in SecureStorage          │
       │                                         │
       │─── Future requests ──────────────────→ │
       │   Headers: { Authorization: Bearer ... }
       │                                         │
       └─────────────────────────────────────────┘

For Web (Session-based):
       │─── POST /login ─────────────────────────>
       │                                         │
       │         ← Set-Cookie: session_id ───────│
       │                                         │
       │ Browser stores cookie                  │
       │                                         │
       │─── Future requests ──────────────────→ │
       │   Cookies sent automatically           │
       │                                         │
       └─────────────────────────────────────────┘
```

### Game Flow (Real-time with Socket.io)

```
Player 1                          Player 2
(Flutter)                         (Flutter)
   │                                │
   │──── POST /game/room/create ────→ Backend
   │                                │
   │ ← roomId: "abc1234" ─────────  │
   │                                │
   │ [Share room ID with P2]        │
   │                                │
   │────── POST /join ──────────────→ Backend
   │                                │
   │                 ┌──────────────┤
   │                 │              │
   │                 │ ← emit 'room-joined'
   │                 │              │
   │ emit 'join-room' with user info
   │     (Socket.io)              │
   │                 ├──────────────→ Backend
   │                 │    roomId,   │
   │                 │    userId,   │
   │                 │    userName  │
   │                 │              │
   │ ← 'room-joined' [players list]─
   │    (broadcast to room)
   │                                ← 'room-joined' [players list]
   │
   │ ← 'game-start' ────────────────────→
   │    (when both players ready)
   │
   │ Makes move ─ 'game:select-number'
   │           with number ──────────────→ Backend
   │                                      │
   │                          ← 'game:update'
   │                            (opponent's number)
   │                                      │
   │ Receives opponent's number ←─────────
   │
   │ Updates opponent grid
   │
   │ (Turn changes)
   │ ← 'game:turn' ────────────────────→
   │    userId who plays next
   │
   │ (Repeat until win)
   │
   │ Wins ──── 'game:win'
   │       with userId ──────────────────→ Backend
   │                                      │
   │                                 Updates stats in DB
   │                                 Deletes room
   │
   │ ← 'game:win' with winnerId ────────→
   │    (broadcast to room)
   │
   │ Display winner
   │ Return to menu
```

## API Endpoints

### Authentication Endpoints

```
POST /api/register
├─ Body: { name, email, password }
├─ Response: { success, user, token (mobile only) }
└─ Session set for web clients

POST /api/login
├─ Body: { email, password, returnToken? }
├─ Response: { success, user, token (if requested) }
└─ Session set for web clients

POST /api/google
├─ Body: { token (Google ID token) }
├─ Response: { success, user, token }
└─ Creates user if not exists

GET /api/verify-token
├─ Headers: { Authorization: Bearer <token> }
├─ Response: { success, userId }
└─ For token validation
```

### Game Endpoints

```
POST /api/game/room/create
├─ Body: {}
├─ Response: { success, roomId }
└─ Creates new room in memory

POST /api/game/room/join
├─ Body: { roomId }
├─ Response: { success }
└─ Validates room exists and has space
```

## Socket.io Events

### Client Emits

```
'join-room'
├─ Data: { roomId, user }
└─ Effect: Adds player to room, broadcasts room-joined

'start-game'
├─ Data: { roomId }
└─ Effect: Marks room as started, broadcasts game-start

'game:select-number'
├─ Data: { roomId, number, userId }
└─ Effect: Broadcasts number, switches turn

'game:win'
├─ Data: { roomId, userId }
└─ Effect: Updates player stats, deletes room

'leave-room'
├─ Data: { roomId }
└─ Effect: Removes player, deletes empty room
```

### Server Broadcasts

```
'room-joined'
├─ Data: [players array]
└─ Sent to: All in room

'game-start'
├─ Data: { turnUserId }
└─ Sent to: All in room

'game:update'
├─ Data: { number }
└─ Sent to: All in room

'game:turn'
├─ Data: { userId }
└─ Sent to: All in room

'game:win'
├─ Data: { userId }
└─ Sent to: All in room
```

## Database Models

### User Collection

```javascript
{
  _id: ObjectId,
  name: String,              // Required
  email: String,             // Unique, required
  password: String,          // Optional (null for OAuth)
  provider: String,          // "local" or "google"

  // Statistics
  gamesPlayed: Number,       // Total games
  win: Number,               // Wins count
  loss: Number,              // Losses count
  draw: Number,              // Draws count

  // Metadata
  lastLogin: Date,           // Last login timestamp
  createdAt: Date,           // Account creation
  updatedAt: Date            // Last update
}
```

### In-Memory Room Structure (Socket.io)

```javascript
rooms = Map {
  "abc1234": {
    roomId: "abc1234",
    players: [
      {
        userId: "user1",
        name: "Player 1",
        socketId: "socket1",
        grid: [...],
        playerNo: 1,
        role: "Host"
      },
      {
        userId: "user2",
        name: "Player 2",
        socketId: "socket2",
        grid: [...],
        playerNo: 2,
        role: "Invited"
      }
    ],
    started: false,
    turnUserId: "user1",
    winnerUserId: null
  }
}
```

## Component Interaction

### Backend Services

```
server.js (Express App)
├── Express middleware
│   ├── CORS
│   ├── JSON parser
│   ├── Session management
│   └── Routes
│
├── API Routes
│   ├── auth.route.js
│   │   ├── /register
│   │   ├── /login
│   │   ├── /google
│   │   └── /verify-token
│   │
│   └── game.route.js
│       ├── /game/room/create
│       └── /game/room/join
│
├── Socket.io
│   └── config/socket.js
│       ├── join-room
│       ├── start-game
│       ├── game:select-number
│       ├── game:win
│       └── leave-room
│
└── Database
    ├── config/db.js (MongoDB connection)
    └── database/User.js (User model)
```

### Flutter Services

```
main.dart
├── AuthService
│   ├── login()
│   ├── register()
│   ├── googleAuth()
│   └── verifyToken()
│
├── GameService
│   ├── createRoom()
│   └── joinRoom()
│
└── SocketService
    ├── init()
    ├── emit()
    ├── on()
    ├── reconnect()
    └── dispose()
```

## Request/Response Cycle

### Typical Game Session

```
1. User Opens App
   └─ SocketService.init()
      └─ Connects to backend WebSocket
      └─ Auto-reconnect enabled

2. User Logs In
   └─ AuthService.login()
      ├─ POST /api/login
      ├─ Receive JWT token
      └─ Store in SecureStorage

3. User Creates Room
   └─ GameService.createRoom()
      ├─ POST /api/game/room/create
      ├─ Receive roomId
      └─ Share with opponent

4. User Joins Room
   └─ GameService.joinRoom()
      ├─ POST /api/game/room/join
      └─ SocketService.emit('join-room')
         ├─ Send roomId, user info
         └─ Receive 'room-joined' with players list

5. Game Starts
   └─ SocketService.emit('start-game')
      └─ Receive 'game-start' with first player

6. Players Play
   └─ Each turn:
      ├─ SocketService.emit('game:select-number')
      ├─ Receive 'game:update' from opponent
      └─ Receive 'game:turn' with next player

7. Player Wins
   └─ SocketService.emit('game:win')
      ├─ Backend updates stats in MongoDB
      ├─ Backend deletes room
      └─ All players receive 'game:win'

8. Game Ends
   └─ Return to menu
```

## Error Handling

```
Connection Errors
├─ Socket disconnects
│  └─ Auto-reconnect with exponential backoff
│
├─ Network timeout
│  └─ Services return error responses
│
└─ Backend down
   └─ Socket reconnect loop

Authentication Errors
├─ Invalid credentials
│  └─ Return { success: false, message }
│
├─ Token expired
│  └─ Return validation error
│  └─ Client redirects to login
│
└─ User not found
   └─ Return { success: false }

Game Errors
├─ Room not found
│  └─ Socket emits fail silently
│
├─ Room full
│  └─ Return error to joining player
│
└─ Invalid move
   └─ Socket discards event
```

## Performance Characteristics

| Operation   | Latency | Notes                      |
| ----------- | ------- | -------------------------- |
| Login       | ~500ms  | Depends on MongoDB network |
| Create Room | <50ms   | In-memory operation        |
| Join Room   | ~100ms  | Socket handshake + emit    |
| Game Update | <50ms   | Real-time Socket emit      |
| Win Update  | ~200ms  | Includes MongoDB write     |

## Scalability Considerations

### Current (Single Instance)

- ✅ Great for development and small player base
- ❌ Single point of failure
- ❌ Limited concurrent connections

### Scaling Up

- Add load balancer (Nginx, HAProxy)
- Use Redis for session store
- Use MongoDB sharding for large datasets
- Implement rate limiting
- Add caching layer

### Distributed Architecture

```
Load Balancer
├─ Backend Instance 1 ──┐
├─ Backend Instance 2 ──┤─── Redis Cache
├─ Backend Instance 3 ──┘
│
MongoDB Cluster
├─ Primary
├─ Secondary 1
└─ Secondary 2
```

---

**Version**: 1.0.0  
**Last Updated**: 2024  
**Status**: Production Ready
