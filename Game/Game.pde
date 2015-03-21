float depth = 100;
float rotationX = 0.0;
float rotationY = 0.0;
float rotationZ = 0.0;
float boardSpeed = 0.7;

float boardSize = 50;
float ballSize = 3;

boolean addCylinderMode = false;

PVector ballLocation;
PVector ballVelocity;
PVector gravity;

float cylinderBaseSize = 4;
float cylinderHeight = 9;
int cylinderResolution = 40;

PShape closedCylinder = new PShape();
PShape openCylinder = new PShape();
PShape topCylinder = new PShape();
PShape bottomCylinder = new PShape();

ArrayList<PVector> cylinderList;

Mover ball;

void setup() {
  size(1000, 700, P3D);  // size always goes first!
  if (frame != null) {
    frame.setResizable(true);
  }
  frameRate(60);
  textureMode(IMAGE);

  ball = new Mover();
  cylinderList = new ArrayList<PVector>();

  createCylinder();
}
void draw() {

  directionalLight(200, 150, 100, 0, -1, 0);
  directionalLight(130, 130, 130, 100, 1, 0);
  ambientLight(102, 102, 102);
  background(200);

  noStroke();

  if (addCylinderMode == true) {
    camera(width/2, 200, 0.1, width/2, height/2, 0, 0, 1, 0);

    translate(width/2, height/2, 0);
    pushMatrix();
    scale(1, 0.07, 1);
    fill(60, 130, 170);
    box(boardSize);
    popMatrix();
  } else {
    ball.checkEdges();
    ball.checkCylinderCollision();


    camera(width/2, height/2 - 20, depth, width/2, height/2, 0, 0, 1, 0);

    translate(width/2, height/2, 0);

    rotateX(rotationX);
    rotateY(rotationY);
    rotateZ(rotationZ);

    pushMatrix();
    scale(1, 0.07, 1);
    fill(60, 130, 170);
    box(boardSize);
    popMatrix();
  }

  ball.display();

  for (int i=0; i<cylinderList.size (); i++) {
    pushMatrix();
    translate(cylinderList.get(i).x, 0, cylinderList.get(i).y);
    rotateX(PI/2);
    //rotateY(rotationY);
    //rotateZ(rotationZ);
    shape(closedCylinder);
    popMatrix();
  }
}

void createCylinder() {

  noStroke();
  fill(255, 0, 0);
  float angle;
  float[] x = new float[cylinderResolution + 1];
  float[] y = new float[cylinderResolution + 1];
  //get the x and y position on a circle for all the sides
  for (int i = 0; i < x.length; i++) {
    angle = (TWO_PI / cylinderResolution) * i;
    x[i] = sin(angle) * cylinderBaseSize;
    y[i] = cos(angle) * cylinderBaseSize;
  }

  closedCylinder = createShape(GROUP);

  openCylinder = createShape();
  openCylinder.beginShape(QUAD_STRIP);
  //draw the border of the cylinder
  for (int i = 0; i < x.length; i++) {
    openCylinder.vertex(x[i], y[i], 0);
    openCylinder.vertex(x[i], y[i], cylinderHeight);
  }
  openCylinder.endShape();

  topCylinder = createShape();
  topCylinder.beginShape(TRIANGLE_FAN);
  topCylinder.vertex(0, 0, 0);
  for (int i = 0; i < x.length; i++) {
    topCylinder.vertex(x[i], y[i], cylinderHeight);
  }
  topCylinder.endShape();

  bottomCylinder = createShape();
  bottomCylinder.beginShape(TRIANGLE_FAN);
  bottomCylinder.vertex(0, 0, cylinderHeight);
  for (int i = 0; i < x.length; i++) {
    bottomCylinder.vertex(x[i], y[i], cylinderHeight);
  }
  bottomCylinder.endShape();

  closedCylinder.addChild(openCylinder);
  closedCylinder.addChild(topCylinder);
  closedCylinder.addChild(bottomCylinder);
}

