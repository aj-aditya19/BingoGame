import React, { useState } from "react";
import { api } from "../services/api";
import "../styles/Login.css";

const Login = ({ onLogin, onRegister, onForgotPassword }) => {
  const [form, setForm] = useState({
    email: "",
    password: "",
  });

  const handleChange = (e) => {
    setForm({
      ...form,
      [e.target.name]: e.target.value,
    });
  };

  const handleLogin = async (e) => {
    e.preventDefault();

    const res = await api.login(form);
    if (res.success) {
      onLogin(res.user || res.data?.user);
    }
  };

  return (
    <div className="login-container">
      <div className="login-card">
        <h2 className="login-title">Login</h2>

        <form className="login-form" onSubmit={handleLogin}>
          <input
            className="login-input"
            name="email"
            placeholder="Email"
            value={form.email}
            onChange={handleChange}
          />
          <div className="login-password-container">
            In case login failed: enter email as password
          </div>
          <div className="login-password-container">
            For example: if email is "john@example.com", use "john" as the
            password
          </div>
          <input
            className="login-input"
            name="password"
            type="password"
            placeholder="Password"
            value={form.password}
            onChange={handleChange}
          />

          <button type="submit" className="login-btn">
            Login
          </button>

          <span className="forgot-link" onClick={onForgotPassword}>
            Forgot password?
          </span>
        </form>

        <p className="register-text">
          New user?{" "}
          <span className="register-link" onClick={onRegister}>
            Register
          </span>
        </p>
      </div>
    </div>
  );
};

export default Login;
