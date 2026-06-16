import 'dart:math';

import 'package:flutter/material.dart';

class GridScreen extends StatefulWidget {
  final Function(List<List<Map<String, dynamic>>>) onDone;

  const GridScreen({super.key, required this.onDone});

  @override
  State<GridScreen> createState() => _GridScreenState();
}

class _GridScreenState extends State<GridScreen> {
  late List<List<Map<String, dynamic>>> grid;
  Set<int> duplicates = {};

  @override
  void initState() {
    super.initState();
    grid = makeEmptyGrid();
  }

  List<List<Map<String, dynamic>>> makeEmptyGrid() {
    return List.generate(
      5,
      (_) => List.generate(5, (_) => {"value": null, "chosen": false}),
    );
  }

  void recomputeDuplicates(List<List<Map<String, dynamic>>> nextGrid) {
    final Map<int, int> freq = {};

    for (var row in nextGrid) {
      for (var cell in row) {
        final value = cell["value"];

        if (value != null) {
          freq[value] = (freq[value] ?? 0) + 1;
        }
      }
    }

    final Set<int> dups = {};

    freq.forEach((key, count) {
      if (count > 1) {
        dups.add(key);
      }
    });

    setState(() {
      duplicates = dups;
    });
  }

  void onChangeCell(int row, int col, String value) {
    int? parsed;

    if (value.isNotEmpty) {
      parsed = int.tryParse(value);

      if (parsed == null) return;

      if (parsed < 1 || parsed > 25) {
        return;
      }
    }

    final nextGrid = grid
        .map((r) => r.map((c) => Map<String, dynamic>.from(c)).toList())
        .toList();

    nextGrid[row][col]["value"] = parsed;

    setState(() {
      grid = nextGrid;
    });

    recomputeDuplicates(nextGrid);
  }

  void randomBox() {
    final random = Random();

    final newGrid = makeEmptyGrid();

    final used = <int>{};

    for (int r = 0; r < 5; r++) {
      for (int c = 0; c < 5; c++) {
        int value;

        do {
          value = random.nextInt(25) + 1;
        } while (used.contains(value));

        used.add(value);

        newGrid[r][c]["value"] = value;
      }
    }

    setState(() {
      grid = newGrid;
      duplicates = {};
    });
  }

  void continueNext() {
    if (duplicates.isNotEmpty) {
      showMessage("Duplicate numbers are not allowed");
      return;
    }

    for (var row in grid) {
      for (var cell in row) {
        if (cell["value"] == null) {
          showMessage("Please fill all cells");
          return;
        }
      }
    }

    widget.onDone(grid);
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final cells = grid.expand((e) => e).toList();

    return Scaffold(
      appBar: AppBar(title: const Text("Create Your Bingo Grid")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: GridView.builder(
                itemCount: cells.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemBuilder: (context, index) {
                  final row = index ~/ 5;
                  final col = index % 5;

                  final cell = grid[row][col];

                  final isDup =
                      cell["value"] != null &&
                      duplicates.contains(cell["value"]);

                  return TextFormField(
                    initialValue: cell["value"]?.toString() ?? "",
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: isDup ? Colors.red.shade100 : null,
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      onChangeCell(row, col, value);
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: randomBox,
                child: const Text("🎲 Random Box"),
              ),
            ),

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: continueNext,
                child: const Text("Continue"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
