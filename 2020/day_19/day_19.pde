float margin = 100;


/**
 * Classic particle class
 * stores a weight from [0, 1] for displaying the line
 */
class Particle {
  PVector location, velocity;
  float weight;
  
  Particle(float x, float y, PVector velocity, float weight) {
    location = new PVector(x, y);
    this.velocity = velocity;
    this.weight = weight;
  }
  
  void update() {
    location.add(velocity); 
  }
}


/**
 * A grain is a collection of particles expanding
 * For the reference, see : https://youtu.be/uG35D_euM-0?t=237
 * See also the wiki page : https://en.wikipedia.org/wiki/Grain_boundary
 */
class Grain {
  ArrayList<Particle> particles;
  PVector origin;
  
  Grain(float x, float y, int nParticles) {
    origin = new PVector(x, y);
    
    particles = new ArrayList<Particle>();
    
    // Choose a random seed for noise variations
    float seed = random(100);
    
    for (int i = 0; i < nParticles; i++) {
      float angle = i * (TWO_PI / nParticles);
      float speed = noise(seed + i) / 2;
      float weight = noise(seed + i / 10.0);
      
      // Use a velocity expanding from the center of the grain
      particles.add(new Particle(x, y, PVector.fromAngle(angle).mult(speed), weight));
    }
  }
  
  void update() {
    for (Particle particle : particles) {
      particle.update(); 
    }
  }
  
  void display() {
    noFill();
    beginShape();
    for (Particle particle : particles) {
      strokeWeight(0.5);
      
      stroke(particle.weight * 255);
      line(origin.x, origin.y, particle.location.x, particle.location.y);
      vertex(particle.location.x, particle.location.y);
    }
    
    stroke(0);
    endShape();
  }
}


/**
 * Scatter points on the canvas according to the poisson distribution
 * It uses the dart throwing method
 * Could also implement the weighted sample elimination : http://www.cemyuksel.com/research/sampleelimination/
 */
ArrayList<PVector> poissonDistributionScatterPoints(int nPoints, float radius) {
  // The number of valid points put
  int n = 0;
  
  ArrayList<PVector> points = new ArrayList<PVector>();
  boolean valid;
  
  // Loop until we placed the right number of points or it's not valid
  do {
    valid = true;
    float randomX = random(margin, width - margin);
    float randomY = random(margin, height - margin);
    
    // For every other points, check if it's inside it's area
    for (PVector point : points) {
      if (dist(point.x, point.y, randomX, randomY) < radius) {
        valid = false;
        break;
      }
    }
    
    // If valid add the choosen point
    if (valid) {
      points.add(new PVector(randomX, randomY));
      n++;
    }
  } while (!valid || n < nPoints);
  
  return points;
}


/**
 * A crystal contains multiple grains
 */
class Crystal {
  ArrayList<Grain> grains;
  
  Crystal(int nGrains) {
    grains = new ArrayList<Grain>();
    
    ArrayList<PVector> poissonDistrib = poissonDistributionScatterPoints(nGrains, 20);
    
    for (PVector point : poissonDistrib) {
      int n = int(random(50, 100));
      grains.add(new Grain(point.x, point.y, n)); 
    }
  }
  
  void display() {
    for (Grain grain : grains) {
      grain.display(); 
    }
  }
  
  void update() {
    // For every grain
    for (int i = 0; i < grains.size(); i++) {
      grains.get(i).update();
      
      // For every other grain
      for (int j = 0; j < grains.size(); j++) {
        // If it's different
        if (j != i) {
          // For every particle of that first grain
          for (Particle p1 : grains.get(i).particles) {
            // Constrain to the boundaries
            if (p1.location.x < margin || p1.location.x > width - margin ||
                p1.location.y < margin || p1.location.y > height - margin) {
              p1.velocity.mult(0.9);      
            }
            
            // For every other particle, check if the distance is too short
            for (Particle p2 : grains.get(j).particles) {
              if (dist(p1.location.x, p1.location.y, p2.location.x, p2.location.y) < 10) {
                // If yes reduce the velocity
                p1.velocity.mult(0.95);
              }
            }
          }
        }
      }
    }
  }
}


Crystal crystal;


void setup() {
  size(500, 500);
  
  // Create a new crystal with 15 clusters
  crystal = new Crystal(15);
}


void draw() {
  background(255);

  crystal.display();
  crystal.update();
}
