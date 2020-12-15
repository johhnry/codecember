float margin = 60;

float offset = 0;
ArrayList<Particle> particles;
float searchRadius = 20;


/*
* The particle class, store a position it's influence radius and the speed
*/
class Particle {
  PVector location;
  float speed, radius;
  
  Particle(float x, float y, float speed, float radius) {
    this.location = new PVector(x, y);
    this.speed = speed;
    this.radius = radius;
  }
  
  /*
  * Display a point with alpha
  */
  void display() {
    stroke(0, map(alphaFromBorders() / 2, 0, 70, 0, 255));
    strokeWeight(radius);
    point(location.x, location.y);
  }
  
  /*
  * Compute the distance bewteen the borders with the margin
  */
  float alphaFromBorders() {
    return min(min(location.x - margin, width - margin - location.x), min(location.y - margin, height - margin - location.y));
  }
  
  /*
  * Update the position with perlin noise (again yesss)
  */
  void update() {
    float noise = noise(location.x / 100.0 + offset, location.y / 100.0);
    location.add(PVector.fromAngle(noise * TWO_PI).mult(speed));
    
    // Reset it's location if goes above the bounds
    if (location.x < margin) location.x = width - margin;
    if (location.x > width - margin) location.x = margin;
    if (location.y < margin) location.y = height - margin;
    if (location.y > height - margin) location.y = margin;
  }
}


void setup() {
  size(500, 500);
  
  // Create random particles on the screen
  particles = new ArrayList<Particle>();
  
  for (int i = 0; i < 200; i++) {
    float rX = random(margin, width - margin);
    float rY = random(margin, height - margin);
    float rSpeed = random(0.1, 2);
    float rRadius = random(5, 30);
    particles.add(new Particle(rX, rY, rSpeed, rRadius));
  }
}


void draw() {
  background(255);
  
  // Loop through every particle
  for (int i = 0; i < particles.size(); i++) {
    Particle particle = particles.get(i);
    
    // Loop through neighbours
    for (int j = 0; j < particles.size(); j++) {
      // If not the same
      if (i != j) {
        Particle other = particles.get(j);
        
        // Compute the distance for drawing the connection
        PVector distance = PVector.sub(particle.location, other.location);
        float distSqrd = pow(distance.x, 2) + pow(distance.y, 2);
        float radSqrd = pow(particle.radius, 2);
        
        // If less than the radius * 2, draw a line
        if (distSqrd < radSqrd * 2) {
          strokeWeight(1);
          stroke(0, particle.alphaFromBorders());
          line(particle.location.x, particle.location.y, other.location.x, other.location.y);
        }
        
        // If less than the diameter, add repelling force to push them
        if (distSqrd < radSqrd) {
          particle.location.add(distance.mult(map(distSqrd, 0, radSqrd, 0.05, 0.01) / 2)); 
        }
      }
    }

    particle.display();
    particle.update();
  }
  
  offset += 0.01;
}
