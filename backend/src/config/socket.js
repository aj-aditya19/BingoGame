// import { rooms } from "../routes/game.route.js";
// import User from "../database/User.js";

// const BOT_ROLE = "Bot";

// const getBotSocketId = (roomId, userId) => `bot:${roomId}:${userId}`;

// const isBotUser = (user) => user?.role === BOT_ROLE;

// const upsertRoomPlayer = (room, user, socketId, roomId) => {
//   const existingPlayer = room.players.find(
//     (player) => player.userId === user._id,
//   );
//   const storedSocketId = isBotUser(user)
//     ? getBotSocketId(roomId, user._id)
//     : socketId;

//   if (existingPlayer) {
//     existingPlayer.socketId = storedSocketId;
//     existingPlayer.name = user.name ?? existingPlayer.name;
//     existingPlayer.grid = user.grid ?? existingPlayer.grid;
//     existingPlayer.role = user.role ?? existingPlayer.role;
//     return;
//   }

//   if (room.players.length >= 2) {
//     console.log("Room full, cannot join", user._id);
//     return;
//   }

//   room.players.push({
//     userId: user._id,
//     name: user.name ?? "Unknown",
//     socketId: storedSocketId,
//     grid: user.grid ?? [],
//     playerNo: room.players.length + 1,
//     role: user.role ?? "Invited",
//   });
// };

// const getNextPlayer = (players, currentUserId) =>
//   players.find((player) => player.userId !== currentUserId);

// const updateStatsOnResult = async (winnerId, loserId) => {
//   try {
//     if (winnerId) {
//       await User.findByIdAndUpdate(winnerId, {
//         $inc: {
//           win: 1,
//           gamesPlayed: 1,
//         },
//       });
//     }

//     if (loserId) {
//       await User.findByIdAndUpdate(loserId, {
//         $inc: {
//           loss: 1,
//           gamesPlayed: 1,
//         },
//       });
//     }
//   } catch (err) {
//     console.log("Error updating stats:", err);
//   }
// };

// const initSocket = (io) => {
//   io.on("connection", (socket) => {
//     console.log("User connected:", socket.id);

//     socket.on("join-room", async ({ roomId, user }) => {
//       const room = rooms.get(roomId);
//       if (!room) return;

//       upsertRoomPlayer(room, user, socket.id, roomId);

//       socket.join(roomId);
//       io.to(roomId).emit("room-joined", room.players);
//       if (!isBotUser(user)) {
//         try {
//           await User.findByIdAndUpdate(user._id, { lastLogin: new Date() });
//         } catch (err) {
//           console.log("Error updating lastLogin:", err);
//         }
//       }
//     });

//     /* ================= START GAME ================= */
//     socket.on("start-game", ({ roomId }) => {
//       const room = rooms.get(roomId);
//       if (!room || room.players.length !== 2) return;

//       room.started = true;
//       room.winnerUserId = null;
//       const firstPlayer =
//         room.players.find((p) => p.role === "Host") || room.players[0];
//       room.turnUserId = firstPlayer.userId;
//       console.log("Turn User ID: ", room.turnUserId);

//       io.to(roomId).emit("game-start", {
//         turnUserId: room.turnUserId,
//       });
//     });

//     /* ================= SELECT NUMBER ================= */
//     socket.on("game:select-number", ({ roomId, number, userId }) => {
//       const room = rooms.get(roomId);
//       if (!room || room.turnUserId !== userId) return;

//       io.to(roomId).emit("game:update", { number });

//       if (room.players.length < 2) {
//         console.log("⚠️ Waiting for opponent");
//         return;
//       }
//       const nextPlayer = getNextPlayer(room.players, userId);

//       if (!nextPlayer) {
//         console.log("⚠️ No next player found");
//         return;
//       }

//       room.turnUserId = nextPlayer.userId;
//       io.to(roomId).emit("game:turn", { userId: room.turnUserId });
//     });

//     socket.on("game:win", async ({ roomId, userId }) => {
//       const room = rooms.get(roomId);
//       if (!room || room.winnerUserId) return;

//       room.winnerUserId = userId;

//       io.to(roomId).emit("game:win", { userId });

//       const winner = room.players.find((p) => p.userId === userId);
//       const loser = room.players.find((p) => p.userId !== userId);

