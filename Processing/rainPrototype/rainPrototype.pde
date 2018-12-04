import org.openkinect.freenect.*;
import org.openkinect.processing.*;

FlockingGame g;
OPC opc;
PImage im;
float xMap;
float yMap;
float rectAreaMap;
  float m;
PVector v2;
Drop[] drops = new Drop[300];



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

    g = new FlockingGame(400); //creating 1000 birds
    background(255);
  }

  // ********* FADECANDY SETUP*********
  // Connect to the local instance of fcserver
  opc = new OPC(this, "127.0.0.1", 7890);

  // Map one 64-LED strip to the center of the window
  opc.ledStrip(0, 64, width/2, height/10*9, width / 90.0, 0, false);
  opc.ledStrip(64, 64, 206, height/10*5+14, width / 90.0, radians(120), true);
  opc.ledStrip(128, 64, 431, 275, width / 90.0, radians(60), true);
  background(0);
}


void draw()
{
  // Run the tracking analysis
  tracker.track();
  // Show the image
  tracker.display();

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

  //TEST ELIPSE FOR LED STRIP PLACEMENT
  //fill(255,0,0);
  //ellipse(mouseX, mouseY, 200, 200);

  getAverageColor();
}


void getAverageColor() {
  tracker.display.loadPixels();
  int b = 0;
  for (int i=0; i<tracker.display.pixels.length; i++) {
    color c = tracker.display.pixels[i];
    b += c&0xFF;
  }
  b /= tracker.display.pixels.length;
   m = map(b, 138, 142, 0, 255);
  println(m);
  fill(m);
  rect(0, 0, width, 30);
}
float getM(){
return m;
}
void keyPressed() {
  int t = tracker.getThreshold();
  if (key == CODED) {
    if (keyCode == UP) {
      t+=5;
      tracker.setThreshold(t);
      println(tracker.getThreshold());
    } else if (keyCode == DOWN) {
      t-=5;
      tracker.setThreshold(t);
      println(tracker.getThreshold());
    }
  }
}

void rain() {

  // for loop to make all rain drops fall down and to show them.
  for (int i = 0; i < drops.length; i++) {
    drops[i].fall();
    // if mouse is pressed, stroke colour changes
    if (m>160) {
      //fill(random(255), 0, random(255));
            fill(255);

      noStroke();
    } else {
      // fill(255,0,map(i,0,drops.length,0,255));
      fill(0,0,255);
      stroke(0,255,255);
      strokeWeight(20);

  }
    drops[i].show(8000/(rectAreaMap+20));
  }
}