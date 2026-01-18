import React, { useState } from "react";
import Home from "./pages/Home";
import Login from "./pages/Login";
import Register from "./pages/Register";
import Grid from "./pages/Grid";
import Game from "./pages/Game";
import SetPassword from "./pages/SetPassword";

const App = () => {
  const [page, setPage] = useState("login");
  const [gameGrid, setGameGrid] = useState(null);

  return (
    <div>
      {page === "login" && (
        <Login
          onLogin={(next) => setPage(next || "input")}
          onRegister={() => setPage("register")}
        />
      )}

      {page === "register" && (
        <Register onRegister={(next) => setPage(next || "input")} />
      )}

      {page === "set-password" && (
        <SetPassword onDone={() => setPage("input")} />
      )}

      {page === "input" && (
        <Grid
          onStartGame={(grid) => {
            setGameGrid(grid);
            setPage("game");
          }}
        />
      )}

      {page === "game" && <Game grid={gameGrid} />}
    </div>
  );
};

export default App;
