import React, { useEffect, useState } from "react";
import { socket } from "../services/socket";
import { gameApi } from "../services/api";

const CreateRoom = ({ grid, user, onCreated }) => {
  const [roomId, setRoomId] = useState(null);

  // 🔥 CREATE ROOM ON SERVER
  useEffect(() => {
    const create = async () => {
      const res = await gameApi.createRoom();
      if (!res.success) return;

      setRoomId(res.roomId);

      socket.emit("join-room", {
        roomId: res.roomId,
        user: {
          id: user._id,
          name: user.name,
          grid,
        },
      });
    };

    create();
  }, []);

  if (!roomId) return <p>Creating room...</p>;

  return (
    <div style={{ textAlign: "center" }}>
      <h3>Room Created</h3>
      <h2>{roomId}</h2>

      <button onClick={() => onCreated(roomId)}>Go To Lobby</button>
    </div>
  );
};

export default CreateRoom;
