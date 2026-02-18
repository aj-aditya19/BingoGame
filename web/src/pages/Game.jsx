import React, { useEffect, useState } from "react";
import { socket } from "../services/socket";
import "../styles/Game.css";

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
            cell.value === number ? { ...cell, chosen: true } : { ...cell },
          ),
        );

        const { newGrid, win } = checkWin(updated);

        if (!winner && currentTurn === myUserId && win) {
          socket.emit("game:win", {
            roomId,
            userId: myUserId,
          });
        }

        return newGrid;
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

  // ✅ UPDATED WIN CHECK WITH LINE HIGHLIGHT
  const checkWin = (grid) => {
    let lines = 0;

    // Deep copy grid
    const updated = grid.map((row) =>
      row.map((cell) => ({ ...cell, completed: false })),
    );

    // Rows
    for (let r = 0; r < 5; r++) {
      if (updated[r].every((c) => c.chosen)) {
        lines++;
        updated[r].forEach((c) => (c.completed = true));
      }
    }

    // Columns
    for (let c = 0; c < 5; c++) {
      if (updated.every((row) => row[c].chosen)) {
        lines++;
        updated.forEach((row) => (row[c].completed = true));
      }
    }

    // Diagonal 1
    if (updated.every((row, i) => row[i].chosen)) {
      lines++;
      updated.forEach((row, i) => (row[i].completed = true));
    }

    // Diagonal 2
    if (updated.every((row, i) => row[4 - i].chosen)) {
      lines++;
      updated.forEach((row, i) => (row[4 - i].completed = true));
    }

    return {
      newGrid: updated,
      win: lines >= 5,
    };
  };

  const getTitle = () => {
    if (winner) {
      return winner === myUserId
        ? { text: "🎉 You Win", class: "win" }
        : { text: "😢 You Lost", class: "lose" };
    }

    return currentTurn === myUserId
      ? { text: "Your Turn", class: "turn" }
      : { text: "Opponent Turn", class: "turn" };
  };

  const title = getTitle();

  return (
    <div className="game-container">
      <h3 className={`game-title ${title.class}`}>{title.text}</h3>

      <div className="game-grid">
        {grid.flat().map((cell, i) => (
          <button
            key={i}
            onClick={() => selectNumber(cell)}
            disabled={cell.chosen || isLocked}
            className={`game-cell 
              ${cell.chosen ? "chosen" : ""} 
              ${cell.completed ? "completed" : ""}
            `}
          >
            {cell.value}
          </button>
        ))}
      </div>
    </div>
  );
};

export default Game;
