import oscP5.*;
import netP5.*;

OscP5 oscP5;
ArrayList<Note> notes = new ArrayList<Note>();

float vertScale;
int bottomNoteNum = 21;
float noteSizeScale = 0.02;
float speed = 3; //how fast notes move across screen
float speedPerspective = 0.2; //how much faster louder notes move than slower ones (0 - 1)
float acceleration = 0.02;
int maxNumNotes = 400;
float startX = 40; //where notes are born

void setup() {
  //size(800, 800);
  fullScreen();
  background(0);
  
  oscP5 = new OscP5(this, 48068);
  vertScale = height/88.0;
  
  //rectMode(CORNERS); //so that the coords of the rects we draw give the coords of the corners, rather than corner and width/height
  ellipseMode(CORNER); //same for ellipse
  
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
    notes.add(new Note(num, vel, depth, speed, speedPerspective, acceleration, startX));
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
        break;
      }
    }
  }
}

class Note {
  int num, vel;
  int depth; //0 is piano, 1 and more is algo
  float onTime, offTime, duration; //in seconds
  float x, y, dx, dy; //location, then width / height
  float speed, accel; //how fast it should move across the screen, and how much it should accelerate
  float r,g,b,a;
  float fadeRate = 0.995;
  float targetHeight = vertScale; 
  float delay = 200;
  float startX;
  
  Note(int theNum, int theVel, int theDepth, float theSpeed, float theSpeedPerspective, float theAccel, float theStartX) {
    num = theNum;
    vel = theVel;
    onTime = millis();
    offTime = -1; //this indicates that we don't yet know the offTime yet — note hasn't finished
    depth = theDepth;
    speed = theSpeed + theSpeedPerspective * theSpeed * (vel/128.0-0.5);
    accel = theAccel;
    startX = theStartX;
   
    x = startX;
    y = height-(num-bottomNoteNum+1)*vertScale;
    dx = x;
    dy = pow(vel,2) * noteSizeScale;
    
    if(depth==0){
      r=255;g=0;b=0;
    }else{
      r=0;g=255;b=0;
    }
    a = vel*255/128;
  }
  
  void update()
  {
    int currentTime = millis();
    speed += accel;
    x += speed;
    if (offTime < 0){
      dx = -x+startX;
    }
    dy += (targetHeight - dy)/delay;
    a *= fadeRate;
    //stroke(0,255,0);
    noStroke();
    fill(r,g,b,a);
    rect(x, y - dy/2, dx, dy);
    stroke(255,255,255,a/3);
    line(x,0,x,height);
    stroke(255,255,255,a/15);
    line(0,y,width,y);
  }
}