import 'package:flutter/material.dart';
import '../models/cell_model.dart';

class GamePage extends StatefulWidget {
  final List<List<Cell>> grid;

  GamePage({required this.grid});

  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  late List<List<Cell>> gameGrid;

  @override
  void initState() {
    super.initState();
    gameGrid = widget.grid
        .map(
          (row) => row.map((c) => Cell(value: c.value, chosen: false)).toList(),
        )
        .toList();
  }

  void toggleCell(int r, int c) {
    setState(() {
      gameGrid[r][c].chosen = !gameGrid[r][c].chosen;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Bingo Game")),
      body: GridView.builder(
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
          Cell cell = gameGrid[r][c];
          return GestureDetector(
            onTap: () => toggleCell(r, c),
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: cell.chosen ? Colors.green : Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                cell.value.toString(),
                style: TextStyle(fontSize: 18),
              ),
            ),
          );
        },
      ),
    );
  }
}
