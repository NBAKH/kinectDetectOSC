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

Trigger[] triggers = new Trigger[8];
String[] OSCm = {"/layer12/opacityandvolume","/layer14/opacityandvolume",
"/layer8/opacityandvolume","/layer4/opacityandvolume",
"/layer10/opacityandvolume","/layer16/opacityandvolume",
"/layer6/opacityandvolume","/layer2/opacityandvolume"};

int[] coordinates = {436,280,378,224,336,189,305,181,252,170,207,175,154,208,64,250
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
    println(i + " average value:"+averageVal(i));
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
  for(int i = triggers[trigNum].arrayNumber-10; i<triggers[trigNum].arrayNumber+10; i++){
    if(rawData[i]==0){
      sum +=7000;
    }else{
      sum+=rawData[i];
    }
    amount++;
  }
  for(int i = triggers[trigNum].yValue-10; i<triggers[trigNum].yValue+10; i++){
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
}

void sendOSC(){
  for (int i = 0; i < triggers.length; i ++ ) {
    OscMessage myMessage = new OscMessage(OSCm[i]);
    if(triggers[i].trig){
      myMessage.add(1.0);
    }else{
      myMessage.add(0.0);
    }
    oscP5.send(myMessage, myRemoteLocation);
  }
}
