import React, { useState } from "react";
import { useEffect } from "react";
import { socket } from "../services/socket";

// CreateRoom.jsx / JoinRoom.jsx ke andar
useEffect(() => {
  if (!roomId || !grid || !user) return; // check essential data

  socket.emit("join-room", {
    roomId,
    user: {
      id: user._id, // unique player id
      name: user.name,
      grid, // player ka grid
    },
  });
}, [roomId, grid, user]);

const JoinRoom = ({ grid, onJoined }) => {
  const [roomId, setRoomId] = useState("");

  const joinRoom = () => {
    if (roomId.trim().length !== 7) {
      alert("Invalid Room ID");
      return;
    }

    // future me backend validation aayega
    onJoined(roomId.trim());
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
