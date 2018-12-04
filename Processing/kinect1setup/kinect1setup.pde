
import org.openkinect.freenect.*;
import org.openkinect.processing.*;

KinectTracker tracker;
Kinect kinect;
PVector v2;

void setup() {
  size(640, 520);
  kinect = new Kinect(this);
  tracker = new KinectTracker();
}

void draw() {
  background(0);
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
  float m = map(b, 134, 138, 0, 255);
//println(m);
  fill(m);
  rect(0,0,width,30);
  
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