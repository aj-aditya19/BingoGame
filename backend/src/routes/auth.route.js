import express from "express";
import jwt from "jsonwebtoken";
import User from "../database/User.js";
import admin from "../config/firebase.js";

const router = express.Router();

const generateToken = (userId) => {
  return jwt.sign({ userId }, process.env.JWT_SECRET || "your_jwt_secret", {
    expiresIn: "30d",
  });
};

const sendUserResponse = async (user, res, withToken = false) => {
  const response = { success: true, user: user.toObject() };

  if (withToken) {
    response.token = generateToken(user._id);
  }

  return res.json(response);
};

router.post("/register", async (req, res) => {
  try {
    const { name, email, password } = req.body;

    if (!email || !password || !name) {
      return res.json({ success: false, message: "All fields required" });
    }
    z;
    const exist = await User.findOne({ email });
    if (exist) {
      return res.json({ success: false, message: "User already exists" });
    }

    const user = await User.create({
      name,
      email,
      password,
    });

    if (req.session) {
      req.session.userId = user._id;
    }
    const withToken =
      req.headers["x-client-type"] === "mobile" || req.body.returnToken;
    return sendUserResponse(user, res, withToken);
  } catch (err) {
    console.error("Register error:", err);
    return res.status(500).json({ success: false, message: "Server error" });
  }
});

router.post("/login", async (req, res) => {
  try {
    const { email, password } = req.body;

    const user = await User.findOne({ email, password });
    if (!user) {
      return res.json({ success: false, message: "Invalid credentials" });
    }

    user.lastLogin = new Date();
    await user.save();

    if (req.session) {
      req.session.userId = user._id;
    }

    const withToken =
      req.headers["x-client-type"] === "mobile" || req.body.returnToken;
    return sendUserResponse(user, res, withToken);
  } catch (err) {
    console.error("Login error:", err);
    return res.status(500).json({ success: false, message: "Server error" });
  }
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
        provider: "google",
      });
    }

    user.lastLogin = new Date();
    await user.save();

    if (req.session) {
      req.session.userId = user._id;
    }

    return sendUserResponse(user, res, true);
  } catch (err) {
    console.error("Google auth error:", err);
    res.status(401).json({ success: false, message: "Authentication failed" });
  }
});

router.get("/verify-token", (req, res) => {
  try {
    const token = req.headers.authorization?.split(" ")[1];
    if (!token) {
      return res.json({ success: false, message: "No token provided" });
    }

    const decoded = jwt.verify(
      token,
      process.env.JWT_SECRET || "your_jwt_secret",
    );
    res.json({ success: true, userId: decoded.userId });
  } catch (err) {
    res.json({ success: false, message: "Invalid token" });
  }
});

export default router;
