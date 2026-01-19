import React from "react";

const Lobby = ({ roomId, isHost, player1, player2, onStartGame }) => {
  return (
    <div style={{ maxWidth: 420, margin: "40px auto" }}>
      <h2 style={{ textAlign: "center" }}>Game Lobby</h2>

      <p style={{ textAlign: "center" }}>
        <b>Room ID:</b> {roomId}
      </p>

      {/* Players Section */}
      <div style={{ marginTop: 20 }}>
        <h4>Players</h4>

        <div>✅ {player1?.name || "Player 1"} (Host)</div>

        <div>
          {player2 ? `✅ ${player2.name}` : "⏳ Waiting for Player 2..."}
        </div>
      </div>

      {/* Grid Preview */}
      <div style={{ marginTop: 20 }}>
        <h4>Grids Preview</h4>

        <div style={{ display: "flex", gap: 20 }}>
          <GridPreview title="Player 1" grid={player1?.grid} />
          <GridPreview title="Player 2" grid={player2?.grid} />
        </div>
      </div>

      {/* Rules */}
      <div style={{ marginTop: 20 }}>
        <h4>Rules</h4>
        <ul>
          <li>Players take turns</li>
          <li>Strike numbers one by one</li>
          <li>Complete BINGO to win</li>
        </ul>
      </div>

      {/* Start Button */}
      {isHost && player2 && (
        <button
          onClick={onStartGame}
          style={{
            width: "100%",
            marginTop: 20,
            padding: 10,
            fontSize: 16,
          }}
        >
          Let’s Play
        </button>
      )}

      {isHost && !player2 && (
        <p style={{ textAlign: "center", marginTop: 10 }}>
          Waiting for another player...
        </p>
      )}
    </div>
  );
};

export default Lobby;

const GridPreview = ({ title, grid }) => {
  if (!grid) return <div>{title}: Not Ready</div>;

  return (
    <div>
      <b>{title}</b>
      <div
        style={{
          display: "grid",
          gridTemplateColumns: "repeat(5, 30px)",
          gap: 4,
          marginTop: 6,
        }}
      >
        {grid.flat().map((cell, i) => (
          <div
            key={i}
            style={{
              height: 30,
              width: 30,
              fontSize: 12,
              textAlign: "center",
              lineHeight: "30px",
              border: "1px solid #ccc",
            }}
          >
            {cell.value}
          </div>
        ))}
      </div>
    </div>
  );
};
