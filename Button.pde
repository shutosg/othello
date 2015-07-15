class Button{
  float x, y, w, h;
  String str;
  color out, on, line;
  Button(float _x, float _y, int _w, int _h, String _str){
    x = _x;
    y = _y;
    w = _w;
    h = _h;
    out = color(0);
    on = color(50);
    line = color(255);
    str = _str;
  }
  
  void setOut(color c){
    out = c;
  }
  
  void setOn(color c){
    on = c;
  }
  
  void pushed(){
    if (!onMouse()) return;
    runFunc();
  }
  
  void runFunc(){};
  
  void draw(){
    pushStyle();
    fill((onMouse())?on:out);
    strokeWeight(1);
    stroke(line);
    rect(x, y, w, h);
    fill(line);
    textAlign(CENTER, CENTER);
    text(str, x+w/2, y+h/2);
    popStyle();
  }
  
  boolean onMouse(){
    if (mouseX<x || x+w<mouseX) return false;
    if (mouseY<y || y+h<mouseY) return false;
    return true;
  }
  
}

class btnComputer extends Button{
  btnComputer(float _x, float _y, int _w, int _h){
    super(_x, _y, _w, _h, "V.S. Computer(You are 1st turn)");
  }
  void runFunc(){
    ai.active = true;
    step = DRAW;
  }
  
}

class btnComputerAfter extends Button{
  btnComputerAfter(float _x, float _y, int _w, int _h){
    super(_x, _y, _w, _h, "V.S. Computer(You are 2nd turn)");
  }
  void runFunc(){
    ai.reset(BLACK);
    ai.active = true;
    ai.timer = frameCount;
    player_turn = false;
    step = DRAW;
  }
  
}

class btnFriend extends Button{
  btnFriend(float _x, float _y, int _w, int _h){
    super(_x, _y, _w, _h, "V.S. friend");
  }
  void runFunc(){
    step = DRAW;
  }
}

class btnUndo extends Button{
  btnUndo(float _x, float _y, int _w, int _h){
    super(_x, _y, _w, _h, "Undo");
  }

  void draw(){
    if (!canUndo() || turnNum<3) return;
    pushStyle();
    fill((onMouse())?((black_turn)?50:205):((black_turn)?0:255));
    strokeWeight(1);
    stroke((black_turn)?255:0);
    rect(x, y, w, h);
    fill((black_turn)?255:0);
    textAlign(CENTER, CENTER);
    text(str, x+w/2, y+h/2);
    popStyle();
  }

  void runFunc(){
    if(turnNum<3) return;
    if(!canUndo()) return;
    cm.progress = 0;
    step = UNDO_ANIMATION;
    animated = false;
    turnNum = turnNum-((cm.passed)?4:2);
    for (int i=0; i<8; i++){
      for (int j=0; j<8; j++){
        cm.getCell(j, i).setNextState(cm.preStates[(black_turn)?BLACK:WHITE][j][i]);
      }
    }
    newRow.setString("put", "Undo");
  }

  boolean canUndo() {
    for (int i=0; i<8; i++) {
      for (int j=0; j<8; j++) {
        if (cm.getCell(j, i).getState() != cm.preStates[(black_turn)?BLACK:WHITE][j][i]) return true;      
      }
    }
    return false;
  }
}
