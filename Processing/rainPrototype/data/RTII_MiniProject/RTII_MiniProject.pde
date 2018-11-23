//Easing med lyd

import ddf.minim.*;
import ddf.minim.analysis.*;
import org.openkinect.processing.*;
import codeanticode.syphon.*;
import processing.serial.*;

Minim       minim;
AudioInput myAudio;
FFT         myAudioFFT;

boolean     showVisualizer   = false;

int         myAudioRange     = 11;
int         myAudioMax       = 100;

float       myAudioAmp       = 40.0;
float       myAudioIndex     = 0.2;
float       myAudioIndexAmp  = myAudioIndex;
float       myAudioIndexStep = 0.35;

float[]     myAudioData      = new float[myAudioRange];

float radius;
float radiusScale = 10;
float easing = 0.2;

// ************************************************************************************

//Easing med lyd
float lerpAmount;
float lerpChange;
color endCol;
color c;
color startCol;

// Kinect Library object
Kinect2 kinect2;

// set the distance thresholds for the tracking (in mm).
float minThresh = 500; // 860
float maxThresh = 600; // 960
PImage img;

// for finding the centroid
float avgX;
float avgY;
int closestInBlob = 0;

// detection within threshold of pushed mesh
boolean thresholdOK = false;

SyphonServer server;

// The serial port:
Serial myPort;
int inByte;
int inByteMax;
int inByteMin;

// colorlerping
float cBrightness;


void settings() {
  size(512, 424, P3D);
  PJOGL.profile=1;
}


void setup() {
  // Create syhpon server to send frames out.
  server = new SyphonServer(this, "Processing Syphon");

  frameRate(180);
  background(200, 200, 200);
  //size(512,424);
  //fullScreen();
  scale(-1, -1);
  kinect2 = new Kinect2(this);
  kinect2.initDepth();
  kinect2.initDevice();
  img = createImage(kinect2.depthWidth, kinect2.depthHeight, RGB);
  // size(1000,1000);
  noStroke();


  // ************************************************************************************

  minim   = new Minim(this);
  myAudio = minim.getLineIn();

  myAudioFFT = new FFT(myAudio.bufferSize(), myAudio.sampleRate());
  myAudioFFT.linAverages(myAudioRange);
  myAudioFFT.window(FFT.GAUSS); //guissian FFT

  // ************************************************************************************

  // Initialisations
  initArduino();


}

void initArduino() {
  // List all the available serial ports:
  printArray(Serial.list());

  // Open the port you are using at the rate you want:
  myPort = new Serial(this, Serial.list()[9], 9600);

  inByte = myPort.read();
  print(inByte);

  inByteMin = 255;
  inByteMax = 0;
}


void draw() {
  // fade
  // background(0);

  // --------------------------- Processes the Arduino
  
  while (myPort.available() > 0) {
    int inByte = myPort.read();

    // Processing the data min and max of a person's GSR
    if (inByte > inByteMax) {
      inByteMax = inByte;
    }
    if (inByte < inByteMin) {
      inByteMin = inByte;
    }
    if (inByte == 127) {
      inByteMin = 255;
      inByteMax = 0;
    }
    println(inByte);
    println("inByteMin" + inByteMin);
    println("inByteMax" + inByteMax);
    
    cBrightness = map(inByte, inByteMin, inByteMax, 0.0, 0.005);
    println(cBrightness);
  }
  

  // --------------------------- Processes the kinect
  img.loadPixels();

  // Get the raw depth as array of integers
  int[] depth = kinect2.getRawDepth();

  // for finding center
  float sumX = 0;
  float sumY = 0;
  float totalPixels = 0;

  for (int x = 0; x < kinect2.depthWidth; x++) {
    for (int y = 0; y < kinect2.depthHeight; y++) {
      int offset = x + y * kinect2.depthWidth; // find the pixel we are currently at
      int d = depth[offset]; // get the depth of that pixel

      if (d > minThresh && d < maxThresh ) { // && x > 100
        img.pixels[offset] = color(255, 0, 150); // color pixels white to see the tracking

        // use for the centroid of the blob/hand - so the particles will come from center
        sumX += x;
        sumY += y;
        totalPixels++;
      } else {
        img.pixels[offset] = color(0); // color the rest of the pixels black
      }
    }
  }

  img.updatePixels();
  // image(img, 0, 0); // Debug: drawing the kinect image (disabled)

  // Find the the centroid
  avgX = sumX / totalPixels;
  avgY = sumY / totalPixels;
  //fill(255, 0, 0);
  //ellipse(avgX, avgY, 60, 60); // Debug: draw center of the hand as a red circle

  // Get the depth at the centroid
  closestInBlob = depth[int(avgX) + int(avgY) * kinect2.depthWidth];

  // draw something or don't depending on whether the mesh is being touched
  if (closestInBlob > minThresh && closestInBlob < maxThresh ) {
    thresholdOK = true;
  } else { 
    thresholdOK = false;
  }

  // ------------------------- do color stuff
  lerpCol(cBrightness);


  // ------------------------- DEBUG STUFF
  fill(255, 255, 255);
  // draw centeroid a size dependent on proximity - smaller is closer
  ellipse(avgX, avgY, 10, 10);// closestInBlob/10, closestInBlob/10); 
  // ellipse(closestX, closestY, 40, 40); // draw actual closest point

  // --------------------------- Send image over syphon to mapping software
  server.sendScreen();
}


