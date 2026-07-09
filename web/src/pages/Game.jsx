import React, { useEffect, useState } from "react";
import { socket } from "../services/socket";
import {
  cloneGrid,
  evaluateGrid,
  markNumber,
  pickBotMove,
} from "../utils/bingoGame";
import "../styles/Game.css";

const Game = ({
  roomId,
  offlineMode = false,
  initialGrid,
  myUserId,
  initialTurnUserId,
  botPlayerId,
  botPlayerName = "Opponent",
  botInitialGrid,
  onGameEnd,
}) => {
  const [grid, setGrid] = useState(() => cloneGrid(initialGrid));
  const [botGrid, setBotGrid] = useState(() =>
    botInitialGrid ? cloneGrid(botInitialGrid) : null,
  );
  const [currentTurn, setCurrentTurn] = useState(offlineMode ? myUserId : null);
  const [winner, setWinner] = useState(null);

  const isBotGame = offlineMode && !!botPlayerId;

  useEffect(() => {
    setGrid(cloneGrid(initialGrid));
  }, [initialGrid]);

  useEffect(() => {
    if (botInitialGrid) {
      setBotGrid(cloneGrid(botInitialGrid));
    }
  }, [botInitialGrid]);

  useEffect(() => {
    if (!offlineMode && initialTurnUserId) {
      setCurrentTurn(initialTurnUserId);
    }
  }, [offlineMode, initialTurnUserId]);

  useEffect(() => {
    if (offlineMode) return undefined;

    const onGameStart = ({ turnUserId }) => {
      setCurrentTurn(turnUserId);
    };

    const onTurn = ({ userId }) => {
      setCurrentTurn(userId);
    };

    const onUpdate = ({ number }) => {
      setGrid((prev) => {
        const nextState = evaluateGrid(markNumber(prev, number));

        if (nextState.win && !winner) {
          socket.emit("game:win", {
            roomId,
            userId: myUserId,
          });
        }

        return nextState.newGrid;
      });
    };

    const onWin = ({ userId }) => {
      setWinner(userId);

      onGameEnd({
        winnerName:
          userId === myUserId
            ? "You"
            : botPlayerId
              ? botPlayerName
              : "Opponent",
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
  }, [offlineMode, myUserId, botPlayerId, botPlayerName, onGameEnd]);

  const finishOfflineGame = (winnerId, draw = false) => {
    setWinner(draw ? "draw" : winnerId);
    onGameEnd({
      winnerName:
        draw || !winnerId ? "" : winnerId === myUserId ? "You" : botPlayerName,
      draw,
    });
  };

  const applyOfflineMove = (number) => {
    const nextHumanState = evaluateGrid(markNumber(grid, number));
    const nextBotState = botGrid
      ? evaluateGrid(markNumber(botGrid, number))
      : null;

    setGrid(nextHumanState.newGrid);
    if (nextBotState) {
      setBotGrid(nextBotState.newGrid);
    }

    if (nextHumanState.win && nextBotState?.win) {
      finishOfflineGame(null, true);
      return;
    }

    if (nextHumanState.win) {
      finishOfflineGame(myUserId, false);
      return;
    }

    if (nextBotState?.win) {
      finishOfflineGame(botPlayerId, false);
      return;
    }

    setCurrentTurn((prev) =>
      prev === myUserId && botPlayerId ? botPlayerId : myUserId,
    );
  };

  useEffect(() => {
    if (!isBotGame || winner || currentTurn !== botPlayerId || !botGrid) {
      return undefined;
    }

    const timer = setTimeout(() => {
      const selectedNumber = pickBotMove(botGrid, grid);

      if (selectedNumber === null) {
        finishOfflineGame(null, true);
        return;
      }

      applyOfflineMove(selectedNumber);
    }, 600);

    return () => clearTimeout(timer);
  }, [isBotGame, botPlayerId, botGrid, grid, currentTurn, winner]);

  const isLocked = offlineMode
    ? currentTurn !== myUserId || !!winner
    : currentTurn !== myUserId || !!winner;

  const selectNumber = (cell) => {
    if (isLocked) return;
    if (cell.chosen) return;

    if (offlineMode) {
      applyOfflineMove(cell.value);
      return;
    }

    socket.emit("game:select-number", {
      roomId,
      number: cell.value,
      userId: myUserId,
    });
  };

  const getTitle = () => {
    if (winner) {
      if (winner === "draw") {
        return { text: "Draw", class: "turn" };
      }

      return winner === myUserId
        ? { text: "You Win", class: "win" }
        : { text: "You Lost", class: "lose" };
    }

    return currentTurn === myUserId
      ? { text: "Your Turn", class: "turn" }
      : {
          text: `${botPlayerId ? botPlayerName : "Opponent"} Turn`,
          class: "turn",
        };
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
