import { useEffect } from "react";

const CreateBot = ({ setBotPlayer, setBotGrid, onReady }) => {
  useEffect(() => {
    const botPlayer = {
      _id: "bot",
      name: "Bingo Bot",
      role: "Bot",
    };

    const used = new Set();

    const grid = Array.from({ length: 5 }, () =>
      Array.from({ length: 5 }, () => {
        let num;

        do {
          num = Math.floor(Math.random() * 25) + 1;
        } while (used.has(num));

        used.add(num);

        return {
          value: num,
          chosen: false,
        };
      }),
    );

    setBotPlayer(botPlayer);
    setBotGrid(grid);

    onReady();
  }, []);

  return <h2>Preparing Bot...</h2>;
};

export default CreateBot;