void keyPressed() {
  if (key == CODED) {
    if (keyCode == RIGHT) {
      rotationY += 0.06 * boardSpeed;
    } else if (keyCode == LEFT) {
      rotationY -= 0.06 * boardSpeed;
    } else if (keyCode == SHIFT) {
      addCylinderMode = true;
    }
  }
}
void keyReleased() {
  if (key == CODED) {
    if (keyCode == SHIFT) {
      addCylinderMode = false;
    }
  }
}

void mouseClicked() {
  if (addCylinderMode == true) {
    float coin1 = screenX(-boardSize/2, 0, boardSize/2);
    float coin2 = screenX(boardSize/2, 0, boardSize/2);
    float boardWidthOnScreen = coin2 - coin1;
    float zoom = boardSize/boardWidthOnScreen;
    float x = mouseX - width/2;
    float y = mouseY - height/2;

    if (width/2 - boardWidthOnScreen/2 <= mouseX && mouseX <= width/2 + boardWidthOnScreen/2 && height/2 - boardWidthOnScreen/2 <= mouseY && mouseY <= height/2 + boardWidthOnScreen) { // PAS CHANGER

      PVector n = new PVector(ball.location.x, 0, ball.location.z);
      n.sub(new PVector(x*zoom, 0, y*zoom));

      if (n.mag() > cylinderBaseSize + ballSize) { // cylindre pas dans ball
        cylinderList.add(new PVector(x*zoom, y*zoom));
      }
    }
  }
}

void mouseDragged() {
  rotationX = -map(mouseY - height/2, -height/2, height/2, -PI/3, PI/3) * boardSpeed;
  if (rotationX < -PI/3)
    rotationX = -PI/3;

  if (rotationX > PI/3)
    rotationX = PI/3;

  rotationZ = map(mouseX - width/2, -width/2, width/2, -PI/3, PI/3) * boardSpeed;
  if (rotationZ < -PI/3)
    rotationZ = -PI/3;

  if (rotationZ > PI/3)
    rotationZ = PI/3;
}

void mouseWheel(MouseEvent event) {
  if (event.getCount() < 0.0) {
    boardSpeed /= 1.1;
  } else {
    boardSpeed *= 1.1;
  }
}


class Mover {
  PVector location;
  PVector velocity;
  PVector gravity;
  Mover() {
    location = new PVector(0, -4.65, 0);
    velocity = new PVector(0, 0, 0);
    gravity = new PVector(0, 0.04, 0);
  }
  
  void update() {
    location.add(velocity);
  }
  void display() {
    pushMatrix();
    fill(0, 255, 0);
    translate(location.x, location.y, location.z);
    sphere(ballSize);
    popMatrix();
  }
  void checkEdges() {
    PVector gravityForce = new PVector(sin(rotationZ) * gravity.y, 0, -sin(rotationX) * gravity.y);
    float normalForce = 1;
    float mu = 0.01;
    float frictionMagnitude = normalForce * mu;
    PVector friction = velocity.get();
    friction.mult(-1);
    friction.normalize();
    friction.mult(frictionMagnitude);
    
    velocity.add(gravityForce);
    velocity.add(friction);
    
    location.add(velocity);
    
    if (location.x > boardSize/2){
      velocity.x = velocity.x * -1;
      location.x = boardSize/2;
    }
    
    if (location.x < -boardSize/2){
      velocity.x = velocity.x * -1;
      location.x = -boardSize/2;
    }
    
    if (location.z > boardSize/2){
      velocity.z = velocity.z * -1;
      location.z = boardSize/2;
    }
    
    if (location.z < -boardSize/2){
      velocity.z = velocity.z * -1;
      location.z = -boardSize/2;
    }
  }
  
  void checkCylinderCollision(){
    
     for (int i=0; i<cylinderList.size(); i++){
       PVector n = new PVector(location.x, 0, location.z);
       n.sub(new PVector(cylinderList.get(i).x, 0, cylinderList.get(i).y));
       
       if (n.mag() < cylinderBaseSize + ballSize){ // collision
         n.normalize();
         PVector temp = n.get();
         temp.mult(2);
         temp.mult(velocity.dot(n));
         velocity.sub(temp);
         
         location.add(velocity); // detach the ball
       }
       
        
     }
    
  }
}

