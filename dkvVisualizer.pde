import oscP5.*;
import netP5.*;

OscP5 oscP5;
ArrayList<Note> notes = new ArrayList<Note>();

float vertScale;
int bottomNoteNum = 21;
float noteSizeScale = 0.02;
float timeSpaceScale = 0.5;
int maxNumNotes = 40;

void setup() {
  //size(800, 800);
  fullScreen();
  background(0);
  
  oscP5 = new OscP5(this, 48068);
  vertScale = height/88.0;
  
}

void draw() {
  background(0);
  
  float currentTime = millis();
  
  if(notes.size() > maxNumNotes){
     notes.remove(0);
  }
  
  for (int i = notes.size() - 1; i >= 0; i--) {
    Note note = notes.get(i);
    if(note.type==0){
      stroke(255,0,0);
      fill(255,0,0,note.vel*255/128);
    }else{
      stroke(0,255,0);
      fill(0,255,0, note.vel*255/128);
    }
    float noteSize = note.vel * note.vel * noteSizeScale;
    float offTime = ((note.offTime < 0) ? currentTime : note.offTime);
    rect((currentTime - note.onTime)*timeSpaceScale, height-(note.num-bottomNoteNum)*vertScale, (note.onTime - offTime)*timeSpaceScale, noteSize);
  }
}

void oscEvent(OscMessage theOscMessage) {
  //pianoOn
  if (theOscMessage.addrPattern().equals("/pianoOn")) {
    int num = theOscMessage.get(0).intValue(); 
    int vel = theOscMessage.get(1).intValue();
    int type = 0;
    print("pianoOn: ");println(num, vel);
    notes.add(new Note(num, vel, type));
  }
  //algoOn
  if (theOscMessage.addrPattern().equals("/algoOn")) {
    int num = theOscMessage.get(0).intValue(); 
    int vel = theOscMessage.get(1).intValue();
    int type = 1;
    print("algoOn: ");println(num, vel);
    notes.add(new Note(num, vel, type));
  }
  //pianoOff
  if (theOscMessage.addrPattern().equals("/pianoOff")) {
    int num = theOscMessage.get(0).intValue();
    int vel = theOscMessage.get(1).intValue();
    int type = 0;
    print("pianoOff: ");println(num, vel);
    for (int i = notes.size() - 1; i >= 0; i--) {
      Note note = notes.get(i);
      if (note.num == num && note.type == type && note.offTime < 0){
        note.offTime = millis();
      }
    }
  }
  //algoOff
  if (theOscMessage.addrPattern().equals("/algoOff")) {
    int num = theOscMessage.get(0).intValue();
    int vel = theOscMessage.get(1).intValue();
    int type = 1;
    print("algoOff: ");println(num, vel);
    for (int i = notes.size() - 1; i >= 0; i--) {
      Note note = notes.get(i);
      if (note.num == num && note.type == type && note.offTime < 0){
        note.offTime = millis();
      }
    }
  }
}

class Note {
  int num, vel;
  int type; //0 is piano, 1 is algo
  float onTime, offTime, duration; //in seconds
  int x, y;
  
  Note(int theNum, int theVel, int theType) {
    num = theNum;
    vel = theVel;
    onTime = millis();
    offTime = -1; //this indicates that we don't yet know the offTime
    type = theType;
  }
}