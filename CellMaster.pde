class CellMaster {
  boolean passed = false;
  Cell[] cells = new Cell[64];

  float progress;
  PGraphics board;
  int[][][] preStates = new int[2][8][8];
  CellMaster(PGraphics _board) {
    initialize();
    board = _board;
  }

  void initialize() {
    for (int y=0; y<8; ++y) {
      for (int x=0; x<8; ++x) {
        cells[x+y*8] = new Cell(x, y, NONE);
      }
    }
    getCell(3, 3).setState(WHITE);
    getCell(3, 3).setNextState(WHITE);
    getCell(4, 3).setState(BLACK);
    getCell(4, 3).setNextState(BLACK);
    getCell(4, 4).setState(WHITE);
    getCell(4, 4).setNextState(WHITE);
    getCell(3, 4).setState(BLACK);
    getCell(3, 4).setNextState(BLACK);
  }

  Cell getCell(int x, int y) {
    return cells[y*8+x];
  }

  void update() {
    if (countNone()==0) {
      game_over = true;//gameover
      step = ANIMATION;
      return;
    }
    checkGameOver();  //置けるかどうかのチェック
  }

  void draw(int _x, int _y, boolean hint) {
    // board
    drawBoard(board);
    // draw stones
    drawStones(board, hint);
    image(board, _x, _y);
  }

  void draw(int _x, int _y) {
    drawBoard(board);
    image(board, _x, _y);
  }

  void drawBoard(PGraphics board) {
    board.beginDraw();
    board.background(0);
    board.stroke(255);
    for (int i=0; i<8; ++i) {
      board.line(i*SIZE, 0, i*SIZE, SIZE*8);
      board.line(0, i*SIZE, SIZE*8, i*SIZE);
    }
    board.line(SIZE*8-1, 0, SIZE*8-1, SIZE*8);
    board.line(0, SIZE*8-1, SIZE*8, SIZE*8-1);
    board.fill(255);
    board.ellipse(SIZE*(8/2-2), SIZE*(8/2-2), 10, 10);
    board.ellipse(SIZE*(8/2+2), SIZE*(8/2-2), 10, 10);
    board.ellipse(SIZE*(8/2-2), SIZE*(8/2+2), 10, 10);
    board.ellipse(SIZE*(8/2+2), SIZE*(8/2+2), 10, 10);
    board.endDraw();
  }

  void drawStones(PGraphics board, boolean hint) {
    board.beginDraw();
    for (int i=0; i<cells.length; i++) {
      cells[i].render(board);
      if (hint)cells[i].renderHint(board);
    }
    board.endDraw();
  }

  void checkGameOver() {//game overかどうかをしらべる 同時にパスかどうかを調べる 置ける場所にヒントも描画
    if (!checkPass()) {
      passed = false;
      return;
    }
    bgCell.pressed();
    newRow.setString("put", "Pass");
    if (passed) { //パスが2回繰り返されたらgameover、勝敗判定
      game_over = true;//gameover
      step = ANIMATION;
      return;
    }
    info.add("pass", black_turn);
    //println("pass");
    step = ANIMATION;
    passed = true;
  }

  boolean checkPass() {
    boolean pass = true;
    for (int y=0; y<8; y++) {
      for (int x=0; x<8; x++) {
        getCell(x, y).setCanput(false);
        if (getCell(x, y).getState() == NONE) {
          if (checkAround(x, y)) {
            pass = false;
            getCell(x, y).setCanput(true);
          }
        }
      }
    }
    return pass;
  }

  boolean checkAround(int x, int y) {  //(x,y)に置けるかどうか
    for (int j=-1; j<2; j++) {
      for (int i=-1; i<2; i++) {
        if (x+i<0 || 7<x+i || y+j<0 || 7<y+j) continue;
        if (i==0 && j==0) continue;
        if (getCell(x+i, y+j).getState() != ((!black_turn)?BLACK:WHITE)) continue;
        if (check(x+i, y+j, i, j)) return true;
      }
    }
    return false;
  }

  boolean check(int x, int y, int vx, int vy) {  //vx,vy方向に調べて自分の色ならture、相手の色なら再帰、それ以外false
    int turn_color = (black_turn)?BLACK:WHITE;
    if (x+vx<0 || 7<x+vx || y+vy<0 || 7<y+vy) return false;
    if (getCell(x+vx, y+vy).getState() == NONE) return false;
    if (getCell(x+vx, y+vy).getState() == turn_color) return true;
    return check(x+vx, y+vy, vx, vy);
  }

  int countBlack() {
    int black = 0;
    for (int i=0; i<cells.length; i++) {
      if (cells[i].getState() == BLACK) black++;
    }
    return black;
  }

  int countWhite() {
    int white = 0;
    for (int i=0; i<cells.length; i++) {
      if (cells[i].getState() == WHITE) white++;
    }
    return white;
  }

  int countNone() {
    int none = 0;
    for (int i=0; i<cells.length; i++) {
      if (cells[i].getState() == NONE) none++;
    }
    return none;
  }

  void reversi(int x, int y) {  //ひっくり返す 全方向見ていく
    int turn_color = (black_turn)?BLACK:WHITE;  //現在のプレーヤーカラー
    for (int j=-1; j<2; j++) {
      for (int i=-1; i<2; i++) {
        if (x+i<0 || 7<x+i || y+j<0 || 7<y+j) continue;  //探索範囲外を除外
        if (i==0&&j==0) continue;
        if (getCell(x+i, y+j).getState() != 1-turn_color) continue;  //相手色以外除外
        if (!check(x+i, y+j, i, j)) continue;  //その先を探索、ひっくり返せるなら続行
        int s = 1;
        while (getCell (x+i*s, y+j*s).getState() != turn_color) {
          getCell(x+i*s, y+j*s).turnNext();
          s++;
        }
        animated = false;
        progress = 0;
      }
    }
  }

  void pressed(int x, int y) {
    if (!getCell(x, y).isCanput()) return;
    int turn = (black_turn)?0:1;
    //preStatesに現在のstateを格納
    for (int i=0; i<8; i++){
      for (int j=0; j<8; j++){
        preStates[turn][j][i] = getCell(j, i).getState();
      }
    }
    /*println((black_turn)?"BLACK":"WHITE");
    for (int i=0; i<8; i++) {
      for (int j=0; j<8; j++) {
        print(preStates[turn][j][i]+" ");
        if (j==7) println();
      }
    }*/
    //押した場所に石を置き、描画
    getCell(x, y).setState((black_turn)?BLACK:WHITE);
    getCell(x, y).setNextState((black_turn)?BLACK:WHITE);
    getCell(x, y).render(board);
    //ひっくり返してstepをANIMATIONへ
    reversi(x, y);
    step = ANIMATION;
    newRow.setString("put", x+", "+y);
    bgCell.pressed();
  }

  void updateAnimation() {
    progress += (101-progress)*0.1;

    if (progress >= 100) {
      animated = true;
      return;
    }
  }

  void drawAnimation(int _x, int _y) {
    board.beginDraw();
    for (int i=0; i<64; i++) {
      if (cells[i].getNextState() == cells[i].getState()) continue;
      cells[i].turnAnimation(board, (int)progress);
    }

    board.endDraw();
    image(board, _x, _y);
  }

  void updateUndoAnimation() {
    progress += (101-progress)*0.1;

    if (progress >= 100) {
      animated = true;
      return;
    }
  }

  void drawUndoAnimation(int _x, int _y) {
    board.beginDraw();
    for (int i=0; i<64; i++) {
      if (cells[i].getState() == NONE) continue;
      //println(i);
      cells[i].undoAnimation(board, (int)progress);
    }
    board.endDraw();
    image(board, _x, _y);
  }

  void test() {
    for (int i=0; i<2; i++) {
      for (int y=0; y<8; y++) {
        for (int x=0; x<8; x++) {
          print((i==0)?(getCell(x, y).getState()+" "):(getCell(x, y).getNextState()+" "));
        }
        println("");
      }
      println();
    }
  }
}
