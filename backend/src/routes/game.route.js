import express from "express";

const router = express.Router();

// in-memory rooms
const rooms = new Map();

const genRoomId = () => Math.random().toString(36).substring(2, 9);

// CREATE ROOM
router.post("/create-room", (req, res) => {
  const roomId = genRoomId();

  rooms.set(roomId, {
    roomId,
    players: [],
    grids: {},
    turnIndex: 0,
    started: false,
  });

  res.json({ success: true, roomId });
});

// JOIN ROOM
router.post("/join-room", (req, res) => {
  const { roomId } = req.body;
  const room = rooms.get(roomId);

  if (!room) return res.json({ success: false, message: "Room not found" });

  if (room.players.length >= 2)
    return res.json({ success: false, message: "Room full" });

  res.json({ success: true });
});

export { rooms };
export default router;
