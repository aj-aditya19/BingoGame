import React, { useState, useEffect } from "react";
import { socket } from "../services/socket";

const generateRoomId = () => {
  return Math.random().toString(36).substring(2, 9); // length = 7
};

const CreateRoom = ({ grid, user, onCreated }) => {
  const [roomId, setRoomId] = useState("");

  // generate room id once
  useEffect(() => {
    const id = generateRoomId();
    setRoomId(id);
  }, []);

  // emit join-room event when roomId, grid, user are ready
  useEffect(() => {
    if (!roomId || !grid || !user) return;

    socket.emit("join-room", {
      roomId,
      user: {
        id: user._id,
        name: user.name,
        grid,
      },
    });
  }, [roomId, grid, user]);

  const continueGame = () => {
    onCreated(roomId);
  };

  return (
    <div style={{ maxWidth: 360, margin: "40px auto", textAlign: "center" }}>
      <h3>Room Created</h3>

      <p>
        <b>Room ID:</b>
      </p>
      <div
        style={{
          padding: "10px",
          border: "1px solid #ccc",
          borderRadius: 6,
          marginBottom: 10,
          fontSize: 18,
        }}
      >
        {roomId}
      </div>

      <p style={{ fontSize: 14 }}>Share this Room ID with your friend</p>

      <button onClick={continueGame} style={{ width: "100%" }}>
        Go To Game
      </button>
    </div>
  );
};

export default CreateRoom;
