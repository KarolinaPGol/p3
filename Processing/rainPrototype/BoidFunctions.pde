class FlockingGame {
  ArrayList birds;
  int num;
  int time;
  Target t;
  float x1, x2, rectWidth, rectHeight, rectArea, rectRatio;
  float minX=width, maxX=0, minY=height, maxY=0;

  FlockingGame(int inNum) {
    num = inNum;
    t = new Target();
    birds = new ArrayList();
    for (int i=0; i<num; i++) { //addin birds to array birds
      birds.add(new Bird());
    }
  }
  void update() {
    time++;
    t.update();
    for (int i = 0; i<birds.size(); i++) {
      Bird b = (Bird) birds.get(i);
      b.findNeighbors(birds);
      b.update(t.getPos());
      float d = b.pos.dist(t.pos);
    }


    noFill();
    stroke(204, 102, 0, 0); //Bounding box visibility, remove last digit to see it!
    x1= getMinX(birds);
    x2 = getMinY(birds);
    rectWidth= getMaxX(birds)-x1;
    rectHeight= getMaxY(birds)-x2;
    rect(x1, x2, rectWidth, rectHeight);
    rectArea = rectWidth*rectHeight;
    rectRatio = rectWidth/rectHeight;
  }
  // Method for getting the maximum value
  float getMaxX(ArrayList inputArray) {    
    float maxValue = 0; 
    for (int i=0; i < inputArray.size(); i++) { 
      Bird b = (Bird) birds.get(i);
      if (b.pos.x > maxValue) { 
        maxValue = b.pos.x;
      }
    } 
    return maxValue;
  }
  float getMaxY(ArrayList inputArray) {    
    float maxValue = 0; 
    for (int i=0; i < inputArray.size(); i++) { 
      Bird b = (Bird) birds.get(i);
      if (b.pos.y > maxValue) { 
        maxValue = b.pos.y;
      }
    } 
    return maxValue;
  }

  // Method for getting the minimum value
  float getMinX(ArrayList inputArray) { 
    float minValue = width; 
    for (int i=0; i<inputArray.size(); i++) { 
      Bird b = (Bird) birds.get(i);
      if (b.pos.x < minValue) { 
        minValue = b.pos.x;
      }
    }
    return minValue;
  } 

  float getMinY(ArrayList inputArray) { 
    float minValue = width; 
    for (int i=0; i<inputArray.size(); i++) { 
      Bird b = (Bird) birds.get(i);
      if (b.pos.y < minValue) { 
        minValue = b.pos.y;
      }
    } 
    return minValue;
  } 
  void generate() {
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
  float r;
  float acceleration;
  float maxforce;    // Maximum steering force
  float maxspeed;    // Maximum speed

  Bird() {
    pos = new PVector();
    tar = new PVector();
    pos.x = width/2;
    pos.y = height/2;
    vel=PVector.random2D();
    vel.mult(5); //SPEED!
    desiredHeading = new PVector();
    ai = new BirdAI();
    tsa = PI/5; //angle at which they turn, the larger this number the more over the place they will be
    seeDist = 50; //lower this if we thing bbox is too big but if its too low we might have lonely birds
    neighbors = new ArrayList();
    maxspeed = 50;
    maxforce = 0.3;
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
    render();
    tar.set(inTar);
    //ai.update(pos, tar, neighbors);
    desiredHeading.set(ai.update(pos, tar, neighbors));
    float r = tsa * sign();
    vel.rotate(r);
    collisions();
    //if (pos.x>600){if (vel.x>0) vel.x*= -1;}
    pos.add(vel);
  }

  int sign() {
    int a = -(int) Math.signum(vel.y*desiredHeading.x - vel.x*desiredHeading.y);
    return a;
  }

  void collisions() {
    if ((pos.x>600)&&(vel.x>0)) vel.x *=-1;
    if ((pos.y>600)&&(vel.y>0)) vel.y *=-1;
    if ((pos.x<0)&&(vel.x<0)) vel.x *=-1;
    if ((pos.y<0)&&(vel.y<0)) vel.y *=-1;
  }

  void render() {
    fill(0, 255, 0, 0); //boid here, change last digit to see the boid!
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
  PVector seek(PVector target) {
    PVector desired = PVector.sub(target, pos);  // A vector pointing from the position to the target
    // Scale to maximum speed
    desired.normalize();
    desired.mult(maxspeed);

    // Above two lines of code below could be condensed with new PVector setMag() method
    // Not using this method until Processing.js catches up
    // desired.setMag(maxspeed);

    // Steering = Desired minus Velocity
    PVector steer = PVector.sub(desired, vel);
    steer.limit(maxforce);  // Limit to maximum steering force
    return steer;
  }

  // Separation
  // Method checks for nearby boids and steers away
  PVector separate (ArrayList<BirdAI> boids) {
    float desiredseparation = 10;
    PVector steer = new PVector(0, 0, 0);
    int count = 0;
    // For every boid in the system, check if it's too close
    for (BirdAI other : boids) {
      float d = PVector.dist(pos, other.pos);
      // If the distance is greater than 0 and less than an arbitrary amount (0 when you are yourself)
      if ((d > 0) && (d < desiredseparation)) {
        // Calculate vector pointing away from neighbor
        PVector diff = PVector.sub(pos, other.pos);
        diff.normalize();
        diff.div(d);        // Weight by distance
        steer.add(diff);
        count++;            // Keep track of how many
      }
    }
    // Average -- divide by how many
    if (count > 0) {
      steer.div((float)count);
    }

    // As long as the vector is greater than 0
    if (steer.mag() > 0) {
      // First two lines of code below could be condensed with new PVector setMag() method
      // Not using this method until Processing.js catches up
      // steer.setMag(maxspeed);

      // Implement Reynolds: Steering = Desired - Velocity
      steer.normalize();
      steer.mult(maxspeed);
      steer.sub(vel);
      steer.limit(maxforce);
    }
    return steer;
  }
  // Cohesion
  // For the average position (i.e. center) of all nearby boids, calculate steering vector towards that position
  PVector cohesion (ArrayList<BirdAI> boids) {
    float neighbordist = 1;
    PVector sum = new PVector(0, 0);   // Start with empty vector to accumulate all positions
    int count = 0;
    for (BirdAI other : boids) {
      float d = PVector.dist(pos, other.pos);
      if ((d > 0) && (d < neighbordist)) {
        sum.add(other.pos); // Add position
        count++;
      }
    }
    if (count > 0) {
      sum.div(count);
      return seek(sum);  // Steer towards the position
    } else {
      return new PVector(0, 0);
    }
  }
}

class BirdAI {
  ArrayList neighbors;
  Bird me;
  PVector pos; 
  PVector tar;
  PVector avoidHeading; 
  float avoidFactor;
  PVector copyHeading; 
  float copyFactor;
  PVector centerHeading; 
  float centerFactor;
  PVector targetHeading; 
  float targetFactor;
  PVector desiredHeading;
  //Behaviour bhv;

  BirdAI() {
    pos = new PVector();
    tar = new PVector();
    avoidHeading = new PVector();
    copyHeading = new PVector();
    centerHeading = new PVector();
    targetHeading = new PVector();
    desiredHeading = new PVector();
    //bhv = new Behaviour();
  }
  PVector update(PVector inPos, PVector inTar, ArrayList inNeighbors) {
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
  PVector avoidV() {
    PVector aV = new PVector();
    PVector tow = new PVector();
    for (int i = 0; i < neighbors.size(); i++) {
      Bird n = (Bird) neighbors.get(i);
      tow.set(pos); 
      tow.sub(n.pos);
      float d = tow.mag();
      tow.normalize();
      tow.mult(40/d); // Change to increase the distance between birds
      aV.add(tow);
    }
    //aV.div((neighbors.size()+1)/2);
    return aV;
  }

  PVector copyV() {
    PVector cpV = new PVector(0, 0, 0);
    for (int i = 0; i < neighbors.size(); i++) {
      Bird n = (Bird) neighbors.get(i);
      cpV.add(n.vel);
    }
    cpV.div(neighbors.size());
    return cpV;
  }

  PVector centerV() {
    PVector cnV = new PVector(0, 0, 0);
    float d = 0;
    for (int i = 0; i < neighbors.size(); i++) {
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

  PVector targetV() {
    PVector tV = new PVector();
    tV.set(tar);
    tV.sub(pos);
    float d = pos.dist(tV);
    d = pow((d/20), 2);
    tV.mult(d);
    tV.normalize();
    tV.mult(mouseCheck());
    return tV;
  }


  int mouseCheck() {
    if (getM()>180) return -1;
    else return 1;
  }
}

class Target {
  PVector pos;
  Target() {
    pos = new PVector(300, 300, 0);
  }
  void update() {
    pos.x = width/2;
    pos.y = height/2;
    pos.z = 0;
    //show();
  }
  PVector getPos() {
    return pos;
  }
  void show() {
  }
}