import { useState } from "react";
import { api } from "../services/api";
import { auth, googleProvider } from "../services/firebase";
import { signInWithPopup } from "firebase/auth";
import "../styles/Register.css";

export default function Register({ onRegister }) {
  const [form, setForm] = useState({
    name: "",
    email: "",
    password: "",
  });

  const handleChange = (e) => {
    setForm({ ...form, [e.target.name]: e.target.value });
  };

  const handleRegister = async (e) => {
    e.preventDefault();

    if (!form.password) {
      alert("Password is required");
      return;
    }

    try {
      const res = await api.register(form);
      if (res.success) {
        // ✅ check if onRegister exists
        if (onRegister) onRegister();
      } else {
        alert(res.message || "Registration failed");
      }
    } catch (err) {
      console.error("Registration error:", err);
      alert("Error registering. Check console for details.");
    }
  };

  const handleGoogleRegister = async () => {
    try {
      const result = await signInWithPopup(auth, googleProvider);
      const token = await result.user.getIdToken();

      const res = await api.googleAuth(token);

      if (res.success) {
        localStorage.setItem("user", JSON.stringify(res.user));
        if (onRegister) onRegister();
      } else {
        alert(res.message || "Google login failed");
      }
    } catch (err) {
      console.error("Google login error:", err);
      alert("Google login failed. Check console.");
    }
  };

  return (
    <div className="register-container">
      <div className="register-card">
        <h2 className="register-title">Create Account</h2>

        <form className="register-form" onSubmit={handleRegister}>
          <input
            className="register-input"
            name="name"
            placeholder="Name"
            onChange={handleChange}
            required
          />
          <input
            className="register-input"
            name="email"
            placeholder="Email"
            onChange={handleChange}
            required
          />
          <input
            className="register-input"
            name="password"
            type="password"
            placeholder="Password"
            onChange={handleChange}
            required
          />
          <button type="submit" className="register-btn">
            Register
          </button>
        </form>

        <div className="divider"></div>

        <button className="google-register-btn" onClick={handleGoogleRegister}>
          Continue with Google
        </button>
      </div>
    </div>
  );
}
