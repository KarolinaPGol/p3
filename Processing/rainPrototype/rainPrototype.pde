import org.openkinect.freenect.*;
import org.openkinect.processing.*;

FlockingGame g;
OPC opc;
float rectAreaMap;
float m;
Drop[] drops = new Drop[300];

KinectTracker tracker;
Kinect kinect;

void setup()
{
  size(640, 520);
  kinectSetup();
  FCsetup();
  instBoids();
}


void draw()
{
  kinectTracker();
  backgroundRect();
  rectAreaMap =  map(g.rectArea, 50000, 200000, 0, 255);
  rain();
  g.update();
  getAverageColor();
  kinectInfo();
}