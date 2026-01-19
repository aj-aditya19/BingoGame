import React, { useEffect, useState } from "react";
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

const generateRoomId = () => {
  return Math.random().toString(36).substring(2, 9); // length = 7
};

const CreateRoom = ({ grid, onCreated }) => {
  const [roomId, setRoomId] = useState("");

  useEffect(() => {
    const id = generateRoomId();
    setRoomId(id);
  }, []);

  const continueGame = () => {
    // yahan future me backend / socket aayega
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
