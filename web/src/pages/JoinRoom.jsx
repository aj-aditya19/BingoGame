import React, { useState } from "react";
import { socket } from "../services/socket";
import { gameApi } from "../services/api";
import "../styles/JoinRoom.css";

const JoinRoom = ({ grid, user, onJoined }) => {
  const [roomId, setRoomId] = useState("");

  const joinRoom = async () => {
    if (!roomId.trim()) {
      alert("Please enter Room ID");
      return;
    }

    const res = await gameApi.joinRoom(roomId);

    if (!res.success) {
      alert(res.message);
      return;
    }

    socket.emit("join-room", {
      roomId,
      user: {
        _id: user._id,
        name: user.name,
        grid,
        role: "Invited",
      },
    });

    onJoined(roomId);
  };

  return (
    <div className="joinroom-container">
      <div className="joinroom-card">
        <h3 className="joinroom-title">Join Room</h3>

        <input
          className="joinroom-input"
          placeholder="Enter Room ID"
          value={roomId}
          onChange={(e) => setRoomId(e.target.value)}
        />
        <button className="joinroom-btn" onClick={joinRoom}>
          Join Game
        </button>
      </div>
    </div>
  );
};

export default JoinRoom;
