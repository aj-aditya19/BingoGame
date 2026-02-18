import React, { useEffect, useState } from "react";
import "../styles/Result.css";

const Result = ({ winner, isDraw, onPlayAgain }) => {
  const [countdown, setCountdown] = useState(7);

  useEffect(() => {
    const timer = setTimeout(() => {
      onPlayAgain();
    }, 7000);

    const interval = setInterval(() => {
      setCountdown((prev) => prev - 1);
    }, 1000);

    return () => {
      clearTimeout(timer);
      clearInterval(interval);
    };
  }, [onPlayAgain]);

  return (
    <div className="result-container">
      <div className="result-card">
        <h2 className="result-title">Game Result</h2>

        {!isDraw ? (
          <>
            <div className="winner-text">🏆 Winner</div>
            <p style={{ fontSize: 20, fontWeight: "bold" }}>{winner}</p>
            <p className="result-sub">BINGO completed 🎉</p>
          </>
        ) : (
          <>
            <div className="draw-text">🤝 Draw</div>
            <p className="result-sub">Both players completed BINGO</p>
          </>
        )}

        <button className="play-again-btn" onClick={onPlayAgain}>
          Play Again
        </button>

        <div className="auto-text">Auto restarting in {countdown}s...</div>
      </div>
    </div>
  );
};

export default Result;
