import express from "express";
import session from "express-session";
import cors from "cors";
import dotenv from "dotenv";
import connectDB from "./config/db.js";
import authRoutes from "./routes/auth.route.js";

dotenv.config();
connectDB();
console.log("SERVER ENV ", process.env.MONGODB_URI);

const app = express();

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

app.use("/api", authRoutes);

app.get("/", (req, res) => {
  res.send("Bingo backend running");
});

app.listen(5000, () => {
  console.log("Server running on port http://localhost:5000");
});
