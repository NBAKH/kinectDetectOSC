class Trigger{
  int xValue;
  int yValue;
  int size = 30;
  int number;
  int calibrateaValue = 0;
  int threshold;
  int arrayNumber;
  int avrNum;
  boolean trig;
  color c = color(255,0,0);

  Trigger(int x, int y, int a){
    xValue = x;
    yValue = y;
    number = a;
  }

  void drawField(){
    ellipseMode(CENTER);
    stroke(c);
    noFill();
    ellipse(xValue,yValue,size,size);
    point(xValue,yValue);
    fill(0,0,255);
    textSize(25);
    text(number,xValue,yValue);
  }

  void updatePos(int x, int y){
    xValue = x;
    yValue = y;
    arrayNumber = x*y;
  }

  void checkStatus(int distance){
    if(distance==0){
      distance=7000;
    }
    if(distance<threshold-tolerence){
      trig = true;
      c = color(0,255,0);
    }else{
      trig = false;
      c = color(255,0,0);
    }
  }

  void setBase(int avg){
    if(avg==0){
      avg=7000;
    }
    threshold = avg;
  }
}
