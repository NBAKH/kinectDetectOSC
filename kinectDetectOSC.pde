/*
By Tvebak
Project in cooperation with Luftkys
credit to the library creators

KinectPV2 by Thomas Sanchez Lengeling.
KinectPV2 website at http://codigogenerativo.com/

oscP5sendreceive by andreas schlegel
oscP5 website at http://www.sojamo.de/oscP5
*/

import KinectPV2.*;
import oscP5.*;
import netP5.*;

KinectPV2 kinect;

OscP5 oscP5;
NetAddress myRemoteLocation;

int[] coordinates = {436,280,378,224,336,189,305,181,248,168,207,175,154,208,64,250,436,300,378,244,336,209,305,201,252,190,207,195,154,228,64,270,436,320,378,264,336,229,305,221,252,210,207,215,154,248,64,290};

Trigger[] triggers = new Trigger[24];
String[] OSCm = {"/layer12/opacityandvolume","/layer14/opacityandvolume",
"/layer8/opacityandvolume","/layer4/opacityandvolume",
"/layer10/opacityandvolume","/layer16/opacityandvolume",
"/layer6/opacityandvolume","/layer2/opacityandvolume"

};

public int [] rawData;
public int tolerence = 500;

void setup() {
  int cCount = 0;
  for (int i = 0; i < triggers.length; i ++ ) {
    triggers[i] = new Trigger(coordinates[cCount], coordinates[cCount+1], i+1);
    cCount+=2;
  }

  size(512, 424, P3D);
  frameRate(15);
  kinect = new KinectPV2(this);
  kinect.enableDepthImg(true);
  kinect.init();

  oscP5 = new OscP5(this,12000);
  myRemoteLocation = new NetAddress("127.0.0.1",7000);
}

void draw() {
  rawData= kinect.getRawDepthData();
  background(0);
  for (int i = 0; i < triggers.length; i++) {
    triggers[i].arrayNumber = triggers[i].xValue + width * triggers[i].yValue;
    // triggers[i].checkStatus(rawData[triggers[i].arrayNumber]);
    triggers[i].checkStatus(averageVal(i));
    //println(i + " average value:"+averageVal(i));
    triggers[i].drawField();
  }

  image(kinect.getDepthImage(), 0, 0);
  sendOSC();
  stroke(255);
  text(frameRate, 50, height - 50);
}

int averageVal(int trigNum){
  int sum=0;
  int amount=0;
  int average=0;
  for(int i = triggers[trigNum].arrayNumber-triggers[trigNum].size/2; i<triggers[trigNum].arrayNumber+triggers[trigNum].size/2; i++){
    if(rawData[i]==0){
      sum +=7000;
    }else{
      sum+=rawData[i];
    }
    amount++;
  }
  for(int i = triggers[trigNum].yValue-triggers[trigNum].size/2; i<triggers[trigNum].yValue+triggers[trigNum].size/2; i++){
    if(rawData[triggers[trigNum].xValue + width * triggers[trigNum].yValue+i]==0){
      sum +=7000;
    }else{
      sum+=rawData[triggers[trigNum].xValue + width * triggers[trigNum].yValue+i];
    }
    amount++;
  }
  average= sum/amount;
  return average;
}

void mouseDragged(){
  for (int i = 0; i < triggers.length; i ++ ) {
    // println(triggers[i].getX());
    if(mouseX>=triggers[i].xValue-triggers[i].size/2 &&
      mouseX<=triggers[i].xValue+triggers[i].size-triggers[i].size/2 &&
    mouseY>=triggers[i].yValue-triggers[i].size/2 &&
    mouseY<=triggers[i].yValue+triggers[i].size-triggers[i].size/2){
      println(triggers[i].xValue +":"+triggers[i].yValue);
      println(triggers[i].number);
      triggers[i].updatePos(mouseX,mouseY);
      triggers[i].arrayNumber = triggers[i].xValue + width * triggers[i].yValue;
    }
  }
}

void keyPressed(){
  if (key == 'c'){
    for (int i = 0; i < triggers.length; i ++ ) {
      //triggers[i].setBase(rawData[triggers[i].arrayNumber]);
      triggers[i].setBase(averageVal(i));
      println("zone: " + i +" array number: " + triggers[i].arrayNumber + ", threshold: "+triggers[i].threshold);
    }
      // println(rawData);
  }
  if (key == 'o'){
    tolerence+=50; println("tolerence: "+ tolerence);
  }
  if (key == 'l'){
    tolerence-=50; println("tolerence: "+ tolerence);
  }
  if (key == 'e'){
    for(int i = 0; i<triggers.length; i ++ ){
      print(triggers[i].xValue +","+triggers[i].yValue + ",");
    }
  }
}

void sendOSC(){
  boolean[] status = new boolean[24];
  for (int i = 0; i < triggers.length; i ++ ) {
    status[i]=triggers[i].trig;
  }

  for (int i = 0; i < OSCm.length; i ++ ) {
    OscMessage myMessage = new OscMessage(OSCm[i]);
    if(triggers[i].trig){
      myMessage.add(1.0);
    }else if(triggers[i+8].trig){
      myMessage.add(1.0);
    }else if(triggers[i+16].trig){
      myMessage.add(1.0);
    }else{
      myMessage.add(0.0);
    }
    oscP5.send(myMessage, myRemoteLocation);
  }
}
