const BASE_URL = import.meta.env.VITE_API_URL || "http://localhost:5000/api";

const requestJson = async (path, options = {}) => {
  const response = await fetch(`${BASE_URL}${path}`, {
    headers: {
      "Content-Type": "application/json",
      ...(options.headers || {}),
    },
    credentials: "include",
    ...options,
  });

  return response.json();
};

export const api = {
  login: async (data) => {
    return requestJson("/login", {
      method: "POST",
      body: JSON.stringify(data),
    });
  },

  register: async (data) => {
    return requestJson("/register", {
      method: "POST",
      body: JSON.stringify(data),
    });
  },

  googleAuth: async (token) => {
    return requestJson("/google", {
      method: "POST",
      body: JSON.stringify({ token }),
    });
  },
};
export const gameApi = {
  createRoom: async () => {
    console.log("In creating a Room");

    return requestJson("/game/room/create", {
      method: "POST",
    });
  },

  joinRoom: async (roomId) => {
    return requestJson("/game/room/join", {
      method: "POST",
      body: JSON.stringify({ roomId }),
    });
  },
};
