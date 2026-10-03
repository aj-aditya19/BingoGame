import { useState } from "react";
import { api } from "../services/api";
import "../styles/Register.css";

export default function Register({ onRegister, onLogin }) {
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
        if (onRegister) onRegister(res.user || res.data?.user);
      } else {
        alert(res.message || "Registration failed");
      }
    } catch (err) {
      console.error("Registration error:", err);
      alert("Error registering. Check console for details.");
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

        <p className="register-text">
          Already have an account?{" "}
          <span className="register-link" onClick={onLogin}>
            Login
          </span>
        </p>
      </div>
    </div>
  );
}
