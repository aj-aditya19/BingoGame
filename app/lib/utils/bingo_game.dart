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
    int completedLines = 0;
    for (int r = 0; r < 5; r++) {
      if (grid[r].every((cell) => cell['chosen'] == true)) {
        completedLines++;
      }
    }

    for (int c = 0; c < 5; c++) {
      bool full = true;
      for (int r = 0; r < 5; r++) {
        if (grid[r][c]['chosen'] != true) {
          full = false;
          break;
        }
      }
      if (full) {
        completedLines++;
      }
    }

    bool diag1 = true;
    for (int i = 0; i < 5; i++) {
      if (grid[i][i]['chosen'] != true) {
        diag1 = false;
        break;
      }
    }
    if (diag1) {
      completedLines++;
    }
    bool diag2 = true;
    for (int i = 0; i < 5; i++) {
      if (grid[i][4 - i]['chosen'] != true) {
        diag2 = false;
        break;
      }
    }

    if (diag2) {
      completedLines++;
    }

    return completedLines >= 5;
  }

  static Map<String, dynamic> evaluateGrid(
    List<List<Map<String, dynamic>>> grid,
  ) {
    int score = 0;

    final updated = grid
        .map((row) => row.map((cell) => {...cell, "completed": false}).toList())
        .toList();

    int completedLines = 0;

    for (int r = 0; r < 5; r++) {
      int count = updated[r].where((cell) => cell["chosen"] == true).length;
      score += count * count;

      if (count == 5) {
        completedLines++;
        for (var cell in updated[r]) {
          cell["completed"] = true;
        }
      }
    }

    for (int c = 0; c < 5; c++) {
      int count = 0;

      for (int r = 0; r < 5; r++) {
        if (updated[r][c]["chosen"] == true) count++;
      }

      score += count * count;

      if (count == 5) {
        completedLines++;

        for (int r = 0; r < 5; r++) {
          updated[r][c]["completed"] = true;
        }
      }
    }

    int diag1 = 0;

    for (int i = 0; i < 5; i++) {
      if (updated[i][i]["chosen"] == true) diag1++;
    }

    score += diag1 * diag1;

    if (diag1 == 5) {
      completedLines++;

      for (int i = 0; i < 5; i++) {
        updated[i][i]["completed"] = true;
      }
    }

    int diag2 = 0;

    for (int i = 0; i < 5; i++) {
      if (updated[i][4 - i]["chosen"] == true) diag2++;
    }

    score += diag2 * diag2;

    if (diag2 == 5) {
      completedLines++;

      for (int i = 0; i < 5; i++) {
        updated[i][4 - i]["completed"] = true;
      }
    }

    return {"score": score, "win": completedLines >= 5, "newGrid": updated};
  }

  static int? pickBotMove(
    List<List<Map<String, dynamic>>> botGrid,
    List<List<Map<String, dynamic>>> humanGrid,
  ) {
    final random = Random();
    final candidates = getAvailableNumbers(botGrid);

    if (candidates.isEmpty) return null;

    int bestMove = candidates[0];
    double bestScore = double.negativeInfinity;

    for (int candidate in candidates) {
      final nextBotResult = markNumber(botGrid, candidate);
      final nextBotEval = evaluateGrid(nextBotResult['newGrid']);

      final nextHumanResult = markNumber(humanGrid, candidate);
      final nextHumanEval = evaluateGrid(nextHumanResult['newGrid']);

      if (nextBotEval['win'] && nextHumanEval['win']) {
        if (bestScore < 5000) {
          bestMove = candidate;
          bestScore = 5000;
        }
        continue;
      }

      if (nextBotEval['win']) {
        if (bestScore < 10000) {
          bestMove = candidate;
          bestScore = 10000;
        }
        continue;
      }

      if (nextHumanEval['win']) {
        if (bestScore < -10000) {
          bestMove = candidate;
          bestScore = -10000;
        }
        continue;
      }

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

    if (random.nextBool()) {
      return bestMove;
    } else {
      return candidates[random.nextInt(candidates.length)];
    }
  }
}
