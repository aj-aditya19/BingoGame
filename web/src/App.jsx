// import React, { useState } from "react";
// import Home from "./pages/Home";
// import Login from "./pages/Login";
// import Register from "./pages/Register";
// import Grid from "./pages/Grid";
// import Game from "./pages/Game";
// import SetPassword from "./pages/SetPassword";

// const App = () => {
//   const [page, setPage] = useState("login");
//   const [gameGrid, setGameGrid] = useState(null);

//   return (
//     <div>
//       {page === "login" && (
//         <Login
//           onLogin={(next) => setPage(next || "input")}
//           onRegister={() => setPage("register")}
//         />
//       )}

//       {page === "register" && (
//         <Register onRegister={(next) => setPage(next || "input")} />
//       )}

//       {page === "set-password" && (
//         <SetPassword onDone={() => setPage("input")} />
//       )}

//       {page === "input" && (
//         <Grid
//           onStartGame={(grid) => {
//             setGameGrid(grid);
//             setPage("game");
//           }}
//         />
//       )}

//       {page === "game" && <Game grid={gameGrid} />}
//     </div>
//   );
// };

// export default App;

import React, { useState } from "react";

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
import { useEffect } from "react";
import { socket } from "./services/socket";

useEffect(() => {
  if (!roomId) return;

  // jab koi player join karta hai
  socket.on("room-joined", (updatedPlayers) => {
    console.log("Players updated:", updatedPlayers);
    setPlayers(updatedPlayers); // players state update hoti hai
  });

  // jab game start hota hai
  socket.on("game-start", () => {
    setPage("game");
  });

  return () => {
    socket.off("room-joined");
    socket.off("game-start");
  };
}, [roomId]);

const App = () => {
  const [page, setPage] = useState("login");

  const [mode, setMode] = useState(null); // create | join
  const [roomId, setRoomId] = useState(null);
  const [gameGrid, setGameGrid] = useState(null);
  const [players, setPlayers] = useState([]); // NEW

  // RESULT STATE
  const [winner, setWinner] = useState(null);
  const [isDraw, setIsDraw] = useState(false);

  return (
    <div>
      {page === "login" && (
        <Login
          onLogin={() => setPage("home")}
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
          onCreated={(id) => {
            setRoomId(id);
            setPage("lobby");
          }}
        />
      )}

      {page === "join-room" && (
        <JoinRoom
          grid={gameGrid}
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
