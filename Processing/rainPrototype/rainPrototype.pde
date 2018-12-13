import org.openkinect.freenect.*;
import org.openkinect.processing.*;
OPC opc;
float m;
float bBoxAreaMapped;
long lastTime = 0;
boolean whatev;

Drop[] drops = new Drop[150];

KinectTracker tracker;
Kinect kinect;

void setup()
{
  size(1400, 520, P3D);
  kinectSetup();
  FCsetup();
  instanceDrop();
  lastTime = millis();
}


void draw()
{
  // CALIBRATING THE KINECT TO THE HEIGHT OF THE PERSON.
  // GET PERSON TO RAISE ARMS IN FRONT OF THEM. SET THRESHOLD HERE
  tracker.threshold = 800;

  // CALIBRATING THE KINECT TO "WIDENESS" OF THE PERSON" 
  //(MIN, MAX)
  println("Raw Area: "+ tracker.area);
  println("AreaMapped:" + tracker.areaMapped(70000, 250000) );




  backgroundRect();


  // THRESHOLD OF AREA. RUN EFFECTS FROM HERE. 0-255.
 
  if (tracker.areaMapped > 100) {

System.out.println( millis()-lastTime);
    if (millis()-lastTime>5000) {     
      redDrops();
           
    }else {
    lastTime = millis();
    
    redBubble();
  }
  } 

  strokeWeight(2);
  kinectTracker();
  kinectInfo();
}