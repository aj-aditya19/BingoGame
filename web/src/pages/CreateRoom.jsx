import React, { useEffect, useState } from "react";
import { socket } from "../services/socket";
import { gameApi } from "../services/api";
import "../styles/CreateRoom.css";

const CreateRoom = ({
  grid,
  user,
  botOpponent,
  botGrid,
  autoStartGame,
  onCreated,
}) => {
  const [roomId, setRoomId] = useState(null);
  const [copyStatus, setCopyStatus] = useState("");

  useEffect(() => {
    const create = async () => {
      const res = await gameApi.createRoom();
      if (!res.success) return;

      setRoomId(res.roomId);

      socket.emit("join-room", {
        roomId: res.roomId,
        user: {
          _id: user._id,
          name: user.name,
          grid,
          role: "Host",
        },
      });

      if (botOpponent && botGrid) {
        socket.emit("join-room", {
          roomId: res.roomId,
          user: {
            _id: botOpponent._id,
            name: botOpponent.name,
            grid: botGrid,
            role: "Bot",
          },
        });
      }

      if (autoStartGame) {
        socket.emit("start-game", { roomId: res.roomId });
      }

      onCreated(res.roomId);
    };

    create();
  }, []);

  const copyRoomId = async () => {
    if (!roomId) return;

    try {
      await navigator.clipboard.writeText(roomId);
      setCopyStatus("Copied");
    } catch (error) {
      setCopyStatus("Copy failed");
    }

    setTimeout(() => setCopyStatus(""), 1800);
  };

  if (!roomId) return <p className="create-room-loading">Creating room...</p>;

  return (
    <div className="create-room-container">
      <div className="create-room-card">
        <h3 className="create-room-title">Room Created</h3>

        <div className="room-id-row">
          <h2 className="create-room-id">{roomId}</h2>
          <button
            type="button"
            onClick={copyRoomId}
            className="copy-room-btn"
            title="Copy room ID"
            aria-label="Copy room ID"
          >
            <svg
              viewBox="0 0 24 24"
              width="18"
              height="18"
              fill="none"
              stroke="currentColor"
              strokeWidth="2"
              strokeLinecap="round"
              strokeLinejoin="round"
              aria-hidden="true"
            >
              <rect x="9" y="9" width="13" height="13" rx="2" ry="2" />
              <path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1" />
            </svg>
          </button>
        </div>

        {copyStatus && <p className="copy-status">{copyStatus}</p>}

        <button className="create-room-btn" onClick={() => onCreated(roomId)}>
          Go To Lobby
        </button>
      </div>
    </div>
  );
};

export default CreateRoom;
