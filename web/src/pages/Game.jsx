import React, { useEffect, useState } from "react";
import { socket } from "../services/socket";

const Game = ({ roomId, initialGrid, myUserId }) => {
  const [grid, setGrid] = useState(initialGrid);
  const [currentTurn, setCurrentTurn] = useState(null);
  const [winner, setWinner] = useState(null);

  // ------------------------
  // Socket listeners
  // ------------------------
  useEffect(() => {
    const onGameStart = ({ turnUserId }) => {
      setCurrentTurn(turnUserId);
    };

    const onTurn = ({ userId }) => {
      setCurrentTurn(userId);
    };

    const onUpdate = ({ number }) => {
      markNumber(number);
    };

    const onWin = ({ userId }) => {
      setWinner(userId);
    };

    socket.on("game-start", onGameStart);
    socket.on("game:turn", onTurn);
    socket.on("game:update", onUpdate);
    socket.on("game:win", onWin);

    return () => {
      socket.off("game-start", onGameStart);
      socket.off("game:turn", onTurn);
      socket.off("game:update", onUpdate);
      socket.off("game:win", onWin);
    };
  }, []);

  // ------------------------
  // Lock buttons based on current turn
  // ------------------------
  const isLocked = currentTurn !== myUserId || !!winner;

  // ------------------------
  // Mark number in grid
  // ------------------------
  const markNumber = (num) => {
    setGrid((prev) =>
      prev.map((row) =>
        row.map((cell) =>
          cell.value === num ? { ...cell, chosen: true } : cell,
        ),
      ),
    );
  };

  // ------------------------
  // Select number
  // ------------------------
  const selectNumber = (cell) => {
    if (isLocked) return;
    if (cell.chosen) return;

    socket.emit("game:select-number", {
      roomId,
      number: cell.value,
      userId: myUserId,
    });
  };

  // ------------------------
  // Check win condition
  // ------------------------
  const checkWin = (grid) => {
    let count = 0;

    // Rows
    for (let r = 0; r < 5; r++) {
      if (grid[r].every((c) => c.chosen)) count++;
    }

    // Columns
    for (let c = 0; c < 5; c++) {
      if (grid.every((row) => row[c].chosen)) count++;
    }

    // Diagonals
    if (grid.every((row, i) => row[i].chosen)) count++;
    if (grid.every((row, i) => row[4 - i].chosen)) count++;

    return count >= 5;
  };

  // ------------------------
  // Emit win only once
  // ------------------------
  useEffect(() => {
    if (!winner && checkWin(grid)) {
      setWinner(myUserId); // local win state
      socket.emit("game:win", { roomId, userId: myUserId });
    }
  }, [grid, winner, myUserId, roomId]);

  // ------------------------
  // Render
  // ------------------------
  return (
    <div style={{ maxWidth: 300, margin: "20px auto" }}>
      <h3 style={{ textAlign: "center" }}>
        {winner
          ? winner === myUserId
            ? "🎉 You Win!"
            : "😢 You Lost"
          : currentTurn === myUserId
            ? "Your Turn"
            : "Opponent Turn"}
      </h3>

      <div
        style={{
          display: "grid",
          gridTemplateColumns: "repeat(5, 50px)",
          gap: 5,
          justifyContent: "center",
        }}
      >
        {grid.flat().map((cell, i) => (
          <button
            key={i}
            onClick={() => selectNumber(cell)}
            disabled={cell.chosen || isLocked}
            style={{
              height: 50,
              width: 50,
              background: cell.chosen ? "#aaa" : "#fff",
              border: "1px solid #000",
              cursor: cell.chosen || isLocked ? "not-allowed" : "pointer",
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
