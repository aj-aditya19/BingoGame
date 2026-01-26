import 'dart:math';
import 'package:flutter/material.dart';
import '../models/cell_model.dart';

class GridScreen extends StatefulWidget {
  final Function(List<List<CellModel>>) onDone;

  const GridScreen({super.key, required this.onDone});

  @override
  State<GridScreen> createState() => _GridScreenState();
}

class _GridScreenState extends State<GridScreen> {
  late List<List<CellModel>> grid;
  late List<List<TextEditingController>> controllers;
  Set<int> duplicates = {};

  @override
  void initState() {
    super.initState();
    grid = _makeEmptyGrid();
    controllers = List.generate(
      5,
      (_) => List.generate(5, (_) => TextEditingController()),
    );
  }

  List<List<CellModel>> _makeEmptyGrid() {
    return List.generate(
      5,
      (_) => List.generate(5, (_) => CellModel(value: -1)),
    );
  }

  void _recomputeDuplicates() {
    final Map<int, int> freq = {};

    for (var row in grid) {
      for (var cell in row) {
        if (cell.value != -1) {
          freq[cell.value!] = (freq[cell.value!] ?? 0) + 1;
        }
      }
    }

    setState(() {
      duplicates = freq.entries
          .where((e) => e.value > 1)
          .map((e) => e.key)
          .toSet();
    });
  }

  void _onChangeCell(int r, int c, String raw) {
    if (raw.isEmpty) {
      grid[r][c].value = -1;
      _recomputeDuplicates();
      return;
    }

    final val = int.tryParse(raw);
    if (val == null || val < 1 || val > 25) return;

    grid[r][c].value = val;
    _recomputeDuplicates();
  }

  void _randomBox() {
    final rand = Random();
    final used = <int>{};

    for (int r = 0; r < 5; r++) {
      for (int c = 0; c < 5; c++) {
        int val;
        do {
          val = rand.nextInt(25) + 1;
        } while (used.contains(val));

        used.add(val);
        grid[r][c].value = val;
        controllers[r][c].text = val.toString();
      }
    }

    setState(() => duplicates.clear());
  }

  void _continueNext() {
    if (duplicates.isNotEmpty) {
      _showAlert("Duplicate numbers are not allowed");
      return;
    }

    for (var row in grid) {
      for (var cell in row) {
        if (cell.value == -1) {
          print("Please fill all cells");
          return;
        }
      }
    }

    widget.onDone(grid);
  }

  void _showAlert(String msg) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    for (var row in controllers) {
      for (var c in row) {
        c.dispose();
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Your Bingo Grid")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: GridView.builder(
                itemCount: 25,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  crossAxisSpacing: 6,
                  mainAxisSpacing: 6,
                ),
                itemBuilder: (context, index) {
                  final r = index ~/ 5;
                  final c = index % 5;
                  final cell = grid[r][c];
                  final isDup =
                      cell.value != -1 && duplicates.contains(cell.value);

                  return TextField(
                    controller: controllers[r][c],
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    onChanged: (v) => _onChangeCell(r, c, v),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: isDup ? Colors.red.shade100 : Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: isDup ? Colors.red : Colors.grey,
                          width: isDup ? 2 : 1,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: _randomBox,
              child: const Text("Random Box"),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _continueNext,
              child: const Text("Continue"),
            ),
          ],
        ),
      ),
    );
  }
}
