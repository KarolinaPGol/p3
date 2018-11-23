import org.openkinect.freenect.*;
import org.openkinect.processing.*;

FlockingGame g;

OPC opc;
PImage im;
float xMap;
float yMap;
float rectAreaMap;
PVector v2;
Drop[] drops = new Drop[10];



// The kinect stuff is happening in another class
KinectTracker tracker;
Kinect kinect;

void setup()
{
  size(640, 520);
  kinect = new Kinect(this);
  tracker = new KinectTracker();

  im = loadImage("abstract.jpg");

  // for loop to make each index of array drops[] an instance of the Drop class 
  for (int i = 0; i < drops.length; i++) {
    drops[i] = new Drop(random(width));
    
    // setup flocking boid
    
      g = new FlockingGame(800); //creating 1000 birds
  background(255);

  }

  // ********* FADECANDY SETUP*********
  // Connect to the local instance of fcserver
  opc = new OPC(this, "127.0.0.1", 7890);

  // Map one 64-LED strip to the center of the window
  opc.ledStrip(0, 64, width/2, height/10*9, width / 90.0, 0, false);
  opc.ledStrip(64, 64, 206, height/10*5+14, width / 90.0, radians(120), false);
  opc.ledStrip(128, 64, 431, 275, width / 90.0, radians(60), false);
    background(0);


}





void draw()
{

  // Run the tracking analysis
  tracker.track();
  // Show the image

  // Let's draw the raw location
  PVector v1 = tracker.getPos();
  fill(50, 100, 250, 200);
  noStroke();
  ellipse(v1.x, v1.y, 20, 20);

  // Let's draw the "lerped" location
  v2 = tracker.getLerpedPos();
  fill(100, 250, 50, 200);
  noStroke();
  ellipse(v2.x, v2.y, 20, 20);

  // Display some info
  int t = tracker.getThreshold();
  fill(0);
  text("threshold: " + t + "    " +  "framerate: " + int(frameRate) + "    " + 
    "UP increase threshold, DOWN decrease threshold", 10, 500);


  // mapping mouseX and mouseY to other values
  yMap =  map(mouseY, height/4, height, 0, 350);
  xMap =  map(mouseX, 0, width, 0, height/2);
    rectAreaMap =  map(g.rectArea, 50000, 200000, 0, 255);

  // stroke and fill - fill follows the mouse mapped
  noStroke(); 
  fill(0, 0, 0);

  // background rect
  rect(0, 0, width, height);

  // rain function called
  rain();
  //tint(255, 255, 255, 100+v2YMapped);

  // fill black, no stroke
  fill(0);
  noStroke();  

  // rectangles to narrow the rain
  // rect(0, 0, xMap, height);
  // rect(width-xMap, 0, width, height);
      g.update();

}

void rain() {

  // for loop to make all rain drops fall down and to show them.
  for (int i = 0; i < drops.length; i++) {
    drops[i].fall();
    // if mouse is pressed, stroke colour changes
    if (mousePressed) {
      fill(rectAreaMap, 100, i*30);
      noStroke();
     } else {
      fill(rectAreaMap, 100, i*30);
      noStroke();
    }
    drops[i].show(255);
  }
}



void keyPressed() {
  int t = tracker.getThreshold();
  if (key == CODED) {
    if (keyCode == UP) {
      t+=5;
      tracker.setThreshold(t);
    } else if (keyCode == DOWN) {
      t-=5;
      tracker.setThreshold(t);
    }
  }
}



class FlockingGame{
  ArrayList birds;
  int num;
  int time;
  Target t;
  float x1, x2, rectWidth, rectHeight, rectArea, rectRatio;
  float minX=width, maxX=0, minY=height, maxY=0;
  
