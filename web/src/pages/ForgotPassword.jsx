import React, { useState, useEffect } from "react";
import { api } from "../services/api";
import "../styles/Login.css";
import "../styles/ForgotPassword.css";

const RESEND_SECONDS = 60;

const ForgotPassword = ({ onBackToLogin }) => {
  const [step, setStep] = useState(1); // 1 = enter email, 2 = enter OTP + new password
  const [email, setEmail] = useState("");
  const [otp, setOtp] = useState("");
  const [newPassword, setNewPassword] = useState("");
  const [confirmPassword, setConfirmPassword] = useState("");
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");
  const [info, setInfo] = useState("");
  const [cooldown, setCooldown] = useState(0);

  useEffect(() => {
    if (cooldown <= 0) return;
    const t = setTimeout(() => setCooldown((c) => c - 1), 1000);
    return () => clearTimeout(t);
  }, [cooldown]);

  const sendOtp = async (e) => {
    if (e) e.preventDefault();
    setError("");
    setInfo("");

    if (!email.trim()) {
      setError("Please enter your email");
      return;
    }

    setLoading(true);
    try {
      const res = await api.forgotPassword(email.trim());
      if (res.success) {
        setStep(2);
        setCooldown(RESEND_SECONDS);
        setInfo("OTP sent to your email (check spam folder too).");
      } else {
        setError(res.message || "Could not send OTP");
      }
    } catch (err) {
      console.error("Forgot password error:", err);
      setError("Something went wrong. Try again.");
    } finally {
      setLoading(false);
    }
  };

  const resetPassword = async (e) => {
    e.preventDefault();
    setError("");
    setInfo("");

    if (!otp.trim() || !newPassword) {
      setError("OTP and new password are required");
      return;
    }

    if (newPassword.length < 6) {
      setError("Password must be at least 6 characters");
      return;
    }

    if (newPassword !== confirmPassword) {
      setError("Passwords do not match");
      return;
    }

    setLoading(true);
    try {
      const res = await api.resetPassword({
        email: email.trim(),
        otp: otp.trim(),
        newPassword,
      });

      if (res.success) {
        alert("Password reset successful. Please login with your new password.");
        onBackToLogin();
      } else {
        setError(res.message || "Could not reset password");
      }
    } catch (err) {
      console.error("Reset password error:", err);
      setError("Something went wrong. Try again.");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="login-container">
      <div className="login-card">
        <h2 className="login-title">Forgot Password</h2>

        {step === 1 ? (
          <form className="login-form" onSubmit={sendOtp}>
            <p className="fp-sub">
              Enter your registered email. We will send you an OTP.
            </p>
            <input
              className="login-input"
              type="email"
              placeholder="Email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
            />
            {error && <p className="fp-error">{error}</p>}
            <button type="submit" className="login-btn" disabled={loading}>
              {loading ? "Sending..." : "Send OTP"}
            </button>
          </form>
        ) : (
          <form className="login-form" onSubmit={resetPassword}>
            <p className="fp-sub">
              OTP sent to <b>{email}</b>
            </p>
            <input
              className="login-input"
              placeholder="Enter 6-digit OTP"
              inputMode="numeric"
              maxLength={6}
              value={otp}
              onChange={(e) => setOtp(e.target.value.replace(/\D/g, ""))}
            />
            <input
              className="login-input"
              type="password"
              placeholder="New password"
              value={newPassword}
              onChange={(e) => setNewPassword(e.target.value)}
            />
            <input
              className="login-input"
              type="password"
              placeholder="Confirm new password"
              value={confirmPassword}
              onChange={(e) => setConfirmPassword(e.target.value)}
            />
            {info && <p className="fp-info">{info}</p>}
            {error && <p className="fp-error">{error}</p>}
            <button type="submit" className="login-btn" disabled={loading}>
              {loading ? "Please wait..." : "Reset Password"}
            </button>

            <button
              type="button"
              className="fp-resend"
              disabled={cooldown > 0 || loading}
              onClick={() => sendOtp()}
            >
              {cooldown > 0 ? `Resend OTP in ${cooldown}s` : "Resend OTP"}
            </button>
          </form>
        )}

        <p className="register-text">
          Remember your password?{" "}
          <span className="register-link" onClick={onBackToLogin}>
            Login
          </span>
        </p>
      </div>
    </div>
  );
};

export default ForgotPassword;
