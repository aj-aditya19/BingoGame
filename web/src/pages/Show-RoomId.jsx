import React, { useState } from "react";
import "../styles/Show-RoomId.css";

const ShowRoomId = ({ roomId, isHost, gotolobby }) => {
  const [copied, setCopied] = useState(false);

  const copyRoomId = async () => {
    try {
      await navigator.clipboard.writeText(roomId);
      setCopied(true);

      setTimeout(() => {
        setCopied(false);
      }, 2000);
    } catch (err) {
      console.error("Failed to copy:", err);
    }
  };

  return (
    <div className="room-page">
      <div className="room-card">
        <h2 className="room-title">Room Created</h2>

        <p className="room-subtitle">
          Share this Room ID with your friends so they can join the game.
        </p>

        <div className="room-id-box">
          <span className="room-id">{roomId}</span>

          <button className="copy-btn" onClick={copyRoomId}>
            Copy
          </button>
        </div>

        {copied && <p className="copied-text">Room ID copied!</p>}

        {isHost && (
          <button className="start-btn" onClick={gotolobby}>
            Go to Lobby →
          </button>
        )}
      </div>
    </div>
  );
};

export default ShowRoomId;
