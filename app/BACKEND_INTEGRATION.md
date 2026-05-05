# Flutter Bingo App - Backend Integration Guide

## Quick Start

### Prerequisites

- Flutter 3.10.4+
- Dart 3.10.4+
- iOS 11.0+ or Android API 21+

### Dependencies

The app already has all required dependencies:

```yaml
http: ^1.2.0 # HTTP requests
socket_io_client: ^3.1.4 # Real-time communication
provider: ^6.1.5 # State management
```

## Backend URL Configuration

### Development (Local Backend)

```bash
# Android/iOS
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:5000/api

# Web (localhost)
flutter run -d web --dart-define=API_BASE_URL=http://localhost:5000/api
```

### Production (Deployed Backend)

```bash
flutter run --dart-define=API_BASE_URL=https://your-backend.com/api
```

### Default URL

If not specified, defaults to: `https://bingogame-6eoj.onrender.com/api`

## Build Instructions

### Android

1. **Update `android/app/build.gradle`**:

   ```gradle
   android {
       compileSdkVersion 34
       defaultConfig {
           minSdkVersion 21
           targetSdkVersion 34
       }
   }
   ```

2. **Ensure Network Permissions** (`android/app/src/main/AndroidManifest.xml`):

   ```xml
   <uses-permission android:name="android.permission.INTERNET" />
   <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
   ```

3. **Build APK**:

   ```bash
   flutter build apk --dart-define=API_BASE_URL=https://your-backend.com/api
   ```

4. **Build App Bundle** (for Play Store):
   ```bash
   flutter build appbundle --dart-define=API_BASE_URL=https://your-backend.com/api
   ```

### iOS

1. **Update `ios/Podfile`**:
   Ensure minimum deployment target is set to 11.0+

2. **Build IPA**:

   ```bash
   flutter build ios --dart-define=API_BASE_URL=https://your-backend.com/api
   ```

3. **Archive for App Store**:
   ```bash
   flutter build ipa --dart-define=API_BASE_URL=https://your-backend.com/api
   ```

### Web

1. **Build Web**:

   ```bash
   flutter build web --dart-define=API_BASE_URL=https://your-backend.com/api
   ```

2. **Deploy to Hosting**:
   ```bash
   # Firebase Hosting
   firebase deploy --only hosting
   ```

## Service Usage

### Authentication Service

#### Login

```dart
import 'package:app/services/auth_service.dart';

final result = await AuthService.login('user@example.com', 'password');

if (result['success']) {
  final user = result['user'];
  final token = result['token']; // Save this securely
  print('Welcome ${user['name']}');
} else {
  print('Error: ${result['message']}');
}
```

#### Register

```dart
final result = await AuthService.register('John Doe', 'john@example.com', 'password');

if (result['success']) {
  // User registered and logged in
  final token = result['token'];
}
```

#### Google Authentication

```dart
// You need to implement Google Sign-In separately
// Then pass the token to AuthService
final result = await AuthService.googleAuth(googleToken);
```

#### Verify Token

```dart
bool isValid = await AuthService.verifyToken(savedToken);
if (!isValid) {
  // Token expired, ask user to login again
}
```

### Game Service

#### Create Room

```dart
import 'package:app/services/game_service.dart';

final result = await GameService.createRoom();

if (result['success']) {
  final roomId = result['roomId'];
  // Share this room ID with opponent
} else {
  print('Error: ${result['message']}');
}
```

#### Join Room

```dart
final result = await GameService.joinRoom(roomId);

if (result['success']) {
  // Connected to room
} else {
  print('Error: ${result['message']}');
}
```

### Socket Service

#### Initialize

```dart
import 'package:app/services/socket_service.dart';

void initState() {
  super.initState();
  SocketService.init();
}

void dispose() {
  SocketService.dispose();
  super.dispose();
}
```

#### Join Room (with player info)

```dart
SocketService.socket.emit('join-room', {
  'roomId': roomId,
  'user': {
    '_id': userId,
    'name': userName,
    'grid': bingGrid,
    'role': 'Host' // or 'Invited'
  }
});
```

#### Listen to Room Joined

```dart
SocketService.socket.on('room-joined', (data) {
  List<dynamic> players = data;
  setState(() {
    this.players = players;
  });
});
```

#### Start Game

```dart
SocketService.socket.emit('start-game', {
  'roomId': roomId
});
```

#### Listen to Game Start

```dart
SocketService.socket.on('game-start', (data) {
  String turnUserId = data['turnUserId'];
  // Game started
});
```

#### Select Number (make a move)

```dart
SocketService.socket.emit('game:select-number', {
  'roomId': roomId,
  'number': selectedNumber,
  'userId': currentUserId
});
```

#### Listen to Game Updates

```dart
SocketService.socket.on('game:update', (data) {
  int selectedNumber = data['number'];
  // Update opponent's grid
});

SocketService.socket.on('game:turn', (data) {
  String turnUserId = data['userId'];
  // Update turn info
});
```

#### Declare Win

```dart
SocketService.socket.emit('game:win', {
  'roomId': roomId,
  'userId': currentUserId
});
```

#### Listen to Win

```dart
SocketService.socket.on('game:win', (data) {
  String winnerId = data['userId'];
  // Show winner
});
```

