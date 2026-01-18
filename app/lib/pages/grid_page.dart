import 'package:flutter/material.dart';
import '../models/cell_model.dart';
import 'game_page.dart';

class GridPage extends StatefulWidget {
  final Function(List<List<Cell>>)? onStartGame;
  GridPage({this.onStartGame});
  @override
  _GridPageState createState() => _GridPageState();
}

class _GridPageState extends State<GridPage> {
  List<List<Cell>> grid = List.generate(
    5,
    (_) => List.generate(5, (_) => Cell()),
  );
  Set<int> duplicates = {};

  void recomputeDuplicates() {
    Map<int, int> freq = {};
    for (var row in grid) {
      for (var cell in row) {
        if (cell.value != null) {
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

  void randomBox() {
    Set<int> used = {};
    List<List<Cell>> newGrid = List.generate(
      5,
      (_) => List.generate(5, (_) => Cell()),
    );
    for (int r = 0; r < 5; r++) {
      for (int c = 0; c < 5; c++) {
        int val;
        do {
          val =
              (1 +
              (25 *
                  (new DateTime.now().millisecondsSinceEpoch % 1000) ~/
                  1000));
        } while (used.contains(val));
        used.add(val);
        newGrid[r][c].value = val;
      }
    }
    setState(() {
      grid = newGrid;
      duplicates.clear();
    });
  }

  void goToGame() {
    if (duplicates.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Duplicate numbers are not allowed")),
      );
      return;
    }
    for (var row in grid) {
      for (var cell in row) {
        if (cell.value == null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Please fill all cells")));
          return;
        }
      }
    }

    if (widget.onStartGame != null) {
      // ✅ use callback if exists
      widget.onStartGame!(grid);
    } else {
      // fallback to default navigation if callback not provided
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => GamePage(grid: grid)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Bingo Grid Setup")),
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                crossAxisSpacing: 6,
                mainAxisSpacing: 6,
              ),
              itemCount: 25,
              itemBuilder: (_, index) {
                int r = index ~/ 5;
                int c = index % 5;
                Cell cell = grid[r][c];
                bool isDup =
                    cell.value != null && duplicates.contains(cell.value);
                return TextField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: isDup ? Colors.red[100] : Colors.white,
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (val) {
                    int? value = int.tryParse(val);
                    if (value != null && value >= 1 && value <= 25) {
                      setState(() {
                        grid[r][c].value = value;
                      });
                      recomputeDuplicates();
                    }
                  },
                  controller: TextEditingController(
                    text: cell.value?.toString() ?? "",
                  ),
                  textAlign: TextAlign.center,
                );
              },
            ),
          ),
          ElevatedButton(onPressed: randomBox, child: Text("Random Box")),
          ElevatedButton(onPressed: goToGame, child: Text("Go To Game")),
        ],
      ),
    );
  }
}
