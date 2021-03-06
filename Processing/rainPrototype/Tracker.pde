/*
 * The code is based on Daniel Shiffman's code
 *
 * Taken from:
 * https://github.com/shiffman/OpenKinect-for-Processing/tree/master/OpenKinect-Processing/examples/Kinectv1/AverageP ointT racking
 *
 */

class KinectTracker {

  // Depth threshold
   int threshold;
   
  int thresholdHead = 600;
  float area;
  float areaMapped;
  // Raw location
  PVector loc;

  // Interpolated location
  PVector lerpedLoc;

  // Depth data
  int[] depth;

  // What we'll show the user
  PImage display;

  KinectTracker() {
    // This is an awkard use of a global variable here
    // But doing it this way for simplicity
    kinect.initDepth();
    kinect.enableMirror(true);
    // Make a blank image
    display = createImage(kinect.width, kinect.height, RGB);
    // Set up the vectors
    loc = new PVector(0, 0);
    lerpedLoc = new PVector(0, 0);
  }

  void track() {
    // Get the raw depth as array of integers
    depth = kinect.getRawDepth();

    // Being overly cautious here
    if (depth == null) return;

    float sumX = 0;
    float sumY = 0;
    float count = 0;

    for (int x = 0; x < kinect.width; x++) {
      for (int y = 0; y < kinect.height; y++) {

        int offset =  x + y*kinect.width;
        // Grabbing the raw depth
        int rawDepth = depth[offset];

        // Testing against threshold
        if (rawDepth < threshold) {
          sumX += x;
          sumY += y;
          count++;
        }
      }
    }
    // As long as we found something
    if (count != 0) {
      loc = new PVector(sumX, sumY);
    }

    // Interpolating the location, doing it arbitrarily for now
    lerpedLoc.x = PApplet.lerp(lerpedLoc.x, loc.x, 0.3f);
    lerpedLoc.y = PApplet.lerp(lerpedLoc.y, loc.y, 0.3f);
  }

  PVector getLerpedPos() {
    return lerpedLoc;
  }

  PVector getPos() {
    return loc;
  }

  void display() {
    PImage img = kinect.getDepthImage();
    float maxValue = 0;
    float minValue = kinect.width*kinect.height ;
    float maxValueX = 0;
    float maxValueY = 0;
    float minValueX = kinect.width;
    float minValueY = kinect.height;

    // Being overly cautious here
    if (depth == null || img == null) return;

    // Going to rewrite the depth image to show which pixels are in threshold
    // A lot of this is redundant, but this is just for demonstration purposes
    display.loadPixels();
    for (int x = 0; x < kinect.width; x++) {
      for (int y = 0; y < kinect.height; y++) {

        int offset = x + y * kinect.width; 
        // Raw depth
        int rawDepth = depth[offset]; 
        int pix = x + y * display.width; //why is it y*width
        if (rawDepth < threshold) {
          // A blue color instead
          display.pixels[pix] = color(0, 0, 255); //set correct pixels to blue

          maxValue = max(maxValue, pix);
          minValue = min(minValue, pix);

          maxValueX = max(maxValueX, x);
          minValueX = min(minValueX, x);

          maxValueY = max(maxValueY, y);
          minValueY = min(minValueY, y);
        } 

        /* if (thresholdHead>815 ) {
         // A blue color instead
         display.pixels[pix] = color(255, 0, 0); //set correct pixels to blue
         if(pix > maxValue){
         maxValue = pix;
         maxValueX = x;
         maxValueY = y;
         }
         
         if(pix < minValue){
         minValue = pix;
         minValueX = x;
         minValueY = y;
         } 
         
         } */


        else {
          display.pixels[pix] = img.pixels[offset];
        }

        // if(display.pixels[pix] == color(0, 0, 255));
      }
    }
    display.updatePixels();

    // Draw the image
    image(display, 0, 0);

    noFill();
    stroke(255, 0, 0);
    rect(minValueX, minValueY, maxValueX-minValueX, maxValueY-minValueY);
    area = (maxValueX-minValueX) * (maxValueY-minValueY);
  }
  float areaMapped(float min, float max) {
    areaMapped = map(area, min, max, 1, 255);
    return areaMapped;
  }

  int getThreshold() {
    return threshold;
  }

  void setThreshold(int t) {
    threshold =  t;
  }

  int getThresholdHead() {
    return thresholdHead;
  }

  void setThresholdHead(int t) {
    thresholdHead =  t;
  }
}
