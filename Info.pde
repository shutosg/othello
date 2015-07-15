class Info{
  TurnMsg turnMsg;
  PassMsg passMsg;
  color msgTrans;
  Info(){
    turnMsg = new TurnMsg(width/2, (int)(STONE_SIZE*1.5), CENTER);
    passMsg = new PassMsg(width/2, (int)(STONE_SIZE*2), CENTER);
  }
  void add(String _msg, boolean black){
    if (_msg.equals("pass")) {
      passMsg.reset((black)?"BLACK":"WHITE");
    }
  }
  
  void update(){
    turnMsg.update();
    passMsg.update();
  }
  
  void draw(){
    textSize(STONE_SIZE*0.7);
    fill(0);
    stroke(255);
    ellipse(SIZE/2, SIZE/2, STONE_SIZE, STONE_SIZE);
    fill(255);
    text(cm.countBlack(), SIZE/2, SIZE/2*1.3);
    fill(255);
    stroke(0);
    ellipse(SIZE*8 - SIZE/2, SIZE/2, STONE_SIZE, STONE_SIZE);
    fill(0);
    text(cm.countWhite(), SIZE*8 - SIZE/2, SIZE/2*1.3);
    if (game_over) return;
    turnMsg.printMsg();
    textSize(20);
    text(turn()+" turn", width/2, STONE_SIZE*0.7);
    passMsg.printMsg();
  }
  
  String turn(){
    String t;
    switch (turnNum%10) {
      case 1:
      t = turnNum+"st";
      break;
      case 2:
      t = turnNum+"nd";
      break;
      case 3:
      t = turnNum+"rd";
      break;
      default:
      t = turnNum+"th";
    }
    return t;
  }
  
  void reset(){
    passMsg.trans=0;
  }
}
