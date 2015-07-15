class Msg{
  String msg;
  int trans;
  int x;
  int y;
  int align;
  color msgColor;
  int size;
  
  Msg (String _msg, int _x, int _y, int _align){
    msg = _msg;
    x = _x;
    y = _y;
    align = _align;
    size = 20;
    msgColor = color(255);
  }
  
  void update(){
  }
  
  void printMsg(){
    textSize(size);
    fill(msgColor);
    textAlign(align);
    text(msg, x, y);
  }
  
}

class TurnMsg extends Msg{
  TurnMsg(int _x, int _y, int _align){
    super("", _x, _y, _align);
  }
  
  void update(){
    if (black_turn) {
      msg = "It's BLACK turn.";
      msgColor = color(255);
      return;
    }
    msg = "It's WHITE turn.";
    msgColor = color(0);
  }
  
}

class PassMsg extends Msg{
  String turn;
  PassMsg(int _x, int _y, int _align){
    super("", _x, _y, _align);
    trans = 0;
  }
  void reset(String turn){
    trans = 257;
    msg = turn + " turn was passed.";
  }
  void update(){
    trans--;
    if(trans == 256) return;
    trans = (trans <= 0)?1:trans;
    int c = (!black_turn)?0:255;
    msgColor = color(c, c, c, trans);
  }
  
}
