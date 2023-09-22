import 'package:flutter/material.dart';
import 'package:gamechess/components/piece.dart';

import '../values/colors.dart';

class Square extends StatelessWidget {
  final bool isWhite;
  final ChessPiece? piece;
  final bool isSelected;
  final void Function()? onTap;
  final bool isValidMove;
  const Square({Key? key, required this.isWhite, this.piece, required this.isSelected, this.onTap, required this.isValidMove}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color? squareColor;
    if(isSelected)
      {
        squareColor=Colors.green;

      }
    else if(isValidMove)
      {
        squareColor=Colors.green[300];
      }
    else
      {
        squareColor=isWhite? foregroundColor:backgroundColor;
      }
    return GestureDetector(
      onTap:onTap ,
      child: Container(
        color: squareColor,
        margin: EdgeInsets.all(isValidMove ? 8 :0),
        child: piece!=null
           ?Icon(
              piece!.iconData,
              color: piece!.isWhite ? Colors.white : Colors.black,)
            :null,
      ),
    );
  }
}
