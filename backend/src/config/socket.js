import { rooms } from "../routes/game.route.js";

export default function initSocket(io) {
  io.on("connection", (socket) => {
    console.log("Socket connected:", socket.id);

    // ================= JOIN ROOM =================
    socket.on("join-room", ({ roomId, user }) => {
      const room = rooms.get(roomId);
      if (!room) return;

      // prevent duplicate
      const alreadyJoined = room.players.find((p) => p.id === user.id);
      if (alreadyJoined) return;

      socket.join(roomId);

      room.players.push({
        id: user.id,
        name: user.name,
        socketId: socket.id,
      });

      room.grids[user.id] = user.grid.flat();

      io.to(roomId).emit("room-joined", room.players); // broadcast to both
    });

    // ================= START GAME =================
    socket.on("start-game", ({ roomId }) => {
      const room = rooms.get(roomId);
      if (!room || room.players.length < 2) return;

      room.started = true;
      room.turnIndex = Math.floor(Math.random() * 2);

      io.to(roomId).emit("game-start", {
        currentTurn: room.players[room.turnIndex].id,
      });
    });

    // ================= MARK NUMBER =================
    socket.on("mark-number", ({ roomId, userId, value }) => {
      const room = rooms.get(roomId);
      if (!room) return;

      const currentPlayer = room.players[room.turnIndex];
      if (currentPlayer.id !== userId) return;

      Object.keys(room.grids).forEach((uid) => {
        room.grids[uid] = room.grids[uid].map((cell) =>
          cell.value === value && !cell.marked
            ? { ...cell, marked: true }
            : cell,
        );
      });

      room.turnIndex = room.turnIndex === 0 ? 1 : 0;

      io.to(roomId).emit("grid-update", {
        grids: room.grids,
        nextTurn: room.players[room.turnIndex].id,
        markedValue: value,
      });
    });

    // ================= DISCONNECT =================
    socket.on("disconnect", () => {
      console.log("Socket disconnected:", socket.id);
    });
  });
}
