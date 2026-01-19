// import React, { useState } from "react";

// const makeEmptyGrid = () =>
//   Array.from({ length: 5 }, () =>
//     Array.from({ length: 5 }, () => ({ value: null, chosen: false })),
//   );

// const Grid = ({ onStartGame }) => {
//   const [grid, setGrid] = useState(makeEmptyGrid());
//   const [duplicates, setDuplicates] = useState(new Set());

//   const recomputeDuplicates = (nextGrid) => {
//     const freq = new Map();

//     nextGrid.flat().forEach((cell) => {
//       if (cell.value !== null) {
//         freq.set(cell.value, (freq.get(cell.value) || 0) + 1);
//       }
//     });

//     const dups = new Set(
//       [...freq.entries()].filter(([, c]) => c > 1).map(([v]) => v),
//     );
//     setDuplicates(dups);
//   };

//   const onChangeCell = (r, c, raw) => {
//     let val = raw === "" ? null : Number(raw);

//     if (val !== null && (!Number.isInteger(val) || val < 1 || val > 25)) return;

//     setGrid((prev) => {
//       const next = prev.map((row) => row.map((cell) => ({ ...cell })));
//       next[r][c].value = val;
//       recomputeDuplicates(next);
//       return next;
//     });
//   };

//   const randomBox = () => {
//     const newGrid = makeEmptyGrid();
//     const used = new Set();

//     for (let r = 0; r < 5; r++) {
//       for (let c = 0; c < 5; c++) {
//         let val;
//         do {
//           val = Math.floor(Math.random() * 25) + 1;
//         } while (used.has(val));

//         used.add(val);
//         newGrid[r][c].value = val;
//       }
//     }

//     setGrid(newGrid);
//     setDuplicates(new Set());
//   };

//   const requestGame = () => {
//     if (duplicates.size > 0) return;

//     for (let r = 0; r < 5; r++) {
//       for (let c = 0; c < 5; c++) {
//         if (grid[r][c].value === null) return;
//       }
//     }

//     onStartGame(grid);
//   };

//   return (
//     <div style={{ maxWidth: 360, margin: "auto" }}>
//       <h2 style={{ textAlign: "center" }}>Bingo Grid Setup</h2>

//       <div
//         style={{
//           display: "grid",
//           gridTemplateColumns: "repeat(5, 1fr)",
//           gap: 6,
//         }}
//       >
//         {grid.map((row, r) =>
//           row.map((cell, c) => {
//             const isDup = cell.value !== null && duplicates.has(cell.value);

//             return (
//               <input
//                 key={`${r}-${c}`}
//                 type="number"
//                 min={1}
//                 max={25}
//                 value={cell.value ?? ""}
//                 onChange={(e) => onChangeCell(r, c, e.target.value)}
//                 style={{
//                   height: 48,
//                   textAlign: "center",
//                   fontSize: 16,
//                   borderRadius: 8,
//                   border: isDup ? "2px solid #ef4444" : "1px solid #cbd5f5",
//                   background: isDup ? "#fee2e2" : "#ffffff",
//                 }}
//               />
//             );
//           }),
//         )}
//       </div>

//       <button onClick={randomBox} style={{ marginTop: 12, width: "100%" }}>
//         Random Fill
//       </button>

//       <button onClick={requestGame} style={{ marginTop: 8, width: "100%" }}>
//         Go To Game
//       </button>
//     </div>
//   );
// };

// export default Grid;

import React, { useEffect, useState } from "react";
import { socket } from "../services/socket";

const Game = ({ roomId, myGrid, myUserId }) => {
  const [grid, setGrid] = useState(myGrid);
  const [currentTurn, setCurrentTurn] = useState(null); // userId
  const [locked, setLocked] = useState(false);

  // 🔁 start game
  useEffect(() => {
    socket.emit("game:start", { roomId });

    socket.on("game:turn", ({ userId }) => {
      setCurrentTurn(userId);
    });

    socket.on("game:update", ({ number }) => {
      markNumber(number);
      setLocked(false);
    });

    return () => {
      socket.off("game:turn");
      socket.off("game:update");
    };
  }, []);

  // ✅ mark number in grid
  const markNumber = (num) => {
    setGrid((prev) =>
      prev.map((row) =>
        row.map((cell) =>
          cell.value === num ? { ...cell, chosen: true } : cell,
        ),
      ),
    );
  };

  // 🎯 user clicks number
  const selectNumber = (cell) => {
    if (locked) return;
    if (cell.chosen) return;
    if (currentTurn !== myUserId) return;

    setLocked(true);

    socket.emit("game:select-number", {
      roomId,
      number: cell.value,
    });
  };

  return (
    <div>
      <h3>Turn: {currentTurn === myUserId ? "Your Turn" : "Opponent Turn"}</h3>

      <div
        style={{
          display: "grid",
          gridTemplateColumns: "repeat(5, 60px)",
          gap: 6,
        }}
      >
        {grid.flat().map((cell, i) => (
          <button
            key={i}
            disabled={cell.chosen || currentTurn !== myUserId}
            onClick={() => selectNumber(cell)}
            style={{
              height: 60,
              background: cell.chosen ? "#22c55e" : "#fff",
              cursor: cell.chosen ? "not-allowed" : "pointer",
            }}
          >
            {cell.value}
          </button>
        ))}
      </div>
    </div>
  );
};

export default Game;
