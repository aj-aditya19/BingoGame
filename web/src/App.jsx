import React, { useState, useEffect } from "react";
import Landing from "./pages/Landing";
import Login from "./pages/Login";
import Register from "./pages/Register";
import GameHome from "./pages/GameHome";
import Grid from "./pages/Grid";
import CreateBot from "./pages/CreateBot";
import CreateRoom from "./pages/CreateRoom";
import JoinRoom from "./pages/JoinRoom";
import Lobby from "./pages/Lobby";
import Game from "./pages/Game";
import Result from "./pages/Result";
import { socket } from "./services/socket";
import { useLocation, useNavigate } from "react-router-dom";
import "./App.css";

const createGuestUser = () => {
  const guestId =
    typeof crypto !== "undefined" && crypto.randomUUID
      ? crypto.randomUUID()
      : `guest-${Date.now()}-${Math.random().toString(16).slice(2)}`;

  console.log(`Request ID: , ${guestId}`);

  return {
    _id: guestId,
    name: "Guest Player",
    email: "guest@local",
    role: "Guest",
    provider: "guest",
  };
};

const App = () => {
  const location = useLocation();
  const navigate = useNavigate();
  const [page, setPage] = useState("landing");
  const [mode, setMode] = useState(null);
  const [playMode, setPlayMode] = useState(null);
  const [roomId, setRoomId] = useState(null);
  const [gameGrid, setGameGrid] = useState(null);
  const [botPlayer, setBotPlayer] = useState(null);
  const [botGrid, setBotGrid] = useState(null);
  const [players, setPlayers] = useState([]);
  const [winner, setWinner] = useState(null);
  const [isDraw, setIsDraw] = useState(false);
  const [initialTurnUserId, setInitialTurnUserId] = useState(null);

  const [user, setUser] = useState(() => {
    const saved = localStorage.getItem("user");
    return saved ? JSON.parse(saved) : null;
  });

  const isAuthRoute = location.pathname === "/auth";
  const isRegisterRoute = location.pathname === "/auth/register";

  const saveUser = (userData) => {
    setUser(userData);
    localStorage.setItem("user", JSON.stringify(userData));
  };

  const clearSavedUser = () => {
    setUser(null);
    localStorage.removeItem("user");
  };

  const resetGameData = () => {
    setRoomId(null);
    setGameGrid(null);
    setBotPlayer(null);
    setBotGrid(null);
    setPlayers([]);
    setWinner(null);
    setIsDraw(false);
    setInitialTurnUserId(null);
  };

  const leaveCurrentRoom = () => {
    if (roomId) {
      socket.emit("leave-room", { roomId });
    }
  };

  const goToHome = () => {
    resetGameData();
    setMode(null);
    setPlayMode(null);
    setPage("home");
  };

  const goToLanding = () => {
    leaveCurrentRoom();
    resetGameData();
    setMode(null);
    setPlayMode(null);
    navigate("/", { replace: true });
    setPage("landing");
  };

  const handleLogout = () => {
    leaveCurrentRoom();
    resetGameData();
    setMode(null);
    setPlayMode(null);
    clearSavedUser();
    navigate("/", { replace: true });
    setPage("landing");
  };

  const handleBack = () => {
    if (isAuthRoute || isRegisterRoute) {
      navigate("/auth", { replace: true });
      return;
    }

    if (page === "grid") {
      goToHome();
      return;
    }

    if (page === "bot-setup") {
      setPage("grid");
      return;
    }

    if (page === "create-room" || page === "join-room") {
      setPage("grid");
      return;
    }

    if (page === "lobby") {
      leaveCurrentRoom();
      resetGameData();
      setMode(null);
      setPlayMode(null);
      setPage("home");
      return;
    }

    if (page === "result") {
      goToHome();
    }
  };

  const handleCancelOrEndGame = () => {
    leaveCurrentRoom();
    resetGameData();
    setMode(null);
    setPlayMode(null);
    navigate("/", { replace: true });
    setPage("landing");
  };

  const startOfflineBotGame = () => {
    resetGameData();
    setMode(null);
    setPlayMode("bot");
    setUser(createGuestUser());
    setPage("grid");
  };

  const startFriendGame = () => {
    resetGameData();
    setMode("create");
    setPlayMode("friends");
    setPage("grid");
  };

  const joinFriendGame = () => {
    resetGameData();
    setMode("join");
    setPlayMode("friends");
    setPage("grid");
  };

  const handleLandingLogin = (userData) => {
    saveUser(userData);
    console.log("User logged in landing page: ", userData);
    navigate("/", { replace: true });
    setPage("home");
  };

  const handleLogin = (userData) => {
    saveUser(userData);
    console.log("User logged in: ", userData);
    navigate("/", { replace: true });
    setPage("home");
  };

  const handleRegister = (userData) => {
    console.log("Registering user");
    saveUser(userData);
    navigate("/", { replace: true });
    setPage("home");
  };

  const handleGridDone = (grid) => {
    console.log("Grid created");
    setGameGrid(grid);

    if (playMode === "bot") {
      setPage("bot-setup");
      return;
    }

    setPage(mode === "create" ? "create-room" : "join-room");
  };

  const handleRoomCreated = (id) => {
    setUser((prev) => ({ ...prev, role: "Host" }));
    setRoomId(id);

    if (playMode === "bot") {
      setPage("game");
      return;
    }

    setPage("lobby");
  };

  const handleRoomJoined = (id) => {
    console.log("Joined room of the user: ", id);
    console.log("Joined User: ", user.email);
    setUser((prev) => ({ ...prev, role: "Invited" }));
    setRoomId(id);
    setPage("lobby");
  };

  const handleGameEnd = ({ winnerName, draw }) => {
    console.log("Initial Turn Id: ", initialTurnUserId);
    setWinner(winnerName);
    setIsDraw(draw);
    setPage("result");
  };

  const handlePlayAgain = () => {
    if (playMode === "bot") {
      goToLanding();
      return;
    }

    resetGameData();
    setMode(null);
    setPlayMode(null);
    setPage("home");
  };

  const showBackButton = [
    "login",
    "register",
    "grid",
    "bot-setup",
    "create-room",
    "join-room",
    "lobby",
    "result",
  ].includes(page);

  const showLogoutButton = user && page !== "landing";

  const showCancelButton = [
    "grid",
    "bot-setup",
    "create-room",
    "join-room",
    "lobby",
    "game",
  ].includes(page);

  const actionButtonLabel = page === "game" ? "End Game" : "Cancel Game";

  const playAgain = () => {
    handlePlayAgain();
  };

  const renderPage = () => {
    if (isAuthRoute || isRegisterRoute) {
      return isRegisterRoute ? (
        <Register
          onRegister={handleRegister}
          onLogin={() => navigate("/auth", { replace: true })}
        />
      ) : (
        <Login
          onLogin={handleLogin}
          onRegister={() => navigate("/auth/register", { replace: true })}
        />
      );
    }

    switch (page) {
      case "landing":
        return (
          <Landing
            onPlayWithBot={startOfflineBotGame}
            gotohomepage={handleLandingLogin}
            onLogin={() => {
              if (user) {
                setPage("home");
                return;
              }

              navigate("/auth", { replace: true });
            }}
          />
        );

      case "home":
        return (
          <GameHome
            onCreateRoom={startFriendGame}
            onJoinRoom={joinFriendGame}
          />
        );

      case "grid":
        return <Grid onDone={handleGridDone} />;

      case "bot-setup":
        return (
          <CreateBot
            setBotPlayer={setBotPlayer}
            setBotGrid={setBotGrid}
            onReady={() => setPage("game")}
          />
        );

      case "create-room":
        return (
          <CreateRoom
            grid={gameGrid}
            user={user}
            botOpponent={playMode === "bot" ? botPlayer : null}
            botGrid={playMode === "bot" ? botGrid : null}
            autoStartGame={playMode === "bot"}
            onCreated={handleRoomCreated}
          />
        );

      case "join-room":
        return (
          <JoinRoom grid={gameGrid} user={user} onJoined={handleRoomJoined} />
        );

      case "lobby":
        return (
          <Lobby
            roomId={roomId}
            isHost={mode === "create"}
            player1={players?.[0] || null}
            player2={players?.[1] || null}
            onStartGame={() => {
              console.log("User: ", user.email);
              socket.emit("start-game", { roomId });
            }}
          />
        );

      case "game":
        console.log("Bot Grid: ", botGrid);
        return gameGrid && user ? (
          <Game
            roomId={roomId}
            offlineMode={playMode === "bot"}
            initialGrid={gameGrid}
            myUserId={user._id}
            myName={user.name}
            initialTurnUserId={initialTurnUserId}
            botPlayerId={playMode === "bot" ? botPlayer?._id : null}
            botPlayerName={playMode === "bot" ? botPlayer?.name : "Opponent"}
            botInitialGrid={playMode === "bot" ? botGrid : null}
            onGameEnd={handleGameEnd}
          />
        ) : null;

      case "result":
        return (
          <Result winner={winner} isDraw={isDraw} onPlayAgain={playAgain} />
        );

      default:
        return (
          <Landing
            onPlayWithBot={startOfflineBotGame}
            onLogin={() => navigate("/auth", { replace: true })}
          />
        );
    }
  };

  useEffect(() => {
    socket.on("room-joined", (updatedPlayers) => {
      console.log("Players updated: ", updatedPlayers);
      setPlayers(updatedPlayers);
    });

    socket.on("game-start", ({ turnUserId }) => {
      setInitialTurnUserId(turnUserId);
      setPage("game");
    });

    return () => {
      socket.off("room-joined");
      socket.off("game-start");
    };
  }, []);

  return (
    <div className="app-shell">
      {(showBackButton || showLogoutButton || showCancelButton) && (
        <div className="app-actions">
          {showBackButton && (
            <button
              type="button"
              className="app-action-btn secondary"
              onClick={handleBack}
            >
              Back
            </button>
          )}

          {showCancelButton && (
            <button
              type="button"
              className="app-action-btn danger"
              onClick={handleCancelOrEndGame}
            >
              {actionButtonLabel}
            </button>
          )}

          {showLogoutButton && (
            <button
              type="button"
              className="app-action-btn secondary"
              onClick={handleLogout}
            >
              Logout
            </button>
          )}
        </div>
      )}

      {renderPage()}
    </div>
  );
};

export default App;
