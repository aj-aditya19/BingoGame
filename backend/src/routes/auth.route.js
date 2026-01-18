import express from "express";
import User from "../database/User.js";
import admin from "../config/firebase.js";

const router = express.Router();

router.post("/register", async (req, res) => {
  const { name, email, password } = req.body;

  if (!email || !password || !name) {
    return res.json({ success: false, message: "All fields required" });
  }

  const exist = await User.findOne({ email });
  if (exist) {
    return res.json({ success: false, message: "User already exists" });
  }

  const user = await User.create({
    name,
    email,
    password,
  });

  req.session.user = user.email;

  res.json({ success: true, user });
});

router.post("/login", async (req, res) => {
  const { email, password } = req.body;

  const user = await User.findOne({ email, password });
  if (!user) return res.json({ success: false });

  req.session.user = user.email;
  res.json({ success: true, user });
});

router.post("/google", async (req, res) => {
  try {
    const { token } = req.body;
    const decoded = await admin.auth().verifyIdToken(token);

    let user = await User.findOne({ email: decoded.email });

    if (!user) {
      user = await User.create({
        name: decoded.name,
        email: decoded.email,
        password: null,
        provider: "google",
      });
    }

    req.session.userId = user._id;

    res.json({
      success: true,
      user,
      needPassword: user.password === null,
    });
  } catch (err) {
    res.status(401).json({ success: false });
  }
});

router.post("/set-password", async (req, res) => {
  if (!req.session.userId) return res.status(401).json({ success: false });

  const { password } = req.body;

  await User.findByIdAndUpdate(req.session.userId, { password });

  res.json({ success: true });
});

export default router;
