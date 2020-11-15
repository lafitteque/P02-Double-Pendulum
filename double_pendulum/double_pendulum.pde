// Simulation of a double pendulum, two pendulums are connnected (each one with a mass at its end).

// Angles (rad)
float a1 = PI/2;
float a2 = PI/3;

// Angular Velocities (rad.s-1)
float a1_v = 0;
float a2_v = 0;

// Angular Accelerations (rad.s-2)
float a1_a = 0;
float a2_a = 0;

// radius
float r1=200;
float r2 = 200;

// masses
float m1 = 10;
float m2 = 2;

float deltaT = 0.1; // Time interval 
float g = 9.8; // Gravity

//Screen parameters
float screenWidth = 900;
float topOffset = 400;

// Memory variables
int pointsNumber = 500;
int index = 0;
int[][] points;

// positions
float x1;
float y1;
float x2;
float y2;


PGraphics canvas;


void setup(){
  points = new int[pointsNumber][2];
  
  // We want all our points in memory to be outside of the screen at the beginning so we can't see them
  for (int i=0 ; i<pointsNumber;i++){
    points[i][0] = -100;
    points[i][1] = -100;

  }
  
  // We use two layers in order to simplify the drawing of the points in memory
  size(900,900);
  canvas = createGraphics(900,900);
  canvas.beginDraw();
  canvas.background(20);
  canvas.endDraw();
}




void draw(){
  iterateState();
  
  actualizeMemory();
  
  image(canvas,0,0);
  
  drawPendulum();
  
  drawMemory();
}




void iterateState(){  
  
  // The equations were found at  https://www.myphysicslab.com/pendulum/double-pendulum-en.html (after eq (16))
  
  float num1 = -g * (2 * m1 + m2) * sin(a1);
  float num2 = -m2 * g * sin(a1-2*a2);
  float num3 = -2 * sin(a1-a2) * m2;
  float num4 = a2_v * a2_v * r2 + a1_v *r1 * cos(a1-a2);
  float den = r1 * (2 * m1 + m2 -m2*cos(2*a1-2*a2));
  a1_a = num1 + num2 +num3*num4;
  a1_a /= den;
  
  num1 = 2 * sin(a1 - a2);
  num2 = a1_v * a1_v * r1 * (m1+m2);
  num3 = g * (m1 + m2)*cos(a1);
  num4 = a2_v * a2_v * r2 * m2 * cos(a1-a2);
  den = r2 * ( 2 * m1 + m2 -m2*cos(2*a1-2*a2));
  a2_a = num1*(num2 + num3 + num4)/den;
  
  // Angular Velocity (rad.s-1)
  a1_v += deltaT * a1_a;
  a2_v += deltaT * a2_a;
  
  // Desceleration
  a1_v -= a1_v * 0.002; // which is completely equivalent to a_v *= 0.998 but for physical interpretation it is clearer to write it this way
  a2_v -= a1_v * 0.002;
  
  // Angle
  a1 += deltaT * a1_v;
  a2 += deltaT * a2_v;
  
  // Positions
  x1 = screenWidth/2 + r1 * cos(a1+PI/2);
  y1 = topOffset + r1 * sin(a1+PI/2);
  
  x2 = x1 + r2 * cos(a2+PI/2);
  y2 = y1 + r2 * sin(a2+PI/2);

}



void actualizeMemory(){
  
  points[index][0] = (int) x2;
  points[index][1] = (int) y2;

  index = (index + 1) % pointsNumber;
}



void drawPendulum(){

  // Drawing the two lines of the pendulum
  
  stroke(220);
  
  line(screenWidth/2,topOffset,x1,y1);
  
  line(x1,y1,x2,y2);
  
  // Drawing two circles depending on the masses (we are in 2D so I chose the square root to calculate the radius)
  int l1 = (int) sqrt(m1);
  int l2 = (int) sqrt(m2);
  
  noStroke();
  fill(255);
  ellipse(x1,y1,2*l1,2*l1);
  
  noStroke();
  fill(255);
  ellipse(x2,y2,2*l2,2*l2);
  
}

void drawMemory(){
  // Drawing the previous points depending on the time spent since their appearance 
  canvas.beginDraw();
  canvas.background(20);
  
  for (int i = 0; i<pointsNumber ; i++){  
    
    // If there are two points on top of each other, we want the brightest to be shown, so we first draw the darkest ones, 
    // so we go in the increasing order , beginning at the actual index (wich points to the last point)
    
    int drawMemoryIndex = (i + index - 1 + pointsNumber)%pointsNumber;
    
    canvas.strokeWeight(8 - 4 * (i+1) / (float) pointsNumber);
    
    canvas.stroke(max(20 , 255 * (i+1) / (float) pointsNumber));
    
    canvas.point(points[drawMemoryIndex][0] , points[drawMemoryIndex][1]);
    
  }
  canvas.endDraw();
}
