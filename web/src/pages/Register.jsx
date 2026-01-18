import { useState } from "react";
import { api } from "../services/api";
import { auth, googleProvider } from "../services/firebase";
import { signInWithPopup } from "firebase/auth";

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

    const res = await api.register(form);
    if (res.success) {
      onRegister();
    }
  };

  const handleGoogleRegister = async () => {
    const result = await signInWithPopup(auth, googleProvider);
    const token = await result.user.getIdToken();

    const res = await api.googleAuth(token);

    if (res.success) {
      if (res.needPassword) {
        onRegister("set-password"); // 🔥 IMPORTANT
      } else {
        onRegister("input");
      }
    }
  };

  return (
    <div style={{ padding: 40 }}>
      <h2>Register</h2>

      <form onSubmit={handleRegister}>
        <input
          name="name"
          placeholder="Name"
          onChange={handleChange}
          required
        />

        <input
          name="email"
          placeholder="Email"
          onChange={handleChange}
          required
        />

        <input
          name="password"
          type="password"
          placeholder="Password"
          onChange={handleChange}
          required
        />

        <button type="submit">Register</button>
      </form>

      <hr />

      <button onClick={handleGoogleRegister}>Register with Google</button>
    </div>
  );
}
