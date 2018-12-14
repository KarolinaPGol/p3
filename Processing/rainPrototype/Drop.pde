
class Drop {
  float x;
  float y;
  float z;
  float len;
  float yspeed;

  Drop(float x) {
    this.x = x;
    y  = random(-500, -50);
    z  = random(0, 20);
    len = map(z, 0, 20, 10, 300);
    yspeed  = map(z, 0, 20, 1, 10);
  }

  void fall() {
    y+= yspeed;

    if (y > height) {
      y = random(-200, -100);
      yspeed = map(z, 0, 20,  1, 20);
    }
  }

  void show(float r) {
    ellipse(x, y,r, r);
  }
  
  void dprint(){
    println("bullshit");
  }
}
