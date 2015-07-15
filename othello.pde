final int SIZE = 50;
final int STONE_SIZE = (int)(SIZE*0.7);
final int BLACK = 0;
final int WHITE = 1;
final int NONE = 2;
final int XOFFSET = 0;
final int YOFFSET = 100;
final int MENU = 0;
final int DRAW = 1;
final int WAIT_P = 2;
final int ANIMATION = 3;
final int NEXT_TURN = 4;
final int UNDO_ANIMATION = 5;
final int GAME_OVER = -1;
int step;
int turnNum, preTurnNum;

CellMaster cm;
Info info;
boolean black_turn, animated, player_turn, recorded, game_over, undoing;
PGraphics board;
float[] sin_tmp, cos_tmp;
BgCell bgCell;
Button[] menus = new Button[3];
Button undoButton;
Ai ai = new Ai(WHITE);
Table output;
TableRow newRow;

void setup() {
  sin_tmp = new float[360];
  cos_tmp = new float[360];
  for (float i=0; i<360; i++) {
    sin_tmp[(int)i] = (i!=180)?sin(i*PI/180):0;
    cos_tmp[(int)i] = (i!=90&&i!=270)?cos(i*PI/180):0;
  }
  player_turn = true;
  game_over = false;
  black_turn = true;
  undoing = false;
  step = MENU;
  size(8*SIZE, 8*SIZE+YOFFSET);
  undoButton = new btnUndo(width/2-30, height-SIZE*8-40, 60, 30);
  bgCell = new BgCell(BLACK);
  menus[0] = new btnComputer(-1, height-STONE_SIZE*3.3, width+1, STONE_SIZE);
  menus[1] = new btnComputerAfter(-1, height-STONE_SIZE*2.2, width+1, STONE_SIZE);
  menus[2] = new btnFriend(-1, height-STONE_SIZE*1.1, width+1, STONE_SIZE);
  board = createGraphics(8*SIZE, 8*SIZE, JAVA2D);
  cm = new CellMaster(board);
  info = new Info();
  animated = true;
  makeTable();
}


void draw() {
  if (turnNum != preTurnNum) {
    preTurnNum = turnNum;
    newRow = output.addRow();
    newRow.setInt("turn_num", turnNum);
    newRow.setInt("turn_color", ((black_turn)?BLACK:WHITE));
  }

  switch (step) {
  case MENU:
    textSize(STONE_SIZE*0.7);
    background(0);
    fill(255);
    textAlign(CENTER);
    text("select mode", width/2, height/2);
    menus[0].draw();
    menus[1].draw();
    menus[2].draw();
    break;

  case DRAW:
    bgCell.render();
    cm.update();
    cm.draw(XOFFSET, YOFFSET, (!game_over)?true:false);
    info.update();
    info.draw();
    if (!player_turn) {
      if (frameCount - ai.timer < random(30, 120)) break;
      ai.select();
      ai.push();
      break;
    }
    undoButton.draw();
    break;

  case ANIMATION:
    if (animated && bgCell.animated) {
      newRow.setInt("black", cm.countBlack());
      newRow.setInt("white", cm.countWhite());
      step = NEXT_TURN;
      black_turn = !black_turn;
      if (!game_over) break;
      step = GAME_OVER;
      break;
    }
    bgCell.render();
    bgCell.updateAnimation();
    bgCell.drawAnimation();
    info.update();
    info.draw();
    cm.draw(XOFFSET, YOFFSET, false);
    cm.updateAnimation();
    cm.drawAnimation(XOFFSET, YOFFSET);
    break;

  case UNDO_ANIMATION:
    if (animated && bgCell.animated) {
      println(cm.countBlack());
      println("before: " + newRow.getInt("black"));
      TableRow tmp = output.getRow(output.getRowCount()-2);
      tmp.setInt("black", cm.countBlack());
      tmp.setInt("white", cm.countWhite());
      println("after: " + newRow.getInt("black"));
      step = DRAW;
      break;
    }
    bgCell.render();
    bgCell.updateAnimation();
    bgCell.drawAnimation();
    info.update();
    info.draw();
    cm.draw(XOFFSET, YOFFSET);
    cm.updateUndoAnimation();
    cm.drawUndoAnimation(XOFFSET, YOFFSET);
    break;

  case NEXT_TURN:
    step = DRAW;
    turnNum++;
    if (ai.active) {
      player_turn = !player_turn;
      ai.timer = frameCount;
    }
    break;

  case GAME_OVER:
    if (!recorded) saveTable(output, "data/"+getDate()+".csv");
    recorded = true;
    bgCell.render();
    cm.draw(XOFFSET, YOFFSET, false);
    info.draw();
    gameEnd();
    break;
  }
}


void mousePressed() {
  switch (step) {
  case MENU:
    for (int i=0; i<menus.length; i++) {
      menus[i].pushed();
    }
    break;

  case DRAW:
    if (!player_turn) break;
    if (onBoard()) {
      int x = (mouseX-XOFFSET)/SIZE;
      int y = (mouseY-YOFFSET)/SIZE;
      cm.pressed(x, y);
    }
    undoButton.pushed();
    break;

  case GAME_OVER:
    resetGame();
  }
}


boolean onBoard() {
  if (!(XOFFSET < mouseX && mouseX < XOFFSET+SIZE*8)) return false;
  if (!(YOFFSET < mouseY && mouseY < YOFFSET+SIZE*8)) return false;
  return true;
}


void resetGame() {
  cm.initialize();
  black_turn = true;
  player_turn = true;
  game_over = false;
  step = MENU;
  bgCell.reset();
  info.reset();
  ai.reset(WHITE);
  recorded = false;
  makeTable();
}


void gameEnd() { //カウントして勝敗表示
  int black = cm.countBlack();
  int white = cm.countWhite();
  textAlign(CENTER);
  //fill((!black_turn)?255:0);
  fill(255, 0, 0);
  if (black == white) {
    text("The game was draw!", width/2, STONE_SIZE);
    text("Click to restart.", width/2, STONE_SIZE*2);
    return;
  }
  text(((black>white)?"BLACK":"WHITE") + " won!", width/2, STONE_SIZE);
  text("Click to restart.", width/2, STONE_SIZE*2);
}


String getDate(){
  int y, m, d, h, min, s;
  y = year();
  m = month();
  d = day();
  h = hour();
  min = minute();
  s = second();
  return "" + y + ((m<10)?"0"+m:m) + ((d<10)?"0"+d:d) + 
  ((h<10)?"0"+h:h) + ((min<10)?"0"+min:min) + ((s<10)?"0"+s:s);
}


void makeTable(){
  output = new Table();
  output.addColumn("turn_num");
  output.addColumn("put");
  output.addColumn("turn_color");
  output.addColumn("black");
  output.addColumn("white");
  turnNum = 1;
  preTurnNum = 0;
}
