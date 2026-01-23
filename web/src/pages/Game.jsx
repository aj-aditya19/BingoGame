import React, { useEffect, useState } from "react";
import { socket } from "../services/socket";

const Game = ({
  roomId,
  initialGrid,
  myUserId,
  initialTurnUserId,
  onGameEnd,
}) => {
  const [grid, setGrid] = useState(initialGrid);
  const [currentTurn, setCurrentTurn] = useState(null);
  const [winner, setWinner] = useState(null);

  useEffect(() => {
    if (initialTurnUserId) {
      setCurrentTurn(initialTurnUserId);
    }
  }, [initialTurnUserId]);

  useEffect(() => {
    const onGameStart = ({ turnUserId }) => {
      setCurrentTurn(turnUserId);
    };

    const onTurn = ({ userId }) => {
      setCurrentTurn(userId);
    };

    const onUpdate = ({ number }) => {
      setGrid((prev) => {
        const updated = prev.map((row) =>
          row.map((cell) =>
            cell.value === number ? { ...cell, chosen: true } : cell,
          ),
        );

        // ✅ ONLY current player can emit win
        if (!winner && currentTurn === myUserId && checkWin(updated)) {
          socket.emit("game:win", {
            roomId,
            userId: myUserId,
          });
        }

        return updated;
      });
    };

    const onWin = ({ userId }) => {
      setWinner(userId);

      onGameEnd({
        winnerName: userId === myUserId ? "You" : "Opponent",
        draw: false,
      });
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
  }, [roomId, myUserId, winner, currentTurn, onGameEnd]);

  const isLocked = currentTurn !== myUserId || !!winner;

  const selectNumber = (cell) => {
    if (isLocked) return;
    if (cell.chosen) return;

    socket.emit("game:select-number", {
      roomId,
      number: cell.value,
      userId: myUserId,
    });
  };

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
