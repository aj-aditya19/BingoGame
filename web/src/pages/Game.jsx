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
            cell.value === number ? { ...cell, chosen: true } : cell,
          ),
        );

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

    for (let r = 0; r < 5; r++) {
      if (grid[r].every((c) => c.chosen)) count++;
    }

    for (let c = 0; c < 5; c++) {
      if (grid.every((row) => row[c].chosen)) count++;
    }

    if (grid.every((row, i) => row[i].chosen)) count++;
    if (grid.every((row, i) => row[4 - i].chosen)) count++;

    return count >= 5;
  };

  const getTitle = () => {
    if (winner) {
      return winner === myUserId
        ? { text: "🎉 You Win!", class: "win" }
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
            className={`game-cell ${cell.chosen ? "chosen" : ""}`}
          >
            {cell.value}
          </button>
        ))}
      </div>
    </div>
  );
};

export default Game;
