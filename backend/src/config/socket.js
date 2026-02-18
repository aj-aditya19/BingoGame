import { rooms } from "../routes/game.route.js";
import User from "../database/User.js";

const initSocket = (io) => {
  io.on("connection", (socket) => {
    console.log("User connected:", socket.id);

    socket.on("join-room", async ({ roomId, user }) => {
      const room = rooms.get(roomId);
      if (!room) return;

      // ❌ duplicate join prevent
      const existing = room.players.find((p) => p.userId === user._id);
      if (existing) {
        existing.socketId = socket.id;
        existing.name = user.name ?? existing.name;
        existing.grid = user.grid ?? existing.grid;
        existing.role = user.role ?? existing.role;
      } else {
        if (room.players.length >= 2) {
          console.log("Room full, cannot join", user._id);
          return;
        }

        room.players.push({
          userId: user._id,
          name: user.name ?? "Unknown",
          socketId: socket.id,
          grid: user.grid ?? [],
          playerNo: room.players.length + 1,
          role: user.role ?? "Invited",
        });
      }

      socket.join(roomId);
      io.to(roomId).emit("room-joined", room.players);
      try {
        await User.findByIdAndUpdate(user._id, { lastLogin: new Date() });
      } catch (err) {
        console.log("Error updating lastLogin:", err);
      }
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

    socket.on("game:win", async ({ roomId, userId }) => {
      const room = rooms.get(roomId);
      if (!room || room.winnerUserId) return;

      room.winnerUserId = userId;

      io.to(roomId).emit("game:win", { userId });

      const winner = room.players.find((p) => p.userId === userId);
      const loser = room.players.find((p) => p.userId !== userId);

      try {
        if (winner) {
          await User.findByIdAndUpdate(winner.userId, {
            $inc: { win: 1, gamesPlayed: 1 },
          });
        }

        if (loser) {
          await User.findByIdAndUpdate(loser.userId, {
            $inc: { loss: 1, gamesPlayed: 1 },
          });
        }
      } catch (err) {
        console.log("Error updating stats:", err);
      }

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

          // If user reconnected (socketId changed), do nothing
          if (stillExists && stillExists.socketId !== socket.id) {
            console.log("User reconnected, not removing");
            return;
          }

          // Remove permanently
          room.players = room.players.filter((p) => p.userId !== player.userId);

          io.to(roomId).emit("room-joined", room.players);

          // 🎯 If game started & only 1 left → give win
          if (room.started && room.players.length === 1) {
            const winnerId = room.players[0].userId;

            io.to(roomId).emit("game:win", { userId: winnerId });

            try {
              await User.findByIdAndUpdate(winnerId, {
                $inc: { win: 1, gamesPlayed: 1 },
              });

              await User.findByIdAndUpdate(player.userId, {
                $inc: { loss: 1, gamesPlayed: 1 },
              });

              console.log("Win/Loss updated due to disconnect");
            } catch (err) {
              console.log("Error updating disconnect stats:", err);
            }

            rooms.delete(roomId);
            console.log("Room deleted after disconnect win:", roomId);
          }

          // If empty
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
