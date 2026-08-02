import 'dart:math';

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

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

    // return SingleChildScrollView(
    // child: Scaffold(
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: Column(
                    children: [
                      Text(
                        "Create Your Bingo Grid",
                        style: TextStyle(
                          color: const Color.fromARGB(255, 0, 0, 0),
                          fontSize: 20,
                        ),
                      ),
                      const Text(
                        "Fill 1-25, no repeats",
                        style: TextStyle(color: AppColors.muted, fontSize: 13),
                      ),

                      const SizedBox(height: 10),

                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.panel,
                          border: Border.all(color: AppColors.line),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: cells.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 5,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                                childAspectRatio: 1,
                              ),
                          itemBuilder: (context, index) {
                            final row = index ~/ 5;
                            final col = index % 5;

                            final cell = grid[row][col];

                            final isDup =
                                cell["value"] != null &&
                                duplicates.contains(cell["value"]);

                            return TextFormField(
                              key: ValueKey("${row}_${col}_${cell["value"]}"),
                              initialValue: cell["value"]?.toString() ?? "",
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.text,
                              ),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: isDup
                                    ? const Color(0xFFFFF1F2)
                                    : AppColors.bgSoft,
                                contentPadding: EdgeInsets.zero,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: isDup
                                        ? AppColors.danger
                                        : AppColors.line,
                                  ),
                                ),
                              ),
                              onChanged: (value) {
                                onChangeCell(row, col, value);
                              },
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 14),

                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: randomBox,
                          child: const Text("🎲 Random Box"),
                        ),
                      ),

                      const SizedBox(height: 10),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: continueNext,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accent,
                          ),
                          child: const Text("Continue"),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