  FlockingGame(int inNum){
    num = inNum;
    t = new Target();
    birds = new ArrayList();
    for(int i=0; i<num; i++){ //addin birds to array birds
      birds.add(new Bird());
    }
  }
  void update(){
    time++;
    t.update();
    for(int i = 0; i<birds.size(); i++){
      Bird b = (Bird) birds.get(i);
      b.findNeighbors(birds);
      b.update(t.getPos());
      float d = b.pos.dist(t.pos);
      //if(b.pos.x>maxX)
        //maxX = b.pos.x;      
     
    // println(maxX);
      
    }
    
    //println(getMaxX(birds));
    noFill();
    stroke(204, 102, 0);
    x1= getMinX(birds);
    x2 = getMinY(birds);
    rectWidth= getMaxX(birds)-x1;
    rectHeight= getMaxY(birds)-x2;
    rect(x1, x2, rectWidth, rectHeight);
    rectArea = rectWidth*rectHeight;
    rectRatio = rectWidth/rectHeight;
    println("rect area: " + rectArea);
  }
  // Method for getting the maximum value
   float getMaxX(ArrayList inputArray){    
   float maxValue = 0; 
    for(int i=0;i < inputArray.size();i++){ 
      Bird b = (Bird) birds.get(i);
      if(b.pos.x > maxValue){ 
         maxValue = b.pos.x; 
      } 
    } 
    return maxValue; 
  }
  float getMaxY(ArrayList inputArray){    
   float maxValue = 0; 
    for(int i=0;i < inputArray.size();i++){ 
      Bird b = (Bird) birds.get(i);
      if(b.pos.y > maxValue){ 
         maxValue = b.pos.y; 
      } 
    } 
    return maxValue; 
  }
 
  // Method for getting the minimum value
  float getMinX(ArrayList inputArray){ 
    float minValue = width; 
    for(int i=0;i<inputArray.size();i++){ 
      Bird b = (Bird) birds.get(i);
      if(b.pos.x < minValue){ 
        minValue = b.pos.x; 
      } 
    }
    return minValue;
   } 
    
   float getMinY(ArrayList inputArray){ 
    float minValue = width; 
    for(int i=0;i<inputArray.size();i++){ 
      Bird b = (Bird) birds.get(i);
      if(b.pos.y < minValue){ 
        minValue = b.pos.y; 
      } 
    } 
    return minValue; 
  } 
  void generate(){
 
  }
}
 
///////////////////////////////////////////////////////////
//CLASS BIRD
///////////////////////////////////////////////////////////
class Bird {
  PVector pos; 
  PVector vel; //velocity
  PVector tar;
  PVector desiredHeading;
  BirdAI ai;
  float tsa; //turn step angle
  ArrayList neighbors;
  float seeDist;
  Bird() {
    pos = new PVector();
    tar = new PVector();
    pos.x = random(200, 500);
    pos.y = random(200, 500);
    vel=PVector.random2D();
    vel.mult(2);
    desiredHeading = new PVector();
    ai = new BirdAI();
    tsa = PI/50;
    seeDist = 50;
    neighbors = new ArrayList();
  }
  ////////////////////////////////////////////////////////////
  //step 1: collect information (find neighbors)
  ////////////////////////////////////////////////////////////
  void findNeighbors(ArrayList allBirds) {
    neighbors = new ArrayList(); //clean ArrayList
    PVector otherPos = new PVector();
    for (int i = 0; i< allBirds.size(); i++) {
      Bird b = (Bird) allBirds.get(i);
      if (this != b) {//do not compare with self
        otherPos.set(b.pos);
        float dist = pos.dist(otherPos);
        if (dist < seeDist) {
          neighbors.add(b);
        }
      }
    }
  }
 
  /////////////////////////////////////////////////////////////
  //step 2: take action
  /////////////////////////////////////////////////////////////
  void update(PVector inTar) {
    tar.set(inTar);
    //ai.update(pos, tar, neighbors);
    desiredHeading.set(ai.update(pos, tar, neighbors));
    float r = tsa * sign();
    vel.rotate(r);
    collisions();
    //if (pos.x>600){if (vel.x>0) vel.x*= -1;}
    pos.add(vel);
    render();
  }
 
  int sign() {
    int a = -(int) Math.signum(vel.y*desiredHeading.x - vel.x*desiredHeading.y);
    return a;
  }
 
