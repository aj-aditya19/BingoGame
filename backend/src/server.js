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

const corsOrigins = process.env.CORS_ORIGINS
  ? process.env.CORS_ORIGINS.split(",")
  : ["http://localhost:5173", "http://localhost:3000"];

const defaultHostedOrigins = ["https://bingogame-web-t73z.vercel.app"];
// const defaultHostedOrigins = ["https://localhost:5173"];

const allowedOrigins = new Set(
  [...corsOrigins, ...defaultHostedOrigins]
    .map((origin) => origin.trim())
    .filter(Boolean),
);

const isAllowedOrigin = (origin) => {
  if (!origin) return true;

  if (
    origin.startsWith("http://localhost") ||
    origin.startsWith("http://127.0.0.1")
  ) {
    return true;
  }

  if (allowedOrigins.has(origin)) {
    return true;
  }

  if (NODE_ENV === "production") {
    return false;
  }

  return true;
};

app.use(
  cors({
    origin: function (origin, callback) {
      if (!origin) {
        return callback(null, true);
      }
      if (origin.startsWith("http://localhost")) return callback(null, true);
      if (allowedOrigins.has(origin)) return callback(null, true);
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
      maxAge: 1000 * 60 * 60 * 24 * 30,
    },
  }),
);

app.use("/api", authRoutes);
app.use("/api/game", gameRoutes);

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

const io = new Server(server, {
  cors: {
    origin: "*",
    methods: ["GET", "POST"],
    credentials: true,
  },
  transports: ["websocket", "polling"],
});

initSocket(io);

server.listen(PORT, () => {
  console.log(`
╔════════════════════════════════════════╗
║     Bingo Game Backend Running         ║
╠════════════════════════════════════════╣
║ Port: ${PORT}                          ║
║ Environment: ${NODE_ENV}               ║
║ URL: http://localhost:${PORT}          ║
║ WebSocket: ws://localhost:${PORT}      ║
╚════════════════════════════════════════╝
  `);
});

process.on("SIGTERM", () => {
  console.log("SIGTERM received, closing server...");
  server.close(() => {
    console.log("Server closed");
    process.exit(0);
  });
});
