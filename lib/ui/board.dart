import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mine_sweeper_game/ui/tile.dart';

class Board extends StatefulWidget {
  @override
  _BoardState createState() => _BoardState();
}

class _BoardState extends State<Board> {
  final int rows = 9;
  final int columns = 9;
  final int numOfMines = 11;
  List<List<TileState>> minesStates;
  List<List<bool>> tiles;

  bool alive;
  bool wonGame;
  int minesFound;
  Timer timer;
  Stopwatch stopwatch = Stopwatch();

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    resetBoard();
  }

  void resetBoard() {
    alive = true;
    wonGame = false;
    minesFound = 0;
    stopwatch.reset();

    timer?.cancel();
    timer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
      setState(() {});
    });

    minesStates = List<List<TileState>>.generate(rows, (row) {
      return List<TileState>.filled(columns, TileState.covered);
    });
    tiles = List<List<bool>>.generate(rows, (row) {
      return List<bool>.filled(columns, false);
    });
    Random random = Random();
    int remainingMines = numOfMines;
    while (remainingMines > 0) {
      int pos = random.nextInt(rows * columns);
      int row = pos ~/ columns;
      int col = pos % columns;
      if (!tiles[row][col]) {
        tiles[row][col] = true;
        remainingMines--;
      }
    }
  }

  Widget buildBoard() {
    bool hasCoveredCell;
    List<Row> boardRow = <Row>[];
    for (int y = 0; y < rows; y++) {
      List<Widget> rowChildren = <Widget>[];
      for (int x = 0; x < columns; x++) {
        TileState state = minesStates[y][x];
        int count = mineCount(x, y);
        if (!alive) {
          if (state != TileState.blown) {
            state = tiles[y][x] ? TileState.revealed : state;
          }
        }
        if (state == TileState.covered || state == TileState.flagged) {
          rowChildren.add(GestureDetector(
            onTap: () {
              if (state == TileState.covered) probe(x, y);
            },
            onLongPress: () {
              flag(x, y);
            },
            child: Listener(
              child: CoveredMineTile(
                flagged: state == TileState.flagged,
                posX: x,
                posY: y,
              ),
            ),
          ));
          if (state == TileState.covered) {
            hasCoveredCell = true;
          }
        } else {
          rowChildren.add(OpenMineTile(state: state, count: count));
        }
      }
      boardRow.add(Row(
        children: rowChildren,
        mainAxisAlignment: MainAxisAlignment.center,
        key: ValueKey<int>(y),
      ));
    }
    if (!hasCoveredCell) {
      if ((minesFound == numOfMines) && alive) {
        wonGame = true;
        stopwatch.stop();
      }
    }
    return Container(
      color: Colors.grey[700],
      padding: EdgeInsets.all(8.0),
      child: Column(children: boardRow),
    );
  }

  void probe(int x, int y) {
    if (!alive) return;
    if (minesStates[y][x] == TileState.flagged) return;
    setState(() {
      if (tiles[y][x]) {
        minesStates[y][x] = TileState.blown;
        alive = false;
        timer.cancel();
      } else {
        open(x, y);
        if (!stopwatch.isRunning) stopwatch.start();
      }
    });
  }

  void open(int x, int y) {
    setState(() {
      if (!inBoard(x, y)) return;
      if (minesStates[y][x] == TileState.open) return;
      minesStates[y][x] = TileState.open;
      if (mineCount(x, y) > 0) return;
      open(x - 1, y);
      open(x + 1, y);
      open(x, y - 1);
      open(x, y + 1);
      open(x - 1, y - 1);
      open(x + 1, y + 1);
      open(x + 1, y - 1);
      open(x - 1, y + 1);
    });
  }

  void flag(int x, int y) {
    if (!alive) return;
    setState(() {
      if (minesStates[y][x] == TileState.flagged) {
        minesStates[y][x] = TileState.covered;
        --minesFound;
      } else {
        minesStates[y][x] = TileState.flagged;
        ++minesFound;
      }
    });
  }

  int mineCount(int x, int y) {
    int count = 0;
    count += bombs(x - 1, y);
    count += bombs(x + 1, y);
    count += bombs(x, y - 1);
    count += bombs(x, y + 1);
    count += bombs(x - 1, y - 1);
    count += bombs(x + 1, y + 1);
    count += bombs(x + 1, y - 1);
    count += bombs(x - 1, y + 1);
    return count;
  }

  int bombs(int x, int y) => inBoard(x, y) && tiles[y][x] ? 1 : 0;

  bool inBoard(int x, int y) => x >= 0 && x < columns && y >= 0 && y < rows;

  @override
  Widget build(BuildContext context) {
    int timeElapsed = stopwatch.elapsedMilliseconds ~/ 1000;
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: Text('Mine Sweeper'),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(45.0),
          child: Row(
            children: <Widget>[
              Container(
                padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 2.0),
                child: FlatButton(
                  child: Text(
                    'Reset board',
                    style: TextStyle(color: Colors.white),
                  ),
                  highlightColor: Colors.green,
                  splashColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: Colors.blue[200]),
                  ),
                  color: Colors.blueAccent[100],
                  onPressed: () => resetBoard(),
                ),
              ),
              SizedBox(
                width: 2.0,
              ),
              Container(
                height: 40.0,
                alignment: Alignment.center,
                child: RichText(
                  text: TextSpan(
                      text: wonGame
                          ? 'You\'ve Won ! $timeElapsed seconds'
                          : alive
                              ? '[mines found: $minesFound] [total mines: $numOfMines] [$timeElapsed seconds]'
                              : 'You\'ve lost ! $timeElapsed seconds'),
                ),
              )
            ],
          ),
        ),
      ),
      body: Container(
        color: Colors.grey[50],
        child: Center(
          child: buildBoard(),
        ),
      ),
    );
  }
}

enum TileState { covered, blown, open, flagged, revealed }
