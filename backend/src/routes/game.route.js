import express from "express";

const router = express.Router();
const rooms = new Map();

const genRoomId = () => Math.random().toString(36).substring(2, 9);

// CREATE ROOM
router.post("/room/create", (req, res) => {
  console.log("In creating room");

  const roomId = genRoomId();

  rooms.set(roomId, {
    roomId,
    players: [],
    hostUserId: null,
    grids: {},
    turnIndex: 0,
    started: false,
  });

  res.json({ success: true, roomId });
});

// JOIN ROOM
router.post("/room/join", (req, res) => {
  const { roomId } = req.body;
  const room = rooms.get(roomId);

  if (!room) return res.json({ success: false, message: "Room not found" });

  if (room.players.length >= 2)
    return res.json({ success: false, message: "Room full" });

  res.json({ success: true });
});

export { rooms };
export default router;
