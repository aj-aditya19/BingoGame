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
  const [mode, setMode] = useState(null);
  const [roomId, setRoomId] = useState(null);
  const [gameGrid, setGameGrid] = useState(null);
  const [players, setPlayers] = useState([]);
  const [user, setUser] = useState(null);
  const [winner, setWinner] = useState(null);
  const [isDraw, setIsDraw] = useState(false);

  // ✅ Correct useEffect INSIDE COMPONENT
  useEffect(() => {
    if (!roomId) return;

    socket.on("room-joined", (updatedPlayers) => {
      console.log("Players updated:", updatedPlayers);
      setPlayers(updatedPlayers);
    });

    socket.on("game-start", () => setPage("game"));

    return () => {
      socket.off("room-joined");
      socket.off("game-start");
    };
  }, [roomId]);

  return (
    <div>
      {page === "login" && (
        <Login
          onLogin={(userData) => {
            // assume Login return karta user object
            setUser(userData);
            setPage("home");
          }}
          onRegister={() => setPage("register")}
        />
      )}

      {page === "register" && (
        <Register onRegister={() => setPage("set-password")} />
      )}

      {page === "set-password" && (
        <SetPassword onDone={() => setPage("home")} />
      )}

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

      {page === "grid" && (
        <Grid
          onDone={(grid) => {
            setGameGrid(grid);
            setPage(mode === "create" ? "create-room" : "join-room");
          }}
        />
      )}

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

      {page === "lobby" && (
        <Lobby
          roomId={roomId}
          isHost={mode === "create"}
          player1={players[0]}
          player2={players[1]}
          onStartGame={() => setPage("game")}
        />
      )}

      {page === "game" && (
        <Game
          roomId={roomId}
          grid={gameGrid}
          onGameEnd={({ winnerName, draw }) => {
            setWinner(winnerName);
            setIsDraw(draw);
            setPage("result");
          }}
        />
      )}

      {page === "result" && (
        <Result
          winner={winner}
          isDraw={isDraw}
          onPlayAgain={() => {
            // reset minimal state
            setWinner(null);
            setIsDraw(false);
            setGameGrid(null);
            setRoomId(null);
            setMode(null);
            setPage("home");
          }}
        />
      )}
    </div>
  );
};

export default App;
