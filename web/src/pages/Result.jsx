import React from "react";

const Result = ({ winner, isDraw, onPlayAgain }) => {
  return (
    <div
      style={{
        maxWidth: 360,
        margin: "60px auto",
        textAlign: "center",
      }}
    >
      <h2>Game Result</h2>

      {!isDraw ? (
        <>
          <h3 style={{ color: "#22c55e" }}>🏆 Winner</h3>
          <p style={{ fontSize: 20, fontWeight: "bold" }}>{winner}</p>
          <p>BINGO completed 🎉</p>
        </>
      ) : (
        <>
          <h3 style={{ color: "#f97316" }}>🤝 Draw</h3>
          <p>Both players completed BINGO</p>
        </>
      )}

      <button
        onClick={onPlayAgain}
        style={{
          marginTop: 20,
          width: "100%",
          padding: 10,
          fontSize: 16,
        }}
      >
        Play Again
      </button>
    </div>
  );
};

export default Result;
