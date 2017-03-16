import oscP5.*;
import netP5.*;

OscP5 oscP5;
NoteInProgress[] pianoNoteInProg = new NoteInProgress[140];
NoteInProgress[] algoNoteInProg = new NoteInProgress[140];
ArrayList<Note> notes = new ArrayList<Note>();
ArrayList<ScreenNote> screenNotes = new ArrayList<ScreenNote>();

float vertScale;
int bottomNoteNum = 21;
float noteSizeScale = 2;
float timeSpaceScale = 0.3;
int maxNumNotes = 1000;

void setup() {
  size(800, 800);
  
  oscP5 = new OscP5(this, 48068);
  vertScale = height/88.0;
  
  for (int i = 0; i < pianoNoteInProg.length; i++) {
    pianoNoteInProg[i] = new NoteInProgress(0, 0.0);
    algoNoteInProg[i] = new NoteInProgress(0, 0.0);
  }
}

void draw() {
  background(0);
  noFill();
  
  float currentTime = millis();
  
  if(notes.size() > maxNumNotes){
     notes.remove(0);
  }
  
  stroke(255,0,0);
  for (int i = 0; i < pianoNoteInProg.length; i++) {
    float noteSize = pianoNoteInProg[i].vel * noteSizeScale;
    rect((currentTime - pianoNoteInProg[i].onTime)*timeSpaceScale, (i-bottomNoteNum)*vertScale, noteSize, noteSize);
  }
  stroke(0,255,0);
  for (int i = 0; i < algoNoteInProg.length; i++) {
    float noteSize = algoNoteInProg[i].vel * noteSizeScale;
    rect((currentTime - algoNoteInProg[i].onTime)*timeSpaceScale, i*vertScale, noteSize, noteSize);
  }
}

void oscEvent(OscMessage theOscMessage) {
  //pianoOn
  if (theOscMessage.addrPattern().equals("/pianoOn")) {
    int num = theOscMessage.get(0).intValue(); 
    int vel = theOscMessage.get(1).intValue();
    println(num, vel);
    pianoNoteInProg[num].vel=vel;
    pianoNoteInProg[num].onTime=millis();
  }
  //algoOn
  if (theOscMessage.addrPattern().equals("/algoOn")) {
    int num = theOscMessage.get(0).intValue(); 
    int vel = theOscMessage.get(1).intValue();
    println(num, vel);
    algoNoteInProg[num].vel=vel;
    algoNoteInProg[num].onTime=millis();
  }
}


class NoteInProgress {
  int vel;
  float onTime; //in seconds
  
  NoteInProgress(int theVel, float theOnTime) {
    vel = theVel;
    onTime = theOnTime;
  }
}

class Note {
  int num, vel;
  int type; //0 is piano, 1 is algo
  float onTime, offTime, duration; //in seconds
  int x, y;
  
  Note(int theNum, int theVel, float theOnTime, float theOffTime, int theType) {
    num = theNum;
    vel = theVel;
    onTime = millis();
    offTime = -1; //this indicates that we don't yet know the offTime
    type = theType;
  }
}

class ScreenNote implements Comparable {
  int num, veloc, x, y, type;
  float onTime, offTime; //in seconds
  
  ScreenNote(int theNum, int theVeloc) {
    num = theNum;
    veloc = theVeloc;
    onTime = millis();
  }
  
  //if we want to sort based on the X value of MyObj-es:
  int compareTo(Object o)
  {
    Note other=(Note)o;
    if(other.num<num)  
      return -1;
    if(other.num==num)
      return 0;
    else
      return 1;
  }
}