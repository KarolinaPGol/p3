

void backgroundRect() {
  fill(0,0,0);
  rect(0, 0, width, height);
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

void instanceDrop(){
  for(int i=0; i< drops.length; i++){
     drops[i] = new Drop(random(width)); 
  }
}

void whiteDrops() {
  noStroke();

  // for loop to make all rain drops fall down and to show them.
  for (int i = 0; i < drops.length; i++) {
    drops[i].fall();
    //fill(random(255), 0, random(255));
    fill(255);
    drops[i].show(8000/500);

    noStroke();
    // fill(255,0,map(i,0,drops.length,0,255));
  }
}
void redDrops() {
  noStroke();

  // for loop to make all rain drops fall down and to show them.
  for (int i = 0; i < drops.length; i++) {
    drops[i].fall();
    // if mouse is pressed, stroke colour changes
    //fill(random(255), 0, random(255));
    fill(255, i, i);
    drops[i].show(8000/500);
    noStroke();
    // fill(255,0,map(i,0,drops.length,0,255));
  }
}

void orangeDrops() {
  noStroke();

  // for loop to make all rain drops fall down and to show them.
  for (int i = 0; i < drops.length; i++) {
    drops[i].fall();
    // if mouse is pressed, stroke colour changes
    //fill(random(255), 0, random(255));
    fill(255, 150, i);
    drops[i].show(8000/500);
    noStroke();
    // fill(255,0,map(i,0,drops.length,0,255));
  }
}

void turquoiseDrops() {
  noStroke();

  // for loop to make all rain drops fall down and to show them.
  for (int i = 0; i < drops.length; i++) {
    drops[i].fall();
    // if mouse is pressed, stroke colour changes
    //fill(random(255), 0, random(255));
    fill(i, 200, 255);
    drops[i].show(8000/500);

    noStroke();
    // fill(255,0,map(i,0,drops.length,0,255));
  }
}

void yellowDrops() {
  noStroke();

  // for loop to make all rain drops fall down and to show them.
  for (int i = 0; i < drops.length; i++) {
    drops[i].fall();
    // if mouse is pressed, stroke colour changes
    //fill(random(255), 0, random(255));
    fill(255, 255, i);
    drops[i].show(8000/500);

    noStroke();
    // fill(255,0,map(i,0,drops.length,0,255));
  }
}


void yellowBubble() {

  for (int i = 0; i < drops.length; i++) {
    drops[i].fall();

    fill(255, 255, 0);
    stroke(255, 200, 0);
    strokeWeight(5);
    drops[i].show(8000/40);
  }
}
void orangeBubble() {
  for (int i = 0; i < drops.length; i++) {
    fill(255, 140, 0);

    drops[i].fall();

    fill(255, 140, 0);
    stroke(255, 180, 0);
    strokeWeight(5);
    drops[i].show(8000/40);
  }
}

void turquoiseBubble() {

  for (int i = 0; i < drops.length; i++) {
    drops[i].fall();

    fill(0, 200, 255);
    stroke(0, 0, 255);
    strokeWeight(5);
    drops[i].show(8000/40);
  }
}

void helocupt() {
  stroke(255);
  strokeWeight(30);
  int cx = width/2;
  int cy = height/2;

  int a = 450; // major axis of ellipse
  int b = 250; // minor axis of ellipse

  float t = millis()/60.0f; //increase to slow down the movement


  for (int i = 1; i <= 1; i++) {
    t = t + 100;
    int x = (int)(cx + a * cos(t));
    int y = (int)(cy + b * sin(t));

    line(cx, cy, x, y);
  }
}
void redBubble() {
  for (int i = 0; i < drops.length; i++) {
    drops[i].fall();

    fill(255, 0, 0);
    stroke(255, 150, 0);
    strokeWeight(2);
    drops[i].show(400);
  }
}


void helocuptReverse() {
  stroke(255);
  strokeWeight(30);
  int cx = width/2;
  int cy = height/2;

  int a = 450; // major axis of ellipse
  int b = 250; // minor axis of ellipse

  float t = millis()/60.0f; //increase to slow down the movement


  for (int i = 1; i <= 1; i++) {
    t = t + 100;
    int x = (int)(cx + a * cos(-t));
    int y = (int)(cy + b * sin(-t));

    line(cx, cy, x, y);

  }
}

void helocuptMulti() {
  stroke(255);
  strokeWeight(5);
  int cx = width/2;
  int cy = height/2;

  int a = 450; // major axis of ellipse
  int b = 250; // minor axis of ellipse

  float t = millis()/1000f; //increase to slow down the movement


  for (int i = 1; i <= 12; i++) {
    t = t + 100;
    int x = (int)(cx + a * cos(t));
    int y = (int)(cy + b * sin(t));

    line(cx, cy, x, y);
  }
}

void helocuptMultiReverse() {
  stroke(255);
  strokeWeight(5);
  int cx = width/2;
  int cy = height/2;

  int a = 450; // major axis of ellipse
  int b = 250; // minor axis of ellipse

  float t = millis()/1000f; //increase to slow down the movement


  for (int i = 1; i <= 12; i++) {
    t = t + 100;
    int x = (int)(cx + a * cos(-t));
    int y = (int)(cy + b * sin(-t));

    line(cx, cy, x, y);
  }
}
void kinectSetup() {
  kinect = new Kinect(this);
  tracker = new KinectTracker();
}

void fillUp() {
  int y = 0;
  fill(255, 255, 255);
  noStroke();
  rect(0, 0, width, y);

  y++;
}

void FCsetup() {
  // ********* FADECANDY SETUP*********
  // Connect to the local instance of fcserver
  opc = new OPC(this, "127.0.0.1", 7890);

  // Map one 64-LED strip to the center of the window
  opc.ledStrip(0, 64, 640/2+700, 520/10*9, 640 / 90.0, 0, false);
  opc.ledStrip(64, 64, 206+700, 520/10*5+14, 640 / 90.0, radians(120), true);
  opc.ledStrip(128, 64, 431+700, 275, 640 / 90.0, radians(60), true);
}

void kinectInfo() {
  // Display some info
  fill(255);
  strokeWeight(2);
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

void buttonControlledLights() {

  if (keyPressed) {
    if (key == 'y' || key == 'Y') {
      redBubble();
    }

    if (key == 'u' || key == 'U') {
      yellowBubble();
    }
    if (key == 'i' || key == 'I') {
      orangeBubble();
    }

    if (key == 'h' || key == 'H') {
      redDrops();
    }

    if (key == 'j' || key == 'J') {
      yellowDrops();
    }

    if (key == 'k' || key == 'K') {
      orangeDrops();
    }

    if (key == 'l' || key == 'L') {
      turquoiseDrops();
    }

    if (key == 'æ' || key == 'Æ') {
      whiteDrops();
    } 
    if (key == 'm' || key == 'M') {
      helocuptMultiReverse();
    }
    if (key == ',' || key == ';') {
      helocuptMulti();
    } 

    if (key == '.' || key == ':') {
      helocupt();
    } 
    if (key == '-' || key == '_') {
      helocuptReverse();
    }
    if (key == 'n' || key == 'N') {
      fillUp();
    }
  } else {
    turquoiseBubble();
  }
}