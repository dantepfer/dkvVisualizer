import oscP5.*;
import netP5.*;

OscP5 oscP5;
ArrayList<Note> notes = new ArrayList<Note>();

float vertScale;
int bottomNoteNum = 21;
float noteSizeScale = 0.02;
float speed = 6; //how fast notes move across screen
float speedPerspective = 2.3; //how much faster louder notes move than slower ones (0 - 1)
float acceleration = 0;//0.02;
int maxNumNotes = 200;
float startX = 10; //where notes are born on the screen
int maxDepth = 15;

MyColor[] depthColors = new MyColor[maxDepth+1];

void setup() {
  size(800, 800);
  //fullScreen(2); (for external monitor)
  //fullScreen();
  //pixelDensity(displayDensity());
  background(0);

  oscP5 = new OscP5(this, 48068);
  vertScale = height/88.0;

  //rectMode(CORNERS); //so that the coords of the rects we draw give the coords of the corners, rather than corner and width/height
  ellipseMode(CORNER); //same for ellipse
  
  for (int i = 0; i < depthColors.length; i++){
    //depthColors[i] = new MyColor(int(random(255)), int(random(255)), int(random(255)));
    int baseIntensity = 255;
    //depthColors[i] = new MyColor(round(random(1))*baseIntensity, round(random(1))*baseIntensity, round(random(1))*baseIntensity);
    String bin = binary(i+1,3);
    depthColors[i] = new MyColor((bin.charAt(0)-48)*baseIntensity, (bin.charAt(1)-48)*baseIntensity, (bin.charAt(2)-48)*baseIntensity); // get 8 distinct colors
  }
}


void draw() {
  background(0);

  int currentTime = millis();

  if (notes.size() > maxNumNotes) {
    notes.remove(0);
  }

  for (int i = notes.size() - 1; i >= 0; i--) {
    Note note = notes.get(i);
    note.update();
  }
  connectPoints();
}

void oscEvent(OscMessage theOscMessage) {
  //noteOn
  if (theOscMessage.addrPattern().equals("/noteOn")) {
    int num = theOscMessage.get(0).intValue(); 
    int vel = theOscMessage.get(1).intValue();
    int depth = theOscMessage.get(2).intValue();
    print("noteOn: ");
    println(num, vel, depth);
    notes.add(new Note(num, vel, depth, speed, speedPerspective, acceleration, startX));
  }
  //pianoOff
  if (theOscMessage.addrPattern().equals("/noteOff")) {
    int num = theOscMessage.get(0).intValue();
    int vel = theOscMessage.get(1).intValue();
    int depth = theOscMessage.get(2).intValue();
    print("noteOff: ");
    println(num, vel, depth);
    for (int i = notes.size() - 1; i >= 0; i--) {
      Note note = notes.get(i);
      if (note.num == num && note.depth == depth && note.offTime < 0) {
        note.offTime = millis();
        break;
      }
    }
  }
  //other settings
  switch(theOscMessage.addrPattern()) {
    case "/speed":
      speed = theOscMessage.get(0).floatValue();
      break;
    case "/speedPerspective":
      speedPerspective = theOscMessage.get(0).floatValue();
      break;
    case "/acceleration":
      acceleration = theOscMessage.get(0).floatValue();
      break;
    case "/noteSizeScale":
      noteSizeScale = theOscMessage.get(0).floatValue();
      break;
  }
}



class Note {
  int num, vel;
  int depth; //0 is piano, 1 and more is algo
  float onTime, offTime, duration, //in seconds
    x, y, dx, dy, //location, then width / height
    speed, accel, //how fast it should move across the screen, and how much it should accelerate
    r, g, b, a, 
    fadeRate = 0.9999, 
    endTargetHeight = vertScale, 
    targetHeight, 
    heightDelay = 4, //delay in initial height growth
    heightDelay2 = 20, //delay in subsequent height reduction
    colorDelay = 30,
    startX;
   boolean shouldFade;

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
    dy = endTargetHeight;
    targetHeight = pow(vel, 2.1) * noteSizeScale;

    r = 255;
    g = 255;
    b = 255;
    a = 255;
    shouldFade = false;
  }

  void update()
  {
    int currentTime = millis();
    if (dy > targetHeight*0.92) {
      targetHeight = endTargetHeight;
      heightDelay = heightDelay2;
    }
    speed += accel;
    x += speed;
    if (offTime < 0) {
      dx = -x+startX;
    }
    dy += (targetHeight - dy)/heightDelay;
    a *= fadeRate;
    if(a < vel*255/128*1.1 && a > vel*255/128*0.9) {shouldFade = true;}
    if(!shouldFade){
      a += (vel*255/128 - a)/colorDelay;
    }else{
      a *= fadeRate;
    }
    stroke(depthColors[depth].r, depthColors[depth].g, depthColors[depth].b, a);
    //noStroke();
    r += (depthColors[depth].r - r)/colorDelay;
    g += (depthColors[depth].g - g)/colorDelay;
    b += (depthColors[depth].b - b)/colorDelay;
    fill(r, g, b, a);
    rect(x, y - dy/2, dx, dy);
    stroke(255, 255, 255, a/3);
    line(x, 0, x, y);
    //stroke(255, 255, 255, a/15);
    //line(0, y, width, y);
    
  }
}




class MyColor {
  int r, g, b;
  
  MyColor(int theR, int theG, int theB) {
    r = theR;
    g = theG;
    b = theB;
  }
}


void connectPoints() {
  for(int j = 0; j < maxDepth; j++){
    float prevX=0, prevY=0, prevDX=0, prevDY=0;
    for (int i = notes.size() - 1; i >= 0; i--) {
      Note note = notes.get(i);
      if (note.depth == j && note.x < width) {
        if(prevX > 0 && prevY > 0){
          stroke(255, 255, 255, 255);
          line(note.x,note.y, prevX, prevY);
        }
        prevX = note.x;
        prevY = note.y;
        prevDX = note.dx;
        prevDY = note.dy;
      }
    }
  }
}