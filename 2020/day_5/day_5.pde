import java.util.List;

float margin = 50;

float noiseDepth = 0;
int pointSeparation = 3;
List<PVector> boids;

void setup() {
  size(500, 500);
  background(255);
  
  boids = new ArrayList<PVector>();
  
  // Create boids on the grid
  for (float x = margin; x < width - margin; x+=pointSeparation) {
    for (float y = margin; y < height - margin; y+=pointSeparation) {
      boids.add(new PVector(x, y));
    }
  }
}

void draw() {
  // Vary the brightness with time
  stroke((noiseDepth / TWO_PI) * 255, 10);
  
  // Go through every boid
  for (PVector boid : boids) {
    // Compute 2d noise with the depth as 3rd dimension
    float noise = noise(boid.x / width * 5, boid.y / width * 5, noiseDepth);
    
    // Compute the vector force from that noise value
    PVector force = PVector.fromAngle(noise * TWO_PI).mult(0.5);
    boid.add(force);
    
    // Prevent boids from escaping the box
    if (boid.x < margin) {
      boid.x = width - margin;
    }
    if (boid.x > width - margin) {
      boid.x = margin;
    }
    if (boid.y < margin) {
      boid.y = height - margin;
    }
    if (boid.y > height - margin) {
      boid.y = margin;
    }
    
    point(boid.x, boid.y);
  }
  
  noiseDepth += 0.01;
}
