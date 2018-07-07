import 'package:flutter/material.dart';
import 'package:mine_sweeper_game/ui/board.dart';

class CoveredMineTile extends StatelessWidget {
  final bool flagged;
  final int posX;
  final int posY;

  CoveredMineTile({this.flagged, this.posX, this.posY});

  @override
  Widget build(BuildContext context) {
    Widget text;
    if (flagged) {
      text = buildInnerTile(RichText(
        text: TextSpan(
            text: "\u2691",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        textAlign: TextAlign.center,
      ));
    }
    Widget innerTile = Container(
      padding: EdgeInsets.all(1.0),
      margin: EdgeInsets.all(2.0),
      height: 20.0,
      width: 20.0,
      color: Colors.grey[350],
      child: text,
    );
    return buildTile(innerTile);
  }
}

class OpenMineTile extends StatelessWidget {
  final TileState state;
  final int count;

  OpenMineTile({this.state, this.count});

  List textColors = [
    Colors.blue,
    Colors.green,
    Colors.red,
    Colors.purple,
    Colors.cyan,
    Colors.amber,
    Colors.brown,
    Colors.black
  ];

  @override
  Widget build(BuildContext context) {
    Widget text;
    if (state == TileState.open) {
      if (count != 0) {
        text = RichText(
          text: TextSpan(
              text: '$count',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: textColors[count-1],
              )),
          textAlign: TextAlign.center,
        );
      }
    } else {
      text = RichText(
        text: TextSpan(
            text: '\u2739',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.red,
            )),
        textAlign: TextAlign.center,
      );
    }
    return buildTile(buildInnerTile(text));
  }
}

Widget buildTile(Widget child) {
  return Container(
    padding: EdgeInsets.all(1.0),
    height: 30.0,
    width: 30.0,
    color: Colors.grey[400],
    margin: EdgeInsets.all(2.0),
    child: child,
  );
}

Widget buildInnerTile(Widget child) {
  return Container(
    padding: EdgeInsets.all(1.0),
    height: 20.0,
    width: 20.0,
    margin: EdgeInsets.all(2.0),
    child: child,
  );
}
