import React from "react";

const GameHome = ({ onCreateRoom, onJoinRoom }) => {
  return (
    <div style={{ textAlign: "center", marginTop: "50px" }}>
      <h2>Bingo Game</h2>

      <div style={{ marginTop: "20px" }}>
        <button
          onClick={onCreateRoom}
          style={{ marginRight: "10px", padding: "10px 20px" }}
        >
          Create Room
        </button>

        <button onClick={onJoinRoom} style={{ padding: "10px 20px" }}>
          Join Room
        </button>
      </div>
    </div>
  );
};

export default GameHome;
