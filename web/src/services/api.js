const BASE_URL = import.meta.env.VITE_API_URL;

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

  forgotPassword: async (email) => {
    return requestJson("/forgot-password", {
      method: "POST",
      body: JSON.stringify({ email }),
    });
  },

  resetPassword: async (data) => {
    return requestJson("/reset-password", {
      method: "POST",
      body: JSON.stringify(data),
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
