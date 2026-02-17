import React, { useEffect, useState } from "react";
import { socket } from "../services/socket";
import { gameApi } from "../services/api";
import "../styles/CreateRoom.css";

const CreateRoom = ({ grid, user, onCreated }) => {
  const [roomId, setRoomId] = useState(null);

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
          role: "Host",
        },
      });
    };

    create();
  }, []);

  if (!roomId)
    return <p className="create-room-loading">Creating room...</p>;

  return (
    <div className="create-room-container">
      <div className="create-room-card">
        <h3 className="create-room-title">Room Created</h3>
        <h2 className="create-room-id">{roomId}</h2>

        <button
          className="create-room-btn"
          onClick={() => onCreated(roomId)}
        >
          Go To Lobby
        </button>
      </div>
    </div>
  );
};

export default CreateRoom;