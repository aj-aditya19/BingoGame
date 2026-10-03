import express from "express";
import crypto from "crypto";
import jwt from "jsonwebtoken";
import User from "../database/User.js";
import { sendOtpEmail, sendWelcomeEmail } from "../config/mailer.js";

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

const OTP_EXPIRY_MINUTES = 10;
const OTP_RESEND_SECONDS = 60;
const OTP_MAX_ATTEMPTS = 5;
const MIN_PASSWORD_LENGTH = 6;

const hashOtp = (otp) =>
  crypto
    .createHash("sha256")
    .update(`${otp}:${process.env.JWT_SECRET || "your_jwt_secret"}`)
    .digest("hex");

const findUserByEmail = (email) =>
  User.findOne({ email }).collation({ locale: "en", strength: 2 });

router.post("/register", async (req, res) => {
  try {
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

    sendWelcomeEmail({ to: user.email, name: user.name }).catch((mailErr) =>
      console.error("Welcome email error:", mailErr.message),
    );

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

router.post("/forgot-password", async (req, res) => {
  const genericResponse = {
    success: true,
    message: "If this email is registered, an OTP has been sent.",
  };

  try {
    const email = String(req.body.email || "").trim();
    if (!email) {
      return res.json({ success: false, message: "Email is required" });
    }

    const user = await findUserByEmail(email);
    if (!user) {
      return res.json(genericResponse);
    }

    if (user.resetOtpExpires) {
      const sentAt =
        user.resetOtpExpires.getTime() - OTP_EXPIRY_MINUTES * 60 * 1000;
      const waitMs = OTP_RESEND_SECONDS * 1000 - (Date.now() - sentAt);
      if (waitMs > 0) {
        return res.json({
          success: false,
          message: `Please wait ${Math.ceil(waitMs / 1000)}s before requesting a new OTP`,
        });
      }
    }

    const otp = String(crypto.randomInt(100000, 1000000));

    user.resetOtpHash = hashOtp(otp);
    user.resetOtpExpires = new Date(
      Date.now() + OTP_EXPIRY_MINUTES * 60 * 1000,
    );
    user.resetOtpAttempts = 0;
    await user.save();

    try {
      await sendOtpEmail({
        to: user.email,
        name: user.name,
        otp,
        expiresInMinutes: OTP_EXPIRY_MINUTES,
      });
    } catch (mailErr) {
      console.error("OTP email error:", mailErr);
      user.resetOtpHash = null;
      user.resetOtpExpires = null;
      await user.save();
      return res
        .status(500)
        .json({ success: false, message: "Could not send email. Try again." });
    }

    return res.json(genericResponse);
  } catch (err) {
    console.error("Forgot password error:", err);
    return res.status(500).json({ success: false, message: "Server error" });
  }
});

router.post("/reset-password", async (req, res) => {
  try {
    const email = String(req.body.email || "").trim();
    const otp = String(req.body.otp || "").trim();
    const newPassword = String(req.body.newPassword || "");

    if (!email || !otp || !newPassword) {
      return res.json({ success: false, message: "All fields required" });
    }

    if (newPassword.length < MIN_PASSWORD_LENGTH) {
      return res.json({
        success: false,
        message: `Password must be at least ${MIN_PASSWORD_LENGTH} characters`,
      });
    }

    const user = await findUserByEmail(email);
    if (!user || !user.resetOtpHash || !user.resetOtpExpires) {
      return res.json({ success: false, message: "Invalid or expired OTP" });
    }

    if (user.resetOtpExpires.getTime() < Date.now()) {
      user.resetOtpHash = null;
      user.resetOtpExpires = null;
      user.resetOtpAttempts = 0;
      await user.save();
      return res.json({
        success: false,
        message: "OTP expired. Request a new one.",
      });
    }

    if (user.resetOtpAttempts >= OTP_MAX_ATTEMPTS) {
      user.resetOtpHash = null;
      user.resetOtpExpires = null;
      user.resetOtpAttempts = 0;
      await user.save();
      return res.json({
        success: false,
        message: "Too many wrong attempts. Request a new OTP.",
      });
    }

    const given = Buffer.from(hashOtp(otp));
    const stored = Buffer.from(user.resetOtpHash);
    const match =
      given.length === stored.length && crypto.timingSafeEqual(given, stored);

    if (!match) {
      user.resetOtpAttempts += 1;
      await user.save();
      return res.json({ success: false, message: "Invalid OTP" });
    }

    user.password = newPassword;
    user.resetOtpHash = null;
    user.resetOtpExpires = null;
    user.resetOtpAttempts = 0;
    await user.save();

    return res.json({
      success: true,
      message: "Password reset successful. Please login.",
    });
  } catch (err) {
    console.error("Reset password error:", err);
    return res.status(500).json({ success: false, message: "Server error" });
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