//       await updateStatsOnResult(winner?.userId, loser?.userId);

//       setTimeout(() => {
//         rooms.delete(roomId);
//         console.log("Room deleted:", roomId);
//       }, 7000);
//     });

//     socket.on("leave-room", ({ roomId }) => {
//       const room = rooms.get(roomId);
//       if (!room) return;

//       socket.leave(roomId);

//       room.players = room.players.filter((p) => p.socketId !== socket.id);

//       io.to(roomId).emit("room-joined", room.players);

//       if (room.players.length === 0) {
//         rooms.delete(roomId);
//         console.log("🧹 Room deleted (empty):", roomId);
//       }

//       console.log("👋 socket left room:", roomId);
//     });

//     /* ================= DISCONNECT ================= */
//     socket.on("disconnect", async () => {
//       console.log("Socket disconnected:", socket.id);

//       for (const [roomId, room] of rooms.entries()) {
//         const player = room.players.find((p) => p.socketId === socket.id);

//         if (!player) continue;

//         console.log("Temporary disconnect for user:", player.userId);

//         setTimeout(async () => {
//           const stillExists = room.players.find(
//             (p) => p.userId === player.userId,
//           );

//           if (stillExists && stillExists.socketId !== socket.id) {
//             console.log("User reconnected, not removing");
//             return;
//           }

//           room.players = room.players.filter((p) => p.userId !== player.userId);

//           io.to(roomId).emit("room-joined", room.players);

//           if (room.started && room.players.length === 1) {
//             const winnerId = room.players[0].userId;

//             io.to(roomId).emit("game:win", { userId: winnerId });

//             await updateStatsOnResult(winnerId, player.userId);

//             console.log("Win/Loss updated due to disconnect");

//             rooms.delete(roomId);
//             console.log("Room deleted after disconnect win:", roomId);
//           }

//           if (room.players.length === 0) {
//             rooms.delete(roomId);
//             console.log("Room deleted (empty):", roomId);
//           }
//         }, 5000);
//       }
//     });
//   });
// };

// export default initSocket;

import { rooms } from "../routes/game.route.js";
import User from "../database/User.js";

const BOT_ROLE = "Bot";

const getBotSocketId = (roomId, userId) => `bot:${roomId}:${userId}`;

const isBotUser = (user) => user?.role === BOT_ROLE;

const upsertRoomPlayer = (room, user, socketId, roomId) => {
  const existingPlayer = room.players.find(
    (player) => player.userId === user._id,
  );
  const storedSocketId = isBotUser(user)
    ? getBotSocketId(roomId, user._id)
    : socketId;

  if (existingPlayer) {
    existingPlayer.socketId = storedSocketId;
    existingPlayer.name = user.name ?? existingPlayer.name;
    existingPlayer.grid = user.grid ?? existingPlayer.grid;
    existingPlayer.role = user.role ?? existingPlayer.role;
    return;
  }

  if (room.players.length >= 2) {
    console.log("Room full, cannot join", user._id);
    return;
  }

  room.players.push({
    userId: user._id,
    name: user.name ?? "Unknown",
    socketId: storedSocketId,
    grid: user.grid ?? [],
    playerNo: room.players.length + 1,
    role: user.role ?? "Invited",
  });
};

const getNextPlayer = (players, currentUserId) =>
  players.find((player) => player.userId !== currentUserId);

const updateStatsOnResult = async (winnerId, loserId) => {
  try {
    if (winnerId) {
      await User.findByIdAndUpdate(winnerId, {
        $inc: {
          win: 1,
          gamesPlayed: 1,
        },
      });
    }

    if (loserId) {
      await User.findByIdAndUpdate(loserId, {
        $inc: {
          loss: 1,
          gamesPlayed: 1,
        },
      });
    }
  } catch (err) {
    console.log("Error updating stats:", err);
  }
};

