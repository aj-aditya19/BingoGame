import React, { useState } from "react";
import { api } from "../services/api";

const SetPassword = ({ onDone }) => {
  const [password, setPassword] = useState("");

  const savePassword = async () => {
    if (!password) {
      alert("Password required");
      return;
    }

    const res = await api.setPassword(password);
    if (res.success) {
      onDone();
    }
  };

  return (
    <div style={{ padding: 40 }}>
      <h3>Set Password</h3>
      <p>Use this password for future email logins</p>

      <input
        type="password"
        placeholder="New password"
        value={password}
        onChange={(e) => setPassword(e.target.value)}
      />

      <button onClick={savePassword}>Save</button>
    </div>
  );
};

export default SetPassword;
