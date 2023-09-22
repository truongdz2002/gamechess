import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gamechess/components/piece.dart';
import 'package:gamechess/components/square.dart';
import 'package:gamechess/helper/helper_methods.dart';
import 'package:gamechess/values/colors.dart';

class GameBoard extends StatefulWidget {
  const GameBoard({Key? key}) : super(key: key);

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  //A 2-dimensional list representing the chessboard
  //with each possibly containing a chess piece
  late List<List<ChessPiece?>> board;
  //the currently selected piece on the chess board
 //if no piece is selected,this is null
  ChessPiece? selectedPiece;
  //the row index of the selected piece
  //Default value =-1 indicated no piece is currently selected
  int selectedRow=-1;
  //the column index of the selected piece
  //Default value =-1 indicated no piece is currently selected
  int selectedCol=-1;
  //A list of valid moves the selected piece
  //each move is represented as a list with 2 elements:row anh column
  List<List<int>> validMoves=[];
  //Move piece
  void movePiece(int newRow,int newCol)
  {
    //move the piece and clear the old spot
    board[newRow][newCol]==selectedPiece;
    board[selectedRow][selectedCol]=null;
    setState(() {
      selectedPiece=null;
      selectedRow=-1;
      selectedCol=-1;
      validMoves=[];
    });
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initialBoard();
  }
  void pieceSelected(int row,int col)
  {
    setState(() {
      //selected a piece if there is a piece in that position
      if(board[row][col]!=null)
        {
          selectedPiece=board[row][col];
          selectedRow=row;
          selectedCol=col;
        }
      //if there is a piece selected and user taps on a square that is valid move,move these
      else if(selectedPiece!=null && validMoves.any((element) => element[0]==row && element[1]==col)) {
        movePiece(row,col);
      }
      //if a piece is selected,calculate it is valid moves
      validMoves=calculateRawValidMoves(row,col,selectedPiece);
    });
  }
  //Calculate raw valid moves
  List<List<int>> calculateRawValidMoves(int row,int col,ChessPiece? piece)
  {
    List<List<int>> candidateMoves=[];
    if(piece==null)
      {
        return [];
      }
    //different directions based on their color
    int direction =piece.isWhite ? -1 :1;

    switch(piece!.type)
    {
      case ChessPieceType.pawn:
        //pawms can move forward if the square is not occupied
        if(isInBoard(row+direction, col) && board[row+direction][col]==null )
          {
            candidateMoves.add([row+direction,col]);
          }
       //pawns can move 2 quares forward if they are at their intial position
      if((row==1 && !piece.isWhite)||(row==6 && piece.isWhite))
        {
          if(isInBoard(row+direction, col) && board[row+2*direction][col]==null && board[row+direction][col]==null )
            {
              candidateMoves.add([row+2*direction,col]);
            }
        }
      //pawns can capture kill diagonally
        if(isInBoard(row+direction, col-1)&& board[row+direction][col-1]!=null&&board[row+direction][col-1]!.isWhite)
          {
            candidateMoves.add([row+direction,col-1]);
          }

        if(isInBoard(row+direction, col+1)&& board[row+direction][col+1]!=null&&board[row+direction][col+1]!.isWhite)
        {
          candidateMoves.add([row+direction,col+1]);
        }


        break;
      case ChessPieceType.rook:
        var directions=[
          [-1,0],//up
          [1,0],//down
          [0,-1],//left
          [0,1]//right
  ];
        for (var direction in directions)
          {
            var i=1;
            while(true)
              {
                var newRow=row+i*direction[0];
                var newCol=col+i*direction[1];
                if(!isInBoard(newRow, newCol))
                  {
                    break;
                  }
                if(board[newRow][newCol]!=null)
                  {
                    if(board[newRow][newCol]!.isWhite==piece.isWhite)
                      {
                        candidateMoves.add([newRow,newCol]);
                      }
                    break;//blocked
                  }
                candidateMoves.add([newRow,newCol]);
                i++;
              }
          }
        break;
      case ChessPieceType.knight:
        var knightMoves=[
          [-2,-1],//up 2 left 1
          [-2,1],//up 2 right 1
          [-1,-2],//up 1 left 2
          [-1,2],//up 1 right 2
          [1,-2],//down 1 left 2
          [1,2],//down 1 right 2
          [2,-1],//down 2 left 1
          [2,1],//down 2 right 1
        ];
        for(var move in knightMoves)
          {
            var newRow=row+move[0];
            var newCol=col+move[1];
            if(!isInBoard(newRow, newCol)){
              continue;
            }
            if(board[newRow][newCol]!=null)
              {
                if(board[newRow][newCol]!.isWhite!=piece.isWhite)
                  {
                    candidateMoves.add([newRow,newCol]);//capture
                  }
                continue;//blocked
              }
            candidateMoves.add([newRow,newCol]);
          }
        break;
      case ChessPieceType.bishop:
        var directions=[
          [-1,-1],//up left
          [-1,1],//up right
          [1,-1],//down left
          [1,1],//down right
        ];
        for(var direction in directions)
          {
            var i=1;
            while(true)
            {
              var newRow=row+i*direction[0];
              var newCol=col+i*direction[1];
              if(!isInBoard(newRow, newCol))
              {
                break;
              }
              if(board[newRow][newCol]!=null)
              {
                if(board[newRow][newCol]!.isWhite==piece.isWhite)
                {
                  candidateMoves.add([newRow,newCol]);
                }
                break;//blocked
              }
              candidateMoves.add([newRow,newCol]);
              i++;
            }
          }
        break;
      case ChessPieceType.queen:
        var directions=[
          [-1,0],//up
          [1,0],//down
          [0,-1],//left
          [0,1],//right
          [-1,-1],//up left
          [-1,1],//up right
          [1,-1],//down left
          [1,1],//dow right
        ];
        for(var direction in directions)
        {
          var i=1;
          while(true)
          {
            var newRow=row+i*direction[0];
            var newCol=col+i*direction[1];
            if(!isInBoard(newRow, newCol))
            {
              break;
            }
            if(board[newRow][newCol]!=null)
            {
              if(board[newRow][newCol]!.isWhite==piece.isWhite)
              {
                candidateMoves.add([newRow,newCol]);
              }
              break;//blocked
            }
            candidateMoves.add([newRow,newCol]);
            i++;
          }
        }

        break;
      case ChessPieceType.king:

        var directions=[
          [-1,0],//up
          [1,0],//down
          [0,-1],//left
          [0,1],//right
          [-1,-1],//up left
          [-1,1],//up right
          [1,-1],//down left
          [1,1],//dow right
        ];
        for(var direction in directions)
        {
          while(true)
          {
            var newRow=row+direction[0];
            var newCol=col+direction[1];
            if(!isInBoard(newRow, newCol))
            {
              continue;
            }
            if(board[newRow][newCol]!=null)
            {
              if(board[newRow][newCol]!.isWhite==piece.isWhite)
              {
                candidateMoves.add([newRow,newCol]);
              }
              continue;//blocked
            }
            candidateMoves.add([newRow,newCol]);
          }
        }
        break;
      default:
    }
    return candidateMoves;
  }
  void _initialBoard()
  {
    List<List<ChessPiece?>> newBoard=List.generate(8, (index) => List.generate(8,(index)=>null));
    //Place pawns
    for(int i=0;i<8;i++)
      {
        newBoard[1][i]=ChessPiece(type: ChessPieceType.pawn, isWhite: false, iconData: Icons.account_balance_rounded);
        newBoard[6][i]=ChessPiece(type: ChessPieceType.pawn, isWhite: true, iconData: Icons.account_balance_rounded);
      }
    //place rook
    newBoard[0][0]=ChessPiece(type: ChessPieceType.rook, isWhite: false, iconData:Icons.bike_scooter);
    newBoard[0][7]=ChessPiece(type: ChessPieceType.rook, isWhite: false, iconData:Icons.bike_scooter);
    newBoard[7][0]=ChessPiece(type: ChessPieceType.rook, isWhite: true, iconData:Icons.bike_scooter);
    newBoard[7][7]=ChessPiece(type: ChessPieceType.rook, isWhite: true, iconData:Icons.bike_scooter);
    //place knight
    newBoard[0][1]=ChessPiece(type: ChessPieceType.knight, isWhite: false, iconData:Icons.kayaking_sharp);
    newBoard[0][6]=ChessPiece(type: ChessPieceType.knight, isWhite: false, iconData:Icons.kayaking_sharp);
    newBoard[7][1]=ChessPiece(type: ChessPieceType.knight, isWhite: true, iconData:Icons.kayaking_sharp);
    newBoard[7][6]=ChessPiece(type: ChessPieceType.knight, isWhite: true, iconData:Icons.kayaking_sharp);
    //place bishop
    newBoard[0][2]=ChessPiece(type: ChessPieceType.bishop, isWhite: false, iconData:Icons.rocket_launch);
    newBoard[0][5]=ChessPiece(type: ChessPieceType.bishop, isWhite: false, iconData:Icons.rocket_launch);
    newBoard[7][2]=ChessPiece(type: ChessPieceType.bishop, isWhite: true, iconData:Icons.rocket_launch);
    newBoard[7][5]=ChessPiece(type: ChessPieceType.bishop, isWhite: true, iconData:Icons.rocket_launch);
    //place queen
    newBoard[0][3]=ChessPiece(type: ChessPieceType.queen, isWhite: false, iconData:Icons.sunny_snowing);
    newBoard[7][4]=ChessPiece(type: ChessPieceType.queen, isWhite: true, iconData:Icons.sunny_snowing);
   //place king
    newBoard[0][4]=ChessPiece(type: ChessPieceType.king, isWhite: false, iconData:Icons.sunny);
    newBoard[7][3]=ChessPiece(type: ChessPieceType.king, isWhite: true, iconData:Icons.sunny);




    board=newBoard;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: GridView.builder(
          itemCount: 8*8,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 8),
          itemBuilder:(context,index)
      {
        int x=index ~/8;//this is gives us the integer division ie,row
        int y=index % 8;//this gives us remainder ie,column
        bool isSelected= selectedRow==x &&selectedCol==y;
        //check if this square is a valid move
        bool isValidMove=false;
        for(var position in validMoves)
          {
            if(position[0]==x && position[1]==y)
              {
                isValidMove=true;
              }
          }
        return Square(isWhite:isWhite(index),piece: board[x][y],isSelected: isSelected,onTap: ()=>pieceSelected(x,y), isValidMove: isValidMove,);
      }),
    );
  }
}