void lerpCol(float lerpBrightness) {

  if (thresholdOK==false) {
    lerpAmount = 0;
    lerpChange = lerpBrightness; // range: 0 - 0.005;
    endCol = color(0, 0, 0);
    c = startCol;
  }


  if (thresholdOK) {
    myAudioFFT.forward(myAudio.mix);
    myAudioDataUpdate();

    // CALL TO WIDGET SHOULD ALWAYS BE LAST ITEM IN DRAW() SO IT ALWAYS APPEARS ABOVE ANY OTHER VISUAL ASSETS
    if (showVisualizer) {
      myAudioDataWidget(); //FFT bands i bunden
    }

    //easing function
    float radiusTarget   = myAudioData[0]; //setting radiusTarget to the band that we are using the most
    float deltaRadius = radiusTarget - radius;
    radius += deltaRadius*easing;
    //*********************************

    float r = lerpColor(int(avgX)-height/4, int(avgX)-height/2, avgY-width/2);
    float g = lerpColor(int(avgY)-height/4, int(avgX)-height/2, avgX-width/2); 
    float b = lerpColor(int(avgX)-height/4, int(avgY)-height/2, lerpColor(int(avgX)-height/4, int(avgY)-height/2, avgX-width/2));
    startCol = color(r, g, b); // determined by position

    c = (lerpColor(startCol, endCol, lerpAmount)); // endcolor is end-brightness
    fill(c, radius*20);
    lerpAmount += lerpChange;

    if (lerpAmount>=1) {
      startCol=endCol;
    }

    ellipse(avgX, avgY, radius*radiusScale, radius*radiusScale);
  }
}


///functions for sound

void circleAmp() {

  myAudioFFT.forward(myAudio.mix);
  myAudioDataUpdate();

  // CALL TO WIDGET SHOULD ALWAYS BE LAST ITEM IN DRAW() SO IT ALWAYS APPEARS ABOVE ANY OTHER VISUAL ASSETS
  if (showVisualizer) myAudioDataWidget(); //FFT bands i bunden


  //easing function
  float radiusTarget   = myAudioData[0]; //setting radiusTarget to the band that we are using the most
  float deltaRadius = radiusTarget - radius;
  radius += deltaRadius*easing;
}


void myAudioDataUpdate() {
  for (int i = 0; i < myAudioRange; ++i) {
    float tempIndexAvg = (myAudioFFT.getAvg(i) * myAudioAmp) * myAudioIndexAmp;
    float tempIndexCon = constrain(tempIndexAvg, 0, myAudioMax);
    myAudioData[i]     = tempIndexCon;
    myAudioIndexAmp+=myAudioIndexStep;
  }
  myAudioIndexAmp = myAudioIndex;
}


//DEBUGGING function for FFT bands (in the bottom showing the frequency bands)
void myAudioDataWidget() {

  //h hint(DISABLE_DEPTH_TEST);
  noStroke(); 
  fill(0, 200); 
  rect(0, height-112, width, 102);

  for (int i = 0; i < myAudioRange; ++i) {
    println(myAudioData);
    //if     (i==0) fill(#237D26); // base  / subitem 0
    if (i==3) fill(#80C41C); // snare / subitem 3
    else          fill(#CCCCCC); // others

    rect(10 + (i*5), (height-myAudioData[i])-11, 4, myAudioData[i]);
  }
  // hint(ENABLE_DEPTH_TEST);
}

void stop() {
  myAudio.close();
  minim.stop();  
  super.stop();
}
