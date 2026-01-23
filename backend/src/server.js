import express from "express";
import session from "express-session";
import cors from "cors";
import dotenv from "dotenv";
import http from "http";
import { Server } from "socket.io";

import connectDB from "./config/db.js";
import authRoutes from "./routes/auth.route.js";
import gameRoutes from "./routes/game.route.js";
import initSocket from "./config/socket.js";

dotenv.config();
connectDB();

const app = express();
const server = http.createServer(app);

const io = new Server(server, {
  cors: {
    origin: "*",
    methods: ["GET", "POST"],
    credentials: true,
  },
});

app.use(
  cors({
    origin: ["http://localhost:5173"],
    credentials: true,
  }),
);

app.use(express.json());

app.use(
  session({
    secret: "bingo-session",
    resave: false,
    saveUninitialized: false,
    cookie: {
      httpOnly: true,
      secure: false,
      sameSite: "lax",
    },
  }),
);

// routes
app.use("/api", authRoutes);
app.use("/api/game", gameRoutes);

// socket init
initSocket(io);

app.get("/", (req, res) => {
  res.send("Bingo backend running");
});

server.listen(5000, () => {
  console.log("Server running on http://localhost:5000");
});
