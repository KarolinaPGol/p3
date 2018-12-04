

void backgroundRect() {
  fill(0);
  rect(0, 0, width, height);
}
void getAverageColor() {
  tracker.display.loadPixels();
  int b = 0;
  for (int i=0; i<tracker.display.pixels.length; i++) {
    color c = tracker.display.pixels[i];
    b += c&0xFF;
  }
  b /= tracker.display.pixels.length;
  m = map(b, 130, 142, 0, 255);
  println(m);
  fill(m);
  rect(0, 0, width, 30);
}
float getM() {
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
      fill(0, 0, 255);
      stroke(0, 255, 255);
      strokeWeight(20);
    }
    drops[i].show(8000/(rectAreaMap+20));
  }
}

void kinectSetup() {
  kinect = new Kinect(this);
  tracker = new KinectTracker();
}
void instBoids() {
  // for loop to make each index of array drops[] an instance of the Drop class 
  for (int i = 0; i < drops.length; i++) {
    drops[i] = new Drop(random(width));

    // setup flocking boid

    g = new FlockingGame(400); //creating 1000 birds
    background(255);
  }
}

void FCsetup() {
  // ********* FADECANDY SETUP*********
  // Connect to the local instance of fcserver
  opc = new OPC(this, "127.0.0.1", 7890);

  // Map one 64-LED strip to the center of the window
  opc.ledStrip(0, 64, width/2, height/10*9, width / 90.0, 0, false);
  opc.ledStrip(64, 64, 206, height/10*5+14, width / 90.0, radians(120), true);
  opc.ledStrip(128, 64, 431, 275, width / 90.0, radians(60), true);
}

void kinectInfo() {
  // Display some info
  fill(255);
  rect(0, height-40, width, 40);

  int t = tracker.getThreshold();
  fill(0);
  text("threshold: " + t + "    " +  "framerate: " + int(frameRate) + "    " + 
    "UP increase threshold, DOWN decrease threshold", 10, 500);
}

void kinectTracker() {
  tracker.track();
  tracker.display();
}