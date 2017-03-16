import oscP5.*;
import netP5.*;

OscP5 oscP5;
ArrayList<Note> notes = new ArrayList<Note>();

float vertScale;
int bottomNoteNum = 21;
float noteSizeScale = 0.02;
float speed = 3; //how fast notes move across screen
float speedPerspective = 1; //how much faster louder notes move than slower ones
int maxNumNotes = 40;

void setup() {
  //size(800, 800);
  fullScreen();
  background(0);
  
  oscP5 = new OscP5(this, 48068);
  vertScale = height/88.0;
  
  //rectMode(CORNERS); //so that the coords of the rects we draw give the coords of the corners, rather than corner and width/height
  //ellipseMode(CORNERS); //same for ellipse
  
}

void draw() {
  background(0);
  
  int currentTime = millis();
  
  if(notes.size() > maxNumNotes){
     notes.remove(0);
  }
  
  for (int i = notes.size() - 1; i >= 0; i--) {
    Note note = notes.get(i);
    note.update();
  }
}

void oscEvent(OscMessage theOscMessage) {
  //noteOn
  if (theOscMessage.addrPattern().equals("/noteOn")) {
    int num = theOscMessage.get(0).intValue(); 
    int vel = theOscMessage.get(1).intValue();
    int depth = theOscMessage.get(2).intValue();
    print("noteOn: ");println(num, vel, depth);
    notes.add(new Note(num, vel, depth, speed, speedPerspective));
  }
  //pianoOff
  if (theOscMessage.addrPattern().equals("/noteOff")) {
    int num = theOscMessage.get(0).intValue();
    int vel = theOscMessage.get(1).intValue();
    int depth = theOscMessage.get(2).intValue();
    print("noteOff: ");println(num, vel, depth);
    for (int i = notes.size() - 1; i >= 0; i--) {
      Note note = notes.get(i);
      if (note.num == num && note.depth == depth && note.offTime < 0){
        note.offTime = millis();
      }
    }
  }
}

class Note {
  int num, vel;
  int depth; //0 is piano, 1 and more is algo
  float onTime, offTime, duration; //in seconds
  float x, y, dx, dy; //location, then width / height
  float speed; //how fast it should move across the screen
  int r,g,b;
  
  Note(int theNum, int theVel, int theDepth, float theSpeed, float theSpeedPerspective) {
    num = theNum;
    vel = theVel;
    onTime = millis();
    offTime = -1; //this indicates that we don't yet know the offTime yet — note hasn't finished
    depth = theDepth;
    speed = theSpeed + theSpeedPerspective * theSpeed * (vel/128.0-0.5);
   
    x = 0;
    y = height-(num-bottomNoteNum+1)*vertScale;
    dx = 0;
    dy = pow(vel,2) * noteSizeScale;
    
    if(depth==0){
      r=255;g=0;b=0;
    }else{
      r=0;g=255;b=0;
    }
  }
  
  void update()
  {
    int currentTime = millis();
    x += speed;
    if (offTime < 0){
      dx = -x;
    }
    //stroke(0,255,0);
    noStroke();
    fill(r,g,b,vel*255/128);
    rect(x, y, dx, dy);
  }
}