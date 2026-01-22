import { rooms } from "../routes/game.route.js";

const initSocket = (io) => {
  io.on("connection", (socket) => {
    console.log("User connected:", socket.id);

    socket.on("join-room", ({ roomId, user }) => {
      const room = rooms.get(roomId);
      if (!room) return;

      // ❌ duplicate join prevent
      const alreadyJoined = room.players.find((p) => p.socketId === socket.id);
      if (alreadyJoined) return;

      if (room.players.length >= 2) return;
      // ✅ join socket room
      socket.join(roomId);

      // ✅ add player
      const playerNo = room.players.length + 1;

      room.players.push({
        userId: user.id,
        name: user.name,
        socketId: socket.id,
        grid: user.grid,
        playerNo,
      });
      console.log("Room:", roomId, room.players);

      // 🔥 SEND UPDATED PLAYERS TO BOTH USERS
      io.to(roomId).emit("room-joined", room.players);
    });

    /* ================= START GAME ================= */
    socket.on("start-game", ({ roomId }) => {
      const room = rooms.get(roomId);
      if (!room || room.players.length !== 2) return;

      room.started = true;

      // ✅ Player 1 always starts
      const firstPlayer = room.players.find((p) => p.playerNo === 1);
      room.turnUserId = firstPlayer.userId;

      io.to(roomId).emit("game-start", {
        turnUserId: room.turnUserId,
      });
    });

    /* ================= SELECT NUMBER ================= */
    socket.on("game:select-number", ({ roomId, number, userId }) => {
      const room = rooms.get(roomId);
      if (!room || room.turnUserId !== userId) return;

      io.to(roomId).emit("game:update", { number });

      const nextPlayer = room.players.find((p) => p.userId !== userId);
      room.turnUserId = nextPlayer.userId;

      io.to(roomId).emit("game:turn", { userId: room.turnUserId });
    });

    socket.on("game:win", ({ roomId, userId }) => {
      const room = rooms.get(roomId);
      if (!room || room.winnerUserId) return;

      room.winnerUserId = userId;
      io.to(roomId).emit("game:win", { userId });
    });

    /* ================= DISCONNECT ================= */
    socket.on("disconnect", () => {
      for (const [roomId, room] of rooms.entries()) {
        const idx = room.players.findIndex((p) => p.socketId === socket.id);

        if (idx !== -1) {
          room.players.splice(idx, 1);
          io.to(roomId).emit("room-joined", room.players);
        }
      }
    });
  });
};

export default initSocket;
