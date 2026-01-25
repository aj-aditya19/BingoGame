import { rooms } from "../routes/game.route.js";

const initSocket = (io) => {
  io.on("connection", (socket) => {
    console.log("User connected:", socket.id);

    socket.on("join-room", ({ roomId, user }) => {
      const room = rooms.get(roomId);
      if (!room) return;

      // ❌ duplicate join prevent
      const existing = room.players.find((p) => p.userId === user.id);
      if (existing) {
        existing.socketId = socket.id;
        existing.name = user.name ?? existing.name;
        existing.grid = user.grid ?? existing.grid;
        existing.role = user.role ?? existing.role;
      } else {
        if (room.players.length >= 2) {
          console.log("Room full, cannot join", user.id);
          return;
        }

        room.players.push({
          userId: user.id,
          name: user.name ?? "Unknown",
          socketId: socket.id,
          grid: user.grid ?? [],
          playerNo: room.players.length + 1,
          role: user.role ?? "Invited",
        });
      }

      socket.join(roomId);
      io.to(roomId).emit("room-joined", room.players);
    });

    /* ================= START GAME ================= */
    socket.on("start-game", ({ roomId }) => {
      const room = rooms.get(roomId);
      if (!room || room.players.length !== 2) return;

      room.started = true;
      room.winnerUserId = null;
      // ✅ Player 1 always starts
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

      // Emit number update
      io.to(roomId).emit("game:update", { number });

      // Find next player safely
      if (room.players.length < 2) {
        console.log("⚠️ Waiting for opponent");
        return;
      }
      const nextPlayer = room.players.find((p) => p.userId !== userId);

      if (!nextPlayer) {
        console.log("⚠️ No next player found");
        return;
      }

      room.turnUserId = nextPlayer.userId;
      io.to(roomId).emit("game:turn", { userId: room.turnUserId });
    });

    socket.on("game:win", ({ roomId, userId }) => {
      const room = rooms.get(roomId);
      if (!room || room.winnerUserId) return;

      room.winnerUserId = userId;

      io.to(roomId).emit("game:win", { userId });

      // 🧹 CLEANUP after 3 seconds
      setTimeout(() => {
        rooms.delete(roomId);
        console.log("Room deleted:", roomId);
      }, 7000);
    });
    socket.on("leave-room", ({ roomId }) => {
      const room = rooms.get(roomId);
      if (!room) return;

      socket.leave(roomId);

      // remove player from room
      room.players = room.players.filter((p) => p.socketId !== socket.id);

      io.to(roomId).emit("room-joined", room.players);

      // agar room empty ho gaya to delete
      if (room.players.length === 0) {
        rooms.delete(roomId);
        console.log("🧹 Room deleted (empty):", roomId);
      }

      console.log("👋 socket left room:", roomId);
    });

    /* ================= DISCONNECT ================= */
    socket.on("disconnect", () => {
      for (const [roomId, room] of rooms.entries()) {
        const leftPlayer = room.players.find((p) => p.socketId === socket.id);

        if (leftPlayer) {
          socket.leave(roomId); // 👈 add this
          room.players = room.players.filter((p) => p.socketId !== socket.id);

          if (room.started && room.players.length === 1) {
            io.to(roomId).emit("game:win", {
              userId: room.players[0].userId,
            });
            rooms.delete(roomId);
          }
        }
      }
    });
  });
};

export default initSocket;
