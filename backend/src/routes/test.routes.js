import express from "express";
import admin from "../config/firebase.js";

const router = express.Router();

router.get("/health", (req, res) => {
  res.json({
    status: "OK",
    message: "Backend + Docker working",
    time: new Date(),
  });
});

router.post("/auth/verify", async (req, res) => {
  const { token } = req.body;
  try {
    const decoded = await admin.auth().verifyIdToken(token);
    res.json({
      success: true,
      uid: decoded.uid,
      email: decoded.email,
    });
  } catch (err) {
    res.status(401).json({
      success: false,
      error: "Invalid Firebase token",
    });
  }
});

router.get("/firebase-test", async (req, res) => {
  try {
    const list = await admin.auth().listUsers(1);
    res.json({
      firebase: "connected",
      usersCount: list.users.length,
    });
  } catch (err) {
    res.status(500).json({
      firebase: "error",
      message: err.message,
    });
  }
});

export default router;