const initSocket = (io) => {
  io.on("connection", (socket) => {
    console.log("User connected:", socket.id);

    socket.on("join-room", async ({ roomId, user }) => {
      const room = rooms.get(roomId);
      if (!room) return;

      upsertRoomPlayer(room, user, socket.id, roomId);

      socket.join(roomId);
      io.to(roomId).emit("room-joined", room.players);
      if (!isBotUser(user)) {
        try {
          await User.findByIdAndUpdate(user._id, { lastLogin: new Date() });
        } catch (err) {
          console.log("Error updating lastLogin:", err);
        }
      }
    });

    /* ================= START GAME ================= */
    socket.on("start-game", ({ roomId }) => {
      const room = rooms.get(roomId);
      if (!room || room.players.length !== 2) return;

      room.started = true;
      room.winnerUserId = null;
      const firstPlayer =
        room.players.find((p) => p.role === "Host") || room.players[0];
      room.turnUserId = firstPlayer.userId;
      console.log("Turn User ID: ", room.turnUserId);

      io.to(roomId).emit("game-start", {
        turnUserId: room.turnUserId,
      });
    });

    /* ================= SELECT NUMBER ================= */
    socket.on("game:select-number", ({ roomId, number, userId }) => {
      const room = rooms.get(roomId);
      if (!room || room.turnUserId !== userId) return;

      io.to(roomId).emit("game:update", { number });

      if (room.players.length < 2) {
        console.log("⚠️ Waiting for opponent");
        return;
      }
      const nextPlayer = getNextPlayer(room.players, userId);

      if (!nextPlayer) {
        console.log("⚠️ No next player found");
        return;
      }

      room.turnUserId = nextPlayer.userId;
      io.to(roomId).emit("game:turn", { userId: room.turnUserId });
    });

    socket.on("game:win", async ({ roomId, userId }) => {
      const room = rooms.get(roomId);
      if (!room || room.winnerUserId) return;

      room.winnerUserId = userId;

      io.to(roomId).emit("game:win", { userId });

      const winner = room.players.find((p) => p.userId === userId);
      const loser = room.players.find((p) => p.userId !== userId);

      await updateStatsOnResult(winner?.userId, loser?.userId);

      setTimeout(() => {
        rooms.delete(roomId);
        console.log("Room deleted:", roomId);
      }, 7000);
    });

    /* ================= CHAT MESSAGE ================= */
    // Simple chat: one player sends a message, everyone else in the
    // same room (roomId) receives it.
    socket.on("chat:send", ({ roomId, message, senderId, senderName }) => {
      if (!roomId || !message) return;

      // send the message to everyone in that room (including sender,
      // so the sender also sees it appear in the chat box)
      io.to(roomId).emit("chat:receive", {
        message,
        senderId,
        senderName,
        time: new Date().toLocaleTimeString([], {
          hour: "2-digit",
          minute: "2-digit",
        }),
      });
    });

    socket.on("leave-room", ({ roomId }) => {
      const room = rooms.get(roomId);
      if (!room) return;

      socket.leave(roomId);

      room.players = room.players.filter((p) => p.socketId !== socket.id);

      io.to(roomId).emit("room-joined", room.players);

      if (room.players.length === 0) {
        rooms.delete(roomId);
        console.log("🧹 Room deleted (empty):", roomId);
      }

      console.log("👋 socket left room:", roomId);
    });

    /* ================= DISCONNECT ================= */
    socket.on("disconnect", async () => {
      console.log("Socket disconnected:", socket.id);

      for (const [roomId, room] of rooms.entries()) {
        const player = room.players.find((p) => p.socketId === socket.id);

        if (!player) continue;

        console.log("Temporary disconnect for user:", player.userId);

        setTimeout(async () => {
          const stillExists = room.players.find(
            (p) => p.userId === player.userId,
          );

          if (stillExists && stillExists.socketId !== socket.id) {
            console.log("User reconnected, not removing");
            return;
          }

          room.players = room.players.filter((p) => p.userId !== player.userId);

          io.to(roomId).emit("room-joined", room.players);

          if (room.started && room.players.length === 1) {
            const winnerId = room.players[0].userId;

            io.to(roomId).emit("game:win", { userId: winnerId });

            await updateStatsOnResult(winnerId, player.userId);

            console.log("Win/Loss updated due to disconnect");

            rooms.delete(roomId);
            console.log("Room deleted after disconnect win:", roomId);
          }

          if (room.players.length === 0) {
            rooms.delete(roomId);
            console.log("Room deleted (empty):", roomId);
          }
        }, 5000);
      }
    });
  });
};

export default initSocket;