  void collisions(){
    if ((pos.x>600)&&(vel.x>0)) vel.x *=-1;
    if ((pos.y>600)&&(vel.y>0)) vel.y *=-1;
    if ((pos.x<0)&&(vel.x<0)) vel.x *=-1;
    if ((pos.y<0)&&(vel.y<0)) vel.y *=-1;
  }
 
  void render() {
    fill(0,255,0);
    float s = 1;
    noStroke();
    pushMatrix();
    translate(pos.x, pos.y);
    rotate(vel.heading()+PI/2);
    beginShape();
    vertex(-s, 0);
    vertex(0, -4*s);
    vertex(s, 0);
    endShape(CLOSE);
    popMatrix();
  }
}
 
class BirdAI{
  ArrayList neighbors;
  Bird me;
  PVector pos; PVector tar;
  PVector avoidHeading; float avoidFactor;
  PVector copyHeading; float copyFactor;
  PVector centerHeading; float centerFactor;
  PVector targetHeading; float targetFactor;
  PVector desiredHeading;
  //Behaviour bhv;
 
  BirdAI(){
    pos = new PVector();
    tar = new PVector();
    avoidHeading = new PVector();
    copyHeading = new PVector();
    centerHeading = new PVector();
    targetHeading = new PVector();
    desiredHeading = new PVector();
    //bhv = new Behaviour();
  }
  PVector update(PVector inPos, PVector inTar, ArrayList inNeighbors){
    neighbors = inNeighbors;
    pos.set(inPos);
    tar.set(inTar);
    //calculate vectors
    avoidHeading.set(avoidV());          //calculate avoid vector
    copyHeading.set(copyV());            //calculate copy vector
    centerHeading.set(centerV());        //calculate center vector
    targetHeading.set(targetV());        //calculate target vector
    //apply weights
    avoidHeading.mult(1);                //apply heading weight
    copyHeading.mult(4);                 //apply heading weight
    centerHeading.mult(1);               //apply heading weight
    targetHeading.mult(5);               //apply heading weight
    //add them to find the desired heading
    desiredHeading.set(avoidHeading);
    desiredHeading.add(copyHeading);
    desiredHeading.add(centerHeading);
    desiredHeading.add(targetHeading);
    return desiredHeading;
  }
  PVector avoidV(){
    PVector aV = new PVector();
    PVector tow = new PVector();
    for(int i = 0; i < neighbors.size(); i++){
      Bird n = (Bird) neighbors.get(i);
      tow.set(pos); tow.sub(n.pos);
      float d = tow.mag();
      tow.normalize();
      tow.mult(20/d);
      aV.add(tow);
    }
    //aV.div((neighbors.size()+1)/2);
    return aV;
  }
 
  PVector copyV(){
    PVector cpV = new PVector(0,0,0);
    for(int i = 0; i < neighbors.size(); i++){
      Bird n = (Bird) neighbors.get(i);
      cpV.add(n.vel);
    }
    cpV.div(neighbors.size());
    return cpV;
  }
 
  PVector centerV(){
    PVector cnV = new PVector(0,0,0);
    float d = 0;
    for(int i = 0; i < neighbors.size(); i++){
      Bird b = (Bird) neighbors.get(i);
      d += pos.dist(b.pos);
      cnV.add(b.pos);
    }
    cnV.div(neighbors.size());
    PVector toC = new PVector();
    cnV.sub(pos);
    //cnV.mult(d/1000);
    //cnV.normalize();
    return cnV;
  }
 
  PVector targetV(){
    PVector tV = new PVector();
    tV.set(tar);
    tV.sub(pos);
    float d = pos.dist(tV);
    d = pow((d/2000),2);
    tV.mult(d);
    tV.normalize();
    tV.mult(mouseCheck());
    return tV;
  }
 
  int mouseCheck(){
    if (mousePressed) return -1;
    else return 1;
  }
}
 
class Target{
  PVector pos;
  Target(){
    pos = new PVector(300,300,0);
  }
  void update(){
    pos.x = mouseX;
    pos.y = mouseY;
    pos.z = 0;
    //show();
  }
  PVector getPos(){
    return pos;
  }
  void show(){
 
  }
}