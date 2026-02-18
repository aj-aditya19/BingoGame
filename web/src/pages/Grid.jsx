import React, { useState } from "react";
import "../styles/Grid.css";

const makeEmptyGrid = () =>
  Array.from({ length: 5 }, () =>
    Array.from({ length: 5 }, () => ({ value: null, chosen: false })),
  );

const Grid = ({ onDone }) => {
  const [grid, setGrid] = useState(makeEmptyGrid());
  const [duplicates, setDuplicates] = useState(new Set());

  const recomputeDuplicates = (nextGrid) => {
    const freq = new Map();

    nextGrid.flat().forEach((cell) => {
      if (cell.value !== null) {
        freq.set(cell.value, (freq.get(cell.value) || 0) + 1);
      }
    });

    const dups = new Set(
      [...freq.entries()].filter(([, c]) => c > 1).map(([v]) => v),
    );
    setDuplicates(dups);
  };

  const onChangeCell = (r, c, raw) => {
    const val = raw === "" ? null : Number(raw);

    if (val !== null && (!Number.isInteger(val) || val < 1 || val > 25)) return;

    setGrid((prev) => {
      const next = prev.map((row) => row.map((cell) => ({ ...cell })));
      next[r][c].value = val;
      recomputeDuplicates(next);
      return next;
    });
  };

  const randomBox = () => {
    const newGrid = makeEmptyGrid();
    const used = new Set();

    for (let r = 0; r < 5; r++) {
      for (let c = 0; c < 5; c++) {
        let val;
        do {
          val = Math.floor(Math.random() * 25) + 1;
        } while (used.has(val));

        used.add(val);
        newGrid[r][c].value = val;
      }
    }

    setGrid(newGrid);
    setDuplicates(new Set());
  };

  const continueNext = () => {
    if (duplicates.size > 0) {
      alert("Duplicate numbers are not allowed");
      return;
    }

    for (let r = 0; r < 5; r++) {
      for (let c = 0; c < 5; c++) {
        if (grid[r][c].value === null) {
          alert("Please fill all cells");
          return;
        }
      }
    }

    onDone(grid);
  };

  return (
    <div className="grid-container">
      <h3 className="grid-title">Create Your Bingo Grid</h3>

      <div className="grid-board">
        {grid.map((row, r) =>
          row.map((cell, c) => {
            const isDup = cell.value !== null && duplicates.has(cell.value);

            return (
              <input
                key={`${r}-${c}`}
                type="number"
                min={1}
                max={25}
                value={cell.value ?? ""}
                onChange={(e) => onChangeCell(r, c, e.target.value)}
                className={`grid-input ${isDup ? "duplicate" : ""}`}
              />
            );
          }),
        )}
      </div>

      <button onClick={randomBox} className="grid-btn random-btn">
        🎲 Random Box
      </button>

      <button onClick={continueNext} className="grid-btn continue-btn">
        Continue
      </button>
    </div>
  );
};

export default Grid;
