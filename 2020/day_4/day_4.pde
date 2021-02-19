import java.util.List;

float margin = 50;

// Rössler attractor parameters
// https://en.wikipedia.org/wiki/R%C3%B6ssler_attractor
int iterations = 5000;
float a = 0.2;
float b = 0.2;
float c = 5.7;
float range = 25;
float h = 0.001;
int substeps = 50;
int cameraDist = 40;
int maxPoints = 4000;

float angle = 0;

List<PVector> points;

void setup() {
  size(500, 500, P3D);
  
  points = new ArrayList<PVector>();
  
  // Precompute the attractor points
  float x = 1;
  float y = 1;
  float z = 1;
  for (int i = 0; i < iterations; i++) {
    points.add(new PVector(x, y, z));
    
    for (int j = 0; j < substeps; j++) {
      float tempx = x;
      x += h * (- y - z);
      y += h * (tempx + a * y);
      z += h * (b + z * (tempx - c));
    }
  }
}

void draw() {
  background(255);
  
  // Place the camera in 3d space with turntable
  perspective(PI/3.0, width/height, 1, 200);
  camera(cos(angle) * cameraDist, sin(angle) * cameraDist, cameraDist * 0.7, 0, 0, 10, 0, 0, -1);
  
  // The points are drawn in order and disapear
  int begin = 0;
  int end = points.size();
  if (angle >= TWO_PI) {
    begin = int(((angle - TWO_PI) / TWO_PI) * points.size());
  } else {
    end = int((angle / TWO_PI) * points.size());
  }
  
  // Display the points
  strokeWeight(2);
  for (int i = begin; i < end; i++) {
    PVector p = points.get(i);
    stroke(map(i, begin, end, 0, 255));
    point(p.x, p.y, p.z);
  }
  
  angle += 0.01;
}
