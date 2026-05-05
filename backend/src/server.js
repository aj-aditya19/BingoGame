import "dotenv/config";

import express from "express";
import MongoStore from "connect-mongo";
import session from "express-session";
import cors from "cors";

import http from "http";
import { Server } from "socket.io";

import connectDB from "./config/db.js";
import authRoutes from "./routes/auth.route.js";
import gameRoutes from "./routes/game.route.js";
import initSocket from "./config/socket.js";

connectDB();

const app = express();
const server = http.createServer(app);
const PORT = process.env.PORT || 5000;
const NODE_ENV = process.env.NODE_ENV || "development";

// Parse CORS origins from env
const corsOrigins = process.env.CORS_ORIGINS
  ? process.env.CORS_ORIGINS.split(",")
  : ["http://localhost:5173", "http://localhost:3000"];

// CORS Configuration - supports web, Flutter mobile, and Flutter web
app.use(
  cors({
    origin: function (origin, callback) {
      // Allow requests with no origin (mobile apps, Postman)
      if (!origin) return callback(null, true);

      const allowedOrigins = corsOrigins;

      // allow any localhost (for Flutter web random ports, Postman, etc.)
      if (
        origin.startsWith("http://localhost") ||
        origin.startsWith("http://127.0.0.1") ||
        allowedOrigins.includes(origin)
      ) {
        return callback(null, true);
      }

      // production - strict checking
      if (NODE_ENV === "production" && !allowedOrigins.includes(origin)) {
        return callback(new Error("Not allowed by CORS"));
      }

      return callback(null, true);
    },
    credentials: true,
  }),
);

app.use(express.json());

app.use(
  session({
    secret: process.env.SESSION_SECRET || "fallback-secret",
    resave: false,
    saveUninitialized: false,
    store: MongoStore.create({ mongoUrl: process.env.MONGODB_URI }),
    cookie: {
      httpOnly: true,
      secure: NODE_ENV === "production",
      sameSite: "none",
      maxAge: 1000 * 60 * 60 * 24 * 30, // 30 days
    },
  }),
);

// API routes
app.use("/api", authRoutes);
app.use("/api/game", gameRoutes);

// Health check endpoint
app.get("/", (req, res) => {
  res.json({
    message: "Bingo backend running",
    env: NODE_ENV,
    timestamp: new Date().toISOString(),
  });
});

app.get("/health", (req, res) => {
  res.json({ status: "ok" });
});

// Socket.io configuration - supports both web and mobile
const io = new Server(server, {
  cors: {
    origin: (origin, callback) => {
      // Allow no origin (mobile apps, desktop clients)
      if (!origin) return callback(null, true);

      // Allow localhost
      if (
        origin.startsWith("http://localhost") ||
        origin.startsWith("http://127.0.0.1")
      ) {
        return callback(null, true);
      }

      // Allow configured origins
      if (corsOrigins.includes(origin)) {
        return callback(null, true);
      }

      return callback(null, true); // permissive in dev
    },
    methods: ["GET", "POST"],
    credentials: true,
  },
  transports: ["websocket", "polling"], // support both transports for mobile
});

initSocket(io);

server.listen(PORT, () => {
  console.log(`
╔════════════════════════════════════════╗
║     Bingo Game Backend Running         ║
╠════════════════════════════════════════╣
║ Port: ${PORT}
║ Environment: ${NODE_ENV}
║ URL: http://localhost:${PORT}
║ WebSocket: ws://localhost:${PORT}
╚════════════════════════════════════════╝
  `);
});

// Handle graceful shutdown
process.on("SIGTERM", () => {
  console.log("SIGTERM received, closing server...");
  server.close(() => {
    console.log("Server closed");
    process.exit(0);
  });
});
