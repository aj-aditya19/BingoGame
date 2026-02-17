// import React from "react";
// import { useEffect } from "react";

// const Result = ({ winner, isDraw, onPlayAgain }) => {
//   useEffect(() => {
//     const timer = setTimeout(() => {
//       onPlayAgain();
//     }, 7000);

//     return () => clearTimeout(timer);
//   }, [onPlayAgain]);
//   return (
//     <div
//       style={{
//         maxWidth: 360,
//         margin: "60px auto",
//         textAlign: "center",
//       }}
//     >
//       <h2>Game Result</h2>

//       {!isDraw ? (
//         <>
//           <h3 style={{ color: "#22c55e" }}>🏆 Winner</h3>
//           <p style={{ fontSize: 20, fontWeight: "bold" }}>{winner}</p>
//           <p>BINGO completed 🎉</p>
//         </>
//       ) : (
//         <>
//           <h3 style={{ color: "#f97316" }}>🤝 Draw</h3>
//           <p>Both players completed BINGO</p>
//         </>
//       )}

//       <button
//         onClick={onPlayAgain}
//         style={{
//           marginTop: 20,
//           width: "100%",
//           padding: 10,
//           fontSize: 16,
//         }}
//       >
//         Play Again
//       </button>
//     </div>
//   );
// };

// export default Result;

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
