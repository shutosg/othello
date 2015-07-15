class Ai {
  int putX, putY, myColor, timer;
  boolean active;
  Ai(int _myColor) {
    myColor = _myColor;
    putX = 0;
    putY = 0;
    active = false;
  }
  void select() {
    println(turnNum + ((turnNum%10 == 1)?"st":((turnNum%10 == 2)?"nd":((turnNum%10 == 3)?"rd":"th"))) + " turn");
    if ((myColor==WHITE)?black_turn:!black_turn) return;
    int count=0;
    boolean[] focus = new boolean[64];
    float[] point = new float[64];
    for (int i=0; i<64; i++) {
      if (!cm.cells[i].canput) continue;
      point[i] = 0;  //評価値の初期化
      focus[i] = false;
      int x_tmp = cm.cells[i].getX();
      int y_tmp = cm.cells[i].getY();
      count++;
      if (i==0||i==7||i==56||i==63) point[i] += 10; //角
      if (i==1||i==6||i==8||i==9||i==14||i==15||i==48||i==49||i==54||i==55||i==62) point[i] -= 4;  //X置き
      if (2 <= x_tmp && x_tmp <=5 && 2 <= y_tmp && y_tmp <= 5) point[i] += (turnNum<15)?3.5:2;  //ボックス
      if ((y_tmp==1 || y_tmp==6) && 2<=x_tmp && x_tmp <= 5) point[i] -= 2;  //中辺
      if ((x_tmp==1 || x_tmp==6) && 2<=y_tmp && y_tmp <= 5) point[i] -= 2;  //中辺
      if (2<=x_tmp && x_tmp<6) point[i]+=3;  //外辺
    }

    Cell[] cellCanPut = new Cell[count];  //置けるマスを格納
    count=0;
    for (int i=0; i<64; i++) {
      if (!cm.cells[i].isCanput()) continue;
      cellCanPut[count] = cm.cells[i];
      count++;
    }


    for (int i=0; i<cellCanPut.length; i++) {  //開放度理論
      count = 0;
      for (int j=0; j<64; j++) {
        focus[j] = false;
      }
      focus(cellCanPut[i].getX(), cellCanPut[i].getY(), focus);
      for (int y=0; y<8; y++) {
        for (int x=0; x<8; x++) {
          if (cm.getCell(x, y).getState() != NONE) continue;
          if (x == cellCanPut[i].getX() && y == cellCanPut[i].getY()) continue;
          count += checkAround(x, y, focus);
        }
      }
      point[cellCanPut[i].getId()] -= count/1.5;
    }


    for (int i=0; i<2; i++) {
      for (int y=0; y<8; y+=7) {
        Cell[] tmp = new Cell[8];
        
        for (int x=1; x<7; x++) {
          if (!cm.getCell((i==0)?x:y, (i==0)?y:x).canput) continue;

          for (int a=0; a<8; a++) {  //1手先を読むための
            Cell c = (i==0)?cm.getCell(a, y):cm.getCell(y, a);
            tmp[a] = c.cloneSelf();
          }
          
          //外辺を2マス間隔で取る
          if ((x-3 >= 0 && cm.getCell((i==0)?x-3:y, (i==0)?y:x-3).getState() == myColor)||
            (x+3 < 8 && cm.getCell((i==0)?x+3:y, (i==0)?y:x+3).getState() == myColor)) 
            point[cm.getCell(((i==0)?x:y), ((i==0)?y:x)).getId()]+=3;
          //2マス間隔で空いている外辺に置かない
          if ((x-2 >= 0 && cm.getCell((i==0)?x-2:y, (i==0)?y:x-2).getState() == myColor)&&
            (x+1 < 8 && cm.getCell((i==0)?x+1:y, (i==0)?y:x+1).getState() == myColor)) 
            point[cm.getCell(((i==0)?x:y), ((i==0)?y:x)).getId()]-=6;
          if ((x-1 >= 0 && cm.getCell((i==0)?x-1:y, (i==0)?y:x-1).getState() == myColor)&&
            (x+2 < 8 && cm.getCell((i==0)?x+2:y, (i==0)?y:x+2).getState() == myColor)) 
            point[cm.getCell(((i==0)?x:y), ((i==0)?y:x)).getId()]-=6;
          
          
          println(((y==7)?((i==0)?"bottom":"right"):((i==0)?"top":"left"))+((i==0)?" x:":" y:")+x);
          for (int test=0; test<8; test++) {
            print(tmp[test].getState() + " ");
          }
          println();
          tmp[x].setState(myColor);
          rowReversi(tmp, myColor);
          for (int test=0; test<8; test++) {
            print(tmp[test].getState() + " ");
          }
          println();
          //println(((i==0)?x:y) + ", " + ((i==0)?y:x));
          
          //自分が置いた後に相手が置けてしまうか判断 置けてしまうのなら低評価、置けないのなら高評価
          for (Cell c:tmp) {
            if (c.getState() != NONE) continue;
            for (int vx=-1; vx<2; vx+=2) {
              if (((i==0)?c.x:c.y)+vx<0 || 7<((i==0)?c.x:c.y)+vx) continue;  //探索範囲外を除外
              if (tmp[((i==0)?c.x:c.y)+vx].getState() != myColor) continue;  //自分色以外除外
              if (!rowCheck(tmp, ((i==0)?c.x:c.y)+vx, vx, 1-myColor)) {  
              //その先を探索、(相手が)ひっくり返せるなら続行
                point[cm.getCell(((i==0)?x:y), ((i==0)?y:x)).getId()]+=4;
                continue;
              }
              point[cm.getCell(((i==0)?x:y), ((i==0)?y:x)).getId()]-=5;
              if (((i==0)?c.x:c.y)==0 || ((i==0)?c.x:c.y)==7) 
                point[cm.getCell(((i==0)?x:y), ((i==0)?y:x)).getId()]-=10;
              println("find risky square(s) " + ((i==0)?x:y) + ", " + ((i==0)?y:x));
            }
          }
        }
      }
    }
    
    //角をとっている場合はその周りの評価値を上げる
    int[][] corner = {
      {
        0, 1, 8, 9
      }
      , {
        7, 6, 14, 15
      }
      , {
        56, 48, 49, 57
      }
      , {
        63, 54, 55, 62
      }
    };
    for (int[] i : corner) {
      if (cm.cells[i[0]].getState() != myColor) continue;
      for (int j=1; j<4; j++) {
        if (cm.cells[i[j]].canput) point[cm.cells[i[j]].getId()]+=9;
      }
    }
    
    //評価が最大のマスを選択
    float maxPoint = -5000;
    int maxIndex = 0;
    for (int i=0; i<cellCanPut.length; i++) {
      if (maxPoint > point[cellCanPut[i].getId()]) continue;
      if (maxPoint == point[cellCanPut[i].getId()] && random(100)>50) continue;
      maxPoint = point[cellCanPut[i].getId()];
      maxIndex = cellCanPut[i].getId();
    }


    putX = cm.cells[maxIndex].x;
    putY = cm.cells[maxIndex].y;
  }

  void focus(int x, int y, boolean[] focus) {  //ひっくり返せる石にマーク(focus)する 全方向見ていく
    int turn_color = (black_turn)?BLACK:WHITE;  //現在のプレーヤーカラー
    for (int j=-1; j<2; j++) {
      for (int i=-1; i<2; i++) {
        if (x+i<0 || 7<x+i || y+j<0 || 7<y+j) continue;  //探索範囲外を除外
        if (i==0&&j==0) continue;
        if (cm.getCell(x+i, y+j).getState() != 1-turn_color) continue;  //相手色以外除外
        if (!cm.check(x+i, y+j, i, j)) continue;  //その先を探索、ひっくり返せるならfocus
        int s = 1;
        while (cm.getCell (x+i*s, y+j*s).getState() != turn_color) {
          focus[cm.getCell(x+i*s, y+j*s).getId()] = true;
          s++;
        }
      }
    }
  }

  void rowReversi(Cell[] tmp, int turnColor) {  //列でひっくり返す
    for (int x=0; x<tmp.length; x++) {
      if (tmp[x].getState() != turnColor) continue;
      for (int i=-1; i<2; i+=2) {
        if (x+i<0 || 7<x+i) continue;  //探索範囲外を除外
        if (tmp[x+i].getState() != 1-turnColor) continue;  //相手色以外除外
        if (!rowCheck(tmp, x+i, i, turnColor)) continue;  //その先を探索、ひっくり返せるなら続行
        int s = 1;
        while (tmp[x+i*s].getState() != turnColor) {
          tmp[x+i*s].turn();
          s++;
        }
      }
    }
  }

  int checkAround(int x, int y, boolean[] focus) {
    for (int t=-1; t<2; t++) {
      for (int s=-1; s<2; s++) {
        if (x+s<0 || 7<x+s || y+t<0 || 7<y+t) continue;
        if (!focus[cm.getCell(x+s, y+t).getId()]) continue;
        return 1;
      }
    }
    return 0;
  }

  boolean rowCheck(Cell[] tmp, int x, int vx, int myColor) {  
  //vx方向に調べて自分の色ならture、敵の色なら再帰、それ以外false
    int turn_color = myColor;
    if (x+vx<0 || 7<x+vx) return false;
    if (tmp[x+vx].getState() == NONE) return false;
    if (tmp[x+vx].getState() == turn_color) return true;
    return rowCheck(tmp, x+vx, vx, turn_color);
  }

  void push() {
    if ((myColor==WHITE)?black_turn:!black_turn) return;
    cm.pressed(putX, putY);
  }

  void reset(int _myColor) {
    myColor = _myColor;
    putX = 0;
    putY = 0;
    active = false;
  }
}
