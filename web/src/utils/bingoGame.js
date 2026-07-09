const GRID_SIZE = 5;

export const cloneGrid = (sourceGrid = []) =>
  sourceGrid.map((row) => row.map((cell) => ({ ...cell })));

export const markNumber = (sourceGrid = [], number) =>
  sourceGrid.map((row) =>
    row.map((cell) =>
      cell.value === number ? { ...cell, chosen: true } : { ...cell },
    ),
  );

export const evaluateGrid = (grid = []) => {
  const updated = grid.map((row) =>
    row.map((cell) => ({ ...cell, completed: false })),
  );

  const lines = [];

  for (let rowIndex = 0; rowIndex < GRID_SIZE; rowIndex += 1) {
    lines.push(updated[rowIndex]);
  }

  for (let columnIndex = 0; columnIndex < GRID_SIZE; columnIndex += 1) {
    lines.push(updated.map((row) => row[columnIndex]));
  }

  lines.push(updated.map((row, index) => row[index]));
  lines.push(updated.map((row, index) => row[GRID_SIZE - 1 - index]));

  let completedLines = 0;

  lines.forEach((line) => {
    const chosenCount = line.filter((cell) => cell.chosen).length;

    if (chosenCount === GRID_SIZE) {
      completedLines += 1;
      line.forEach((cell) => {
        cell.completed = true;
      });
    }
  });

  const score = lines.reduce((total, line) => {
    const chosenCount = line.filter((cell) => cell.chosen).length;

    if (chosenCount === GRID_SIZE) return total + 1000;
    if (chosenCount === GRID_SIZE - 1) return total + 160;
    if (chosenCount === GRID_SIZE - 2) return total + 40;
    if (chosenCount === GRID_SIZE - 3) return total + 10;
    return total + chosenCount * chosenCount;
  }, 0);

  return {
    newGrid: updated,
    win: completedLines >= 5,
    score,
  };
};

export const getAvailableNumbers = (grid = []) =>
  grid
    .flat()
    .filter((cell) => !cell.chosen)
    .map((cell) => cell.value);

export const pickBotMove = (botGrid = [], humanGrid = []) => {
  const candidates = getAvailableNumbers(botGrid);

  if (candidates.length === 0) return null;

  let bestMove = candidates[0];
  let bestScore = -Infinity;

  candidates.forEach((candidate) => {
    const nextBot = evaluateGrid(markNumber(botGrid, candidate));
    const nextHuman = evaluateGrid(markNumber(humanGrid, candidate));

    if (nextBot.win && nextHuman.win) {
      if (bestScore < 5000) {
        bestMove = candidate;
        bestScore = 5000;
      }
      return;
    }

    if (nextBot.win) {
      if (bestScore < 10000) {
        bestMove = candidate;
        bestScore = 10000;
      }
      return;
    }

    if (nextHuman.win) {
      if (bestScore < -10000) {
        bestMove = candidate;
        bestScore = -10000;
      }
      return;
    }

    const remainingNumbers = getAvailableNumbers(nextBot.newGrid);
    let worstHumanReply = Infinity;

    remainingNumbers.forEach((reply) => {
      const replyBot = evaluateGrid(markNumber(nextBot.newGrid, reply));
      const replyHuman = evaluateGrid(markNumber(nextHuman.newGrid, reply));

      const replyScore = replyBot.score - replyHuman.score;
      worstHumanReply = Math.min(worstHumanReply, replyScore);
    });

    const moveScore = nextBot.score - nextHuman.score + worstHumanReply;

    if (moveScore > bestScore) {
      bestScore = moveScore;
      bestMove = candidate;
    }
  });

  return bestMove;
};
