import React, { useState } from "react";
import { socket } from "../services/socket";
import { gameApi } from "../services/api"; // ✅ THIS WAS MISSING

const JoinRoom = ({ grid, user, onJoined }) => {
  const [roomId, setRoomId] = useState("");

  const joinRoom = async () => {
    const res = await gameApi.joinRoom(roomId);

    if (!res.success) {
      alert(res.message);
      return;
    }

    socket.emit("join-room", {
      roomId,
      user: {
        id: user._id,
        name: user.name,
        grid,
        role: "Invited",
      },
    });

    onJoined(roomId);
  };

  return (
    <div style={{ maxWidth: 360, margin: "40px auto", textAlign: "center" }}>
      <h3>Join Room</h3>

      <input
        placeholder="Enter Room ID"
        value={roomId}
        onChange={(e) => setRoomId(e.target.value)}
        style={{
          width: "100%",
          padding: 10,
          fontSize: 16,
          marginBottom: 10,
        }}
      />

      <button onClick={joinRoom} style={{ width: "100%" }}>
        Join Game
      </button>
    </div>
  );
};

export default JoinRoom;