#### Leave Room

```dart
SocketService.socket.emit('leave-room', {
  'roomId': roomId
});
```

## Storage (Token Management)

### Secure Storage Setup

Add to `pubspec.yaml`:

```yaml
flutter_secure_storage: ^9.0.0
```

### Example Usage

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const storage = FlutterSecureStorage();

// Save token
await storage.write(key: 'auth_token', value: token);

// Retrieve token
String? token = await storage.read(key: 'auth_token');

// Delete token (logout)
await storage.delete(key: 'auth_token');

// Check if token exists
bool hasToken = await storage.containsKey(key: 'auth_token');
```

## Error Handling

### Common Errors

```dart
// Connection timeout
try {
  final result = await AuthService.login(email, password);
} catch (e) {
  if (e.toString().contains('timeout')) {
    print('Connection timeout - check internet');
  }
}

// Invalid credentials
if (!result['success']) {
  print(result['message']); // "Invalid credentials"
}

// Socket connection issues
SocketService.socket.onConnectError((err) {
  print('Socket error: $err');
  // Implement reconnection logic
});
```

## Network Configuration

### Android Network Security

Create `android/app/src/main/res/xml/network_security_config.xml`:

```xml
<?xml version="1.0" encoding="utf-8"?>
<network-security-config>
    <domain-config cleartextTrafficPermitted="true">
        <domain includeSubdomains="true">localhost</domain>
        <domain includeSubdomains="true">10.0.0.0/8</domain>
    </domain-config>
</network-security-config>
```

Reference in `AndroidManifest.xml`:

```xml
<application
    android:networkSecurityConfig="@xml/network_security_config"
    ...>
</application>
```

### iOS Network Configuration

Update `ios/Runner/Info.plist`:

```xml
<key>NSLocalNetworkUsageDescription</key>
<string>App needs local network access for testing</string>
<key>NSBonjourServices</key>
<array>
    <string>_http._tcp</string>
    <string>_ws._tcp</string>
</array>
```

## Testing

### Unit Tests

```dart
import 'package:app/services/auth_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthService', () {
    test('login returns user on success', () async {
      final result = await AuthService.login('test@test.com', 'password');
      expect(result['success'], true);
    });
  });
}
```

Run tests:

```bash
flutter test
```

### Manual Testing

1. **Test Login**: Start backend, run app, attempt login
2. **Test Room Creation**: Create room and verify room ID
3. **Test Real-time**: Open on two devices and verify socket communication
4. **Test Offline**: Disable network and verify error handling

## Deployment

### Play Store (Android)

1. Create signing key:

   ```bash
   keytool -genkey -v -keystore ~/bingo-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias bingo-key
   ```

2. Update `android/app/build.gradle`:

   ```gradle
   signingConfigs {
       release {
           keyAlias = 'bingo-key'
           keyPassword = '...'
           storeFile = file('bingo-key.jks')
           storePassword = '...'
       }
   }
   ```

3. Build and upload to Play Store

### App Store (iOS)

1. Create App ID in Apple Developer
2. Set up code signing certificates
3. Run:
   ```bash
   flutter build ipa --dart-define=API_BASE_URL=...
   ```
4. Upload to TestFlight or App Store Connect

### Web Hosting

1. Build web:

   ```bash
   flutter build web --dart-define=API_BASE_URL=...
   ```

2. Deploy to Firebase Hosting:
   ```bash
   firebase deploy --only hosting
   ```

## Performance Optimization

1. **Minimize Hot Reload Issues**: Use `const` constructors
2. **Network Optimization**: Implement request caching
3. **Socket Optimization**: Batch socket emissions
4. **UI Performance**: Use `const` and `RepaintBoundary`

## Troubleshooting

### API Connection Issues

```
❌ Connection refused (10.0.2.2 on Android)
✅ Use 10.0.2.2:5000 for local backend on Android emulator

❌ CORS errors
✅ Verify API_BASE_URL matches backend CORS_ORIGINS

❌ Timeout errors
✅ Check network connectivity
✅ Verify backend is running
✅ Increase timeout in AuthService/GameService
```

### Socket Connection Issues

```
❌ Socket disconnected immediately
✅ Check WebSocket URL matches API_BASE_URL
✅ Verify backend Socket.io is running
✅ Check firewall isn't blocking WebSocket

❌ "WebSocket closed" errors
✅ Verify backend stability
✅ Check network stability
✅ Implement automatic reconnection
```

## Development Tips

1. **Hot Reload with Dart Define**:

   ```bash
   flutter run --dart-define=API_BASE_URL=http://10.0.2.2:5000/api
   ```

2. **Debug Network Requests**:

   ```dart
   // In main.dart or appropriate location
   HttpClient().badCertificateCallback = (x, y, z) => true; // dev only
   ```

3. **Monitor Socket Events**:
   ```dart
   SocketService.socket.onConnect((_) => print('✅ Connected'));
   SocketService.socket.onDisconnect((_) => print('❌ Disconnected'));
   SocketService.socket.onError((err) => print('⚠️ Error: $err'));
   ```

---

**Last Updated**: 2024  
**Flutter Version**: 3.10.4+  
**Backend**: Node.js Express with Socket.io
