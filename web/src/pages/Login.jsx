import React, { useState } from "react";
import { api } from "../services/api";
import { auth, googleProvider } from "../services/firebase";
import { signInWithPopup } from "firebase/auth";

const Login = ({ onLogin, onRegister }) => {
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
      onLogin(res.user);
      console.log("Login successful");
    }
  };

  const handleGoogleLogin = async () => {
    const result = await signInWithPopup(auth, googleProvider);
    const token = await result.user.getIdToken();

    const res = await api.googleAuth(token);
    if (res.success) {
      onLogin(res.user.email);
    }
  };

  return (
    <div style={{ padding: 40 }}>
      <h2>Login</h2>

      <form onSubmit={handleLogin}>
        <input
          name="email"
          placeholder="Email"
          value={form.email}
          onChange={handleChange}
        />

        <input
          name="password"
          type="password"
          placeholder="Password"
          value={form.password}
          onChange={handleChange}
        />

        <button type="submit">Login</button>
      </form>

      <hr />

      <button onClick={handleGoogleLogin}>Login with Google</button>

      <p style={{ marginTop: 16 }}>
        New user?{" "}
        <span
          onClick={onRegister}
          style={{
            color: "blue",
            cursor: "pointer",
            textDecoration: "underline",
          }}
        >
          Register
        </span>
      </p>
    </div>
  );
};

export default Login;
