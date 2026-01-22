const BASE_URL = "http://localhost:5000/api";

export const api = {
  login: async (data) => {
    const res = await fetch(`${BASE_URL}/login`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      credentials: "include",
      body: JSON.stringify(data),
    });
    return res.json();
  },

  register: async (data) => {
    const res = await fetch(`${BASE_URL}/register`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      credentials: "include",
      body: JSON.stringify(data),
    });
    return res.json();
  },

  googleAuth: async (token) => {
    const res = await fetch(`${BASE_URL}/google`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      credentials: "include",
      body: JSON.stringify({ token }),
    });
    return res.json();
  },

  setPassword: async (password) => {
    const res = await fetch(`${BASE_URL}/set-password`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      credentials: "include",
      body: JSON.stringify({ password }),
    });
    return res.json();
  },

  // ===============================
  // 🎮 GAME / ROOM APIs
  // ===============================
};
export const gameApi = {
  createRoom: async () => {
    console.log("In creating a Room");

    const res = await fetch(`${BASE_URL}/game/room/create`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      credentials: "include",
    });

    return res.json();
  },

  joinRoom: async (roomId) => {
    const res = await fetch(`${BASE_URL}/game/room/join`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      credentials: "include",
      body: JSON.stringify({ roomId }),
    });

    return res.json();
  },
};
