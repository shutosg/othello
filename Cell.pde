class Cell {
  protected int id, x, y, state, nextState;
  protected boolean canput;
  Cell(int _x, int _y, int _state) {
    x = _x;
    y = _y;
    id = y*8 + x;
    state = _state;
    nextState = state;
    canput = false;
  }

  void setState(int _state) {this.state = _state;}
  void setNextState(int _state) {this.nextState = _state;}
  void setCanput(boolean _canput) {this.canput = _canput;}


  int getId() {return this.id;}
  int getX() {return this.x;}
  int getY() {return this.y;}
  int getState() {return this.state;}
  int getNextState() {return this.nextState;}
  boolean isCanput() {return this.canput;}


  void render(PGraphics board) {
    if (state==NONE) return;
    board.noStroke();
    board.stroke((state!=BLACK)?0:255);
    board.fill((state==BLACK)?0:255);
    board.ellipse((x*2+1)*SIZE/2, (y*2+1)*SIZE/2, STONE_SIZE, STONE_SIZE);
  }

  void renderHint(PGraphics board) {
    if (!canput) return;
    int trans = 129+(int)(64*sin_tmp[frameCount*2%360]);
    board.stroke((!black_turn)?color(0, 0, 0, trans):color(255, 255, 255, trans));
    board.fill((black_turn)?color(0, 0, 0, trans):color(255, 255, 255, trans));
    board.ellipse((x*2+1)*SIZE/2, (y*2+1)*SIZE/2, STONE_SIZE/2, STONE_SIZE/2);
  }

  void turn() {
    if (state == NONE) return;
    state = 1-state;
  }

  void turnNext() {
    if (state == NONE) return;
    nextState = 1-state;
  }

  void turnAnimation(PGraphics board, int progress) {
    if (progress >= 100) {
      turn();
      render(board);
    }
    float stoneSize = (progress>100)?STONE_SIZE:STONE_SIZE*progress/100.0;
    board.stroke((nextState!=BLACK)?0:255);
    board.strokeWeight(1);
    board.fill((nextState==BLACK)?0:255);
    board.ellipse((x*2+1)*SIZE/2, (y*2+1)*SIZE/2, stoneSize, stoneSize);
  }

  void undoAnimation(PGraphics board, int progress) {
    //undo後の石描画
    if (getNextState() != NONE) {
      board.stroke((nextState==BLACK)?255:0);
      board.strokeWeight(1);
      board.fill((nextState==BLACK)?0:255);
      board.ellipse((x*2+1)*SIZE/2, (y*2+1)*SIZE/2, STONE_SIZE, STONE_SIZE);
    }
    if (progress>=100) {
      setState(nextState);
      return;
    }
    //undo前の石描画
    if (getNextState() == getState()) return;
    float stoneSize = STONE_SIZE*(100-progress)/100.0;
    board.stroke((state!=BLACK)?0:255);
    board.strokeWeight(1);
    board.fill((state==BLACK)?0:255);
    board.ellipse((x*2+1)*SIZE/2, (y*2+1)*SIZE/2, stoneSize, stoneSize);
  }


  Cell cloneSelf() {
    Cell c = new Cell(x, y, state);
    return c;
  }

  void reset() {
    state = NONE;
    canput = false;
  }
}

///////////////////////////////////////////////////////////////////


class BgCell extends Cell {
  //int x, y, state, nextState;
  float progress;
  boolean animated;
  final int MAX_SIZE = (int)(1.1*sqrt(sq(width)+sq(height)));
  BgCell(int _state) {
    super(width/2, height/2, _state);
    progress = 100;
    animated = true;
  }

  void render() {
    if (state==NONE) return;
    noStroke();
    fill((state==BLACK)?0:255);
    ellipse(x, y, MAX_SIZE, MAX_SIZE);
  }

  void turnAnimation(int progress) {
    if (progress >= 100) {
      turn();
      render();
    }
    float stoneSize = (progress>100)?MAX_SIZE:MAX_SIZE*progress/100.0;
    noStroke();
    //stroke((state!=BLACK)?0:255);
    fill((nextState==BLACK)?0:255);
    ellipse(x, y, stoneSize, stoneSize);
  }

  void updateAnimation() {
    progress += (101-progress)*0.2;

    if (progress >= 100) {
      animated = true;
      return;
    }
  }

  void drawAnimation() {
    if (nextState == state) return;
    turnAnimation((int)progress);
  }

  void pressed() {
    turnNext();
    animated = false;
    progress = 0;
  }

  void reset() {
    progress = 100;
    animated = true;
    state = BLACK;
    nextState = BLACK;
  }
}
