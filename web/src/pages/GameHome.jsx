import React from "react";
import "../styles/GameHome.css";

const GameHome = ({ onCreateRoom, onJoinRoom }) => {
  return (
    <div className="gamehome-container">
      <div className="gamehome-card">
        <h2 className="gamehome-title">🎯 Bingo Game</h2>

        <div className="gamehome-buttons">
          <button onClick={onCreateRoom} className="gamehome-btn create-btn">
            Create Room
          </button>

          <button onClick={onJoinRoom} className="gamehome-btn join-btn">
            Join Room
          </button>
        </div>
      </div>
    </div>
  );
};

export default GameHome;
