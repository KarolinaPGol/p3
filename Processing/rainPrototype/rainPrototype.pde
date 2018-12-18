/* The code inspired by the following codes:
 * Daniel Shiffman:
 * https://thecodingtrain.com/CodingChallenges/004-purplerain.html?fbclid=IwAR1NUTJ6Bl5Lo4WOcN-7Dkt2nzmz8n7cBipH0tBI9srjf35qyt-MMVgYuuw
 * https://github.com/shiffman/OpenKinect-for-Processing/tree/master/OpenKinect-Processing/examples/Kinectv1/AverageP ointT racking
 *
 * Micah Elizabeth Scott:
 * https://github.com/scanlime/fadecandy/blob/master/examples/processing/triangle16attractor/OP C.pde
 */

import org.openkinect.freenect.*;
import org.openkinect.processing.*;
OPC opc;
float m;
float bBoxAreaMapped;
long lastTime = 0;
boolean whatev;

Drop[] drops = new Drop[400];

KinectTracker tracker;
Kinect kinect;

void setup()
{
  size(1400, 520, P3D);
  kinectSetup();
  FCsetup();
  instanceDrop();
  lastTime = millis();
  background(0);
}


void draw()
{
  // CALIBRATING THE KINECT TO THE HEIGHT OF THE PERSON.
  // GET PERSON TO RAISE ARMS IN FRONT OF THEM. SET THRESHOLD HERE
  tracker.threshold = 850;

  // CALIBRATING THE KINECT TO "WIDENESS" OF THE PERSON" 
  //(MIN, MAX)
  println("Raw Area: "+ tracker.area);
  println("AreaMapped:" + tracker.areaMapped(70000, 250000) );



  if (tracker.areaMapped <= 50) {

    fill(0, 220, 255);
    turquoiseBubble();
  }

  // THRESHOLD OF AREA. RUN EFFECTS FROM HERE. 0-255.

  if (tracker.areaMapped > 50) {
    backgroundRect();
    redDrops();


    //System.out.println( millis()-lastTime);
    if (millis()-lastTime>2000) {
      backgroundRect();
      helocuptMulti();
    }
  } else {
    lastTime = millis();
    // backgroundRect(); /fill:maybe this is not needed try with and without
  }  

  strokeWeight(2);
  kinectTracker();
  kinectInfo();
}
