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

// const io = new Server(server, {
//   cors: {
//     origin: "*",
//     methods: ["GET", "POST"],
//     credentials: true,
//   },
// });

app.use(
  cors({
    origin: function (origin, callback) {
      // allow requests with no origin (mobile apps, Postman)
      if (!origin) return callback(null, true);

      const allowedOrigins = [
        "http://localhost:5173",
        "https://bingogame-web-t73z.vercel.app",
      ];

      // allow any localhost (for Flutter web random ports)
      if (
        origin.startsWith("http://localhost") ||
        allowedOrigins.includes(origin)
      ) {
        return callback(null, true);
      }

      return callback(new Error("Not allowed by CORS"));
    },
    credentials: true,
  }),
);

app.use(express.json());

app.use(
  session({
    secret: process.env.SESSION_SECRET,
    resave: false,
    saveUninitialized: false,
    store: MongoStore.create({ mongoUrl: process.env.MONGODB_URI }),
    cookie: {
      httpOnly: true,
      secure: process.env.NODE_ENV === "production", // true on Render
      sameSite: "none", // important for cross-origin frontend
      maxAge: 1000 * 60 * 60 * 24 * 30, // 30 days
    },
  }),
);

// routes
app.use("/api", authRoutes);
app.use("/api/game", gameRoutes);

// socket init
const io = new Server(server, {
  cors: {
    origin: (origin, callback) => {
      if (!origin || origin.startsWith("http://localhost")) {
        return callback(null, true);
      }
      return callback(null, true);
    },
    methods: ["GET", "POST"],
    credentials: true,
  },
});

initSocket(io);

app.get("/", (req, res) => {
  res.send("Bingo backend running");
});

server.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
});
