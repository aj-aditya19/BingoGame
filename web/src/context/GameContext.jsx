import { createContext, useContext, useState } from "react";

const GameContext = createContext();

export const GameProvider = ({ children }) => {
  const [roomId, setRoomId] = useState(null);
  const [players, setPlayers] = useState([]);
  const [isHost, setIsHost] = useState(false);

  return (
    <GameContext.Provider
      value={{
        roomId,
        setRoomId,
        players,
        setPlayers,
        isHost,
        setIsHost,
      }}
    >
      {children}
    </GameContext.Provider>
  );
};

export const useGame = () => useContext(GameContext);
