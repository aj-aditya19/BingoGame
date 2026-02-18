import React from "react";
import "../styles/Lobby.css";

const Lobby = ({ roomId, isHost, player1, player2, onStartGame }) => {
  return (
    <div className="lobby-container">
      <h2 className="lobby-title">🎮 Game Lobby</h2>

      <p className="lobby-room">
        <b>Room ID:</b> {roomId}
      </p>

      {/* Players */}
      <div className="lobby-section">
        <h4>Players</h4>
        <div className="players-list">
          <div>
            ✅ {player1?.name || "Player 1"} ({player1?.role || "Player"})
          </div>

          <div>
            {player2
              ? `✅ ${player2.name} (${player2.role || "Player"})`
              : "⏳ Waiting for Player 2..."}
          </div>
        </div>
      </div>

      {/* Grid Preview */}
      <div className="lobby-section">
        <h4>Grids Preview</h4>

        <div className="preview-container">
          <GridPreview title="Player 1" grid={player1?.grid} />
          <GridPreview title="Player 2" grid={player2?.grid} />
        </div>
      </div>

      {/* Rules */}
      <div className="lobby-section">
        <h4>Rules</h4>
        <ul className="rules-list">
          <li>Players take turns</li>
          <li>Strike numbers one by one</li>
          <li>Complete BINGO to win</li>
        </ul>
      </div>

      {/* Start */}
      {isHost && player2 && (
        <button className="start-btn" onClick={onStartGame}>
          🚀 Let’s Play
        </button>
      )}

      {isHost && !player2 && (
        <p className="waiting-text">Waiting for another player...</p>
      )}
    </div>
  );
};

export default Lobby;

const GridPreview = ({ title, grid }) => {
  if (!grid)
    return (
      <div className="preview-card">
        <b>{title}</b>
        <p>Not Ready</p>
      </div>
    );

  return (
    <div className="preview-card">
      <div className="preview-title">{title}</div>

      <div className="preview-grid">
        {grid.flat().map((cell, i) => (
          <div key={i} className="preview-cell">
            {cell.value}
          </div>
        ))}
      </div>
    </div>
  );
};
