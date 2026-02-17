// import React, { useState } from "react";
// import { api } from "../services/api";

// const SetPassword = ({ onDone }) => {
//   const [password, setPassword] = useState("");

//   const savePassword = async () => {
//     if (!password) {
//       alert("Password required");
//       return;
//     }

//     const res = await api.setPassword(password);
//     if (res.success) {
//       onDone();
//     }
//   };

//   return (
//     <div style={{ padding: 40 }}>
//       <h3>Set Password</h3>
//       <p>Use this password for future email logins</p>

//       <input
//         type="password"
//         placeholder="New password"
//         value={password}
//         onChange={(e) => setPassword(e.target.value)}
//       />

//       <button onClick={savePassword}>Save</button>
//     </div>
//   );
// };

// export default SetPassword;

import React, { useState } from "react";
import { api } from "../services/api";
import "../styles/SetPassword.css";

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
    <div className="setpass-container">
      <div className="setpass-card">
        <h3 className="setpass-title">Set Password</h3>
        <p className="setpass-sub">Use this password for future email logins</p>

        <input
          className="setpass-input"
          type="password"
          placeholder="New password"
          value={password}
          onChange={(e) => setPassword(e.target.value)}
        />

        <button className="setpass-btn" onClick={savePassword}>
          Save Password
        </button>
      </div>
    </div>
  );
};

export default SetPassword;
