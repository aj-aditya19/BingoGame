import 'dart:math';

class BingoGameUtils {
  static List<int> getAvailableNumbers(List<List<Map<String, dynamic>>> grid) {
    final available = <int>[];
    for (int i = 1; i <= 25; i++) {
      bool found = false;
      for (var row in grid) {
        for (var cell in row) {
          if (cell['value'] == i && cell['chosen'] == true) {
            found = true;
            break;
          }
        }
        if (found) break;
      }
      if (!found) {
        available.add(i);
      }
    }
    return available;
  }

  static Map<String, dynamic> markNumber(
    List<List<Map<String, dynamic>>> grid,
    int number,
  ) {
    final newGrid = grid.map((row) {
      return row.map((cell) {
        if (cell['value'] == number) {
          return {...cell, 'chosen': true};
        }
        return cell;
      }).toList();
    }).toList();

    return {'newGrid': newGrid};
  }

  static bool _checkWin(List<List<Map<String, dynamic>>> grid) {
    // Check rows
    for (var row in grid) {
      if (row.every((cell) => cell['chosen'] == true)) {
        return true;
      }
    }

    // Check columns
    for (int col = 0; col < 5; col++) {
      bool colWin = true;
      for (int row = 0; row < 5; row++) {
        if (grid[row][col]['chosen'] != true) {
          colWin = false;
          break;
        }
      }
      if (colWin) return true;
    }

    // Check diagonals
    bool diag1 = true;
    bool diag2 = true;
    for (int i = 0; i < 5; i++) {
      if (grid[i][i]['chosen'] != true) diag1 = false;
      if (grid[i][4 - i]['chosen'] != true) diag2 = false;
    }

    return diag1 || diag2;
  }

  static Map<String, dynamic> evaluateGrid(
    List<List<Map<String, dynamic>>> grid,
  ) {
    int score = 0;

    // Score rows
    for (var row in grid) {
      int count = row.where((cell) => cell['chosen'] == true).length;
      score += count * count;
    }

    // Score columns
    for (int col = 0; col < 5; col++) {
      int count = 0;
      for (int row = 0; row < 5; row++) {
        if (grid[row][col]['chosen'] == true) count++;
      }
      score += count * count;
    }

    // Score diagonals
    int diag1 = 0;
    int diag2 = 0;
    for (int i = 0; i < 5; i++) {
      if (grid[i][i]['chosen'] == true) diag1++;
      if (grid[i][4 - i]['chosen'] == true) diag2++;
    }
    score += diag1 * diag1 + diag2 * diag2;

    final win = _checkWin(grid);

    return {'score': score, 'win': win, 'newGrid': grid};
  }

  static int? pickBotMove(
    List<List<Map<String, dynamic>>> botGrid,
    List<List<Map<String, dynamic>>> humanGrid,
  ) {
    final candidates = getAvailableNumbers(botGrid);

    if (candidates.isEmpty) return null;

    int bestMove = candidates[0];
    double bestScore = double.negativeInfinity;

    for (int candidate in candidates) {
      final nextBotResult = markNumber(botGrid, candidate);
      final nextBotEval = evaluateGrid(nextBotResult['newGrid']);

      final nextHumanResult = markNumber(humanGrid, candidate);
      final nextHumanEval = evaluateGrid(nextHumanResult['newGrid']);

      // If both can win with this number, prioritize blocking
      if (nextBotEval['win'] && nextHumanEval['win']) {
        if (bestScore < 5000) {
          bestMove = candidate;
          bestScore = 5000;
        }
        continue;
      }

      // If bot wins with this move, take it
      if (nextBotEval['win']) {
        if (bestScore < 10000) {
          bestMove = candidate;
          bestScore = 10000;
        }
        continue;
      }

      // If human would win, block it
      if (nextHumanEval['win']) {
        if (bestScore < -10000) {
          bestMove = candidate;
          bestScore = -10000;
        }
        continue;
      }

      // Look ahead one move
      final remainingNumbers = getAvailableNumbers(nextBotEval['newGrid']);
      double worstHumanReply = double.infinity;

      for (int reply in remainingNumbers) {
        final replyBotResult = markNumber(nextBotEval['newGrid'], reply);
        final replyBotEval = evaluateGrid(replyBotResult['newGrid']);

        final replyHumanResult = markNumber(nextHumanEval['newGrid'], reply);
        final replyHumanEval = evaluateGrid(replyHumanResult['newGrid']);

        final replyScore =
            (replyBotEval['score'] as int) - (replyHumanEval['score'] as int);
        worstHumanReply = min(worstHumanReply, replyScore.toDouble());
      }

      final moveScore =
          (nextBotEval['score'] as int) -
          (nextHumanEval['score'] as int) +
          worstHumanReply;

      if (moveScore > bestScore) {
        bestScore = moveScore;
        bestMove = candidate;
      }
    }

    return bestMove;
  }
}
