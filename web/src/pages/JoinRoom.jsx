import React, { useState } from "react";
import { socket } from "../services/socket";

const JoinRoom = ({ grid, user, onJoined }) => {
  const [roomId, setRoomId] = useState("");

  const joinRoom = () => {
    const id = roomId.trim();
    if (id.length !== 7) {
      alert("Invalid Room ID");
      return;
    }

    // ✅ emit join-room only when user clicks "Join Game"
    socket.emit("join-room", {
      roomId: id,
      user: {
        id: user._id,
        name: user.name,
        grid,
      },
    });

    onJoined(id); // App.jsx me roomId set hota hai → lobby show
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
