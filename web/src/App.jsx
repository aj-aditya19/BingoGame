import React, { useState, useEffect } from "react";
import Login from "./pages/Login";
import Register from "./pages/Register";
import SetPassword from "./pages/SetPassword";
import GameHome from "./pages/GameHome";
import Grid from "./pages/Grid";
import CreateRoom from "./pages/CreateRoom";
import JoinRoom from "./pages/JoinRoom";
import Lobby from "./pages/Lobby";
import Game from "./pages/Game";
import Result from "./pages/Result";
import { socket } from "./services/socket";

const App = () => {
  const [page, setPage] = useState("login");
  const [mode, setMode] = useState(null); // create | join
  const [roomId, setRoomId] = useState(null);
  const [gameGrid, setGameGrid] = useState(null);
  const [players, setPlayers] = useState([]);
  const [winner, setWinner] = useState(null);
  const [isDraw, setIsDraw] = useState(false);
  const [initialTurnUserId, setInitialTurnUserId] = useState(null);

  const [user, setUser] = useState(() => {
    const saved = localStorage.getItem("user");
    return saved ? JSON.parse(saved) : null;
  });

  /* =======================
     AUTH SAFETY
  ======================= */
  useEffect(() => {
    if (!user) {
      setPage("login");
    }
  }, [user]);

  /* =======================
     SOCKET LISTENERS (ONCE)
  ======================= */
  useEffect(() => {
    socket.on("room-joined", (updatedPlayers) => {
      console.log("Players updated:", updatedPlayers);
      setPlayers(updatedPlayers);
    });

    socket.on("game-start", ({ turnUserId }) => {
      setInitialTurnUserId(turnUserId); // ⭐ IMPORTANT
      setPage("game");
    });

    return () => {
      socket.off("room-joined");
      socket.off("game-start");
    };
  }, []);

  return (
    <div>
      {/* LOGIN */}
      {page === "login" && (
        <Login
          onLogin={(userData) => {
            setUser(userData);
            localStorage.setItem("user", JSON.stringify(userData));
            setPage("home");
          }}
          onRegister={() => setPage("register")}
        />
      )}

      {/* REGISTER */}
      {page === "register" && (
        <Register onRegister={() => setPage("set-password")} />
      )}

      {/* SET PASSWORD */}
      {page === "set-password" && (
        <SetPassword onDone={() => setPage("home")} />
      )}

      {/* HOME */}
      {page === "home" && (
        <GameHome
          onCreateRoom={() => {
            setMode("create");
            setPage("grid");
          }}
          onJoinRoom={() => {
            setMode("join");
            setPage("grid");
          }}
        />
      )}

      {/* GRID */}
      {page === "grid" && (
        <Grid
          onDone={(grid) => {
            setGameGrid(grid);
            setPage(mode === "create" ? "create-room" : "join-room");
          }}
        />
      )}

      {/* CREATE ROOM */}
      {page === "create-room" && (
        <CreateRoom
          grid={gameGrid}
          user={user}
          onCreated={(id) => {
            setRoomId(id);
            setPage("lobby");
          }}
        />
      )}

      {/* JOIN ROOM */}
      {page === "join-room" && (
        <JoinRoom
          grid={gameGrid}
          user={user}
          onJoined={(id) => {
            setRoomId(id);
            setPage("lobby");
          }}
        />
      )}

      {/* LOBBY */}
      {page === "lobby" && (
        <Lobby
          roomId={roomId}
          isHost={mode === "create"}
          player1={players?.[0] || null}
          player2={players?.[1] || null}
          onStartGame={() => {
            socket.emit("start-game", { roomId });
          }}
        />
      )}

      {/* GAME */}
      {page === "game" && roomId && gameGrid && (
        <Game
          roomId={roomId}
          initialGrid={gameGrid}
          myUserId={user._id}
          initialTurnUserId={initialTurnUserId}
          onGameEnd={({ winnerName, draw }) => {
            setWinner(winnerName);
            setIsDraw(draw);
            setPage("result");
          }}
        />
      )}

      {/* RESULT */}
      {page === "result" && (
        <Result
          winner={winner}
          isDraw={isDraw}
          onPlayAgain={() => {
            setWinner(null);
            setIsDraw(false);
            setGameGrid(null);
            setRoomId(null);
            setMode(null);
            setPlayers([]);
            setPage("home");
          }}
        />
      )}
    </div>
  );
};

export default App;
