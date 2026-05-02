# BingoGame

Web and Flutter BingoGame project with a browser client, mobile app, and Node.js backend.

## Live Demo

Hosted web app: https://bingogame-web-t73z.vercel.app/

## Demo Users

Use these sample accounts to sign in and test the website:

| Email                  | Password |
| ---------------------- | -------- |
| ajaditya1908@gmail.com | 1907     |
| tushar@gmail.com       | 2611     |

## Project Structure

- `web/` - React + Vite web client
- `backend/` - Node.js backend and socket/API logic
- `app/` - Flutter client

## Web App Features

- Landing page on first open
- Login and register flow
- Create room and join room flow
- Live lobby, game board, and result screen
- Light and dark theme support

## Local Run

### Web

1. `cd web`
2. `npm install`
3. `npm run dev`

### Backend

1. `cd backend`
2. `npm install`
3. `npm start`

### Flutter App

1. `cd app`
2. `flutter pub get`
3. `flutter run`

## Notes

- The sample credentials are for demo/testing only.
- Make sure the backend is running before trying multiplayer room flows.
