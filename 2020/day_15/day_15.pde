float margin = 50;

// The buffer where we draw the letter
PGraphics letterCanvas;

// Text options
String text = "codecember";
int letterIndex = 0;
int changeFrame = 200;

ArrayList<Particle> particles;


/**
 * Particle class, pretty simple
 * stores a target destination and the previous one
 */
class Particle {
  PVector location, velocity, acceleration;
  PVector previousTarget, target;
  float speed;

  Particle(float x, float y, float speed) {
    location = new PVector(x, y);

    this.speed = speed;
    this.velocity = new PVector(0, 0);
    this.acceleration = new PVector(0, 0);
  }

  /**
   * Set the target of the particle, switch the previous one
   */
  void setTarget(PVector newTarget) {
    this.previousTarget = this.target;
    this.target = newTarget;
  }

  /**
   * The farthest from the target the speedier (bad english here ;)
   */
  void updateVelocity() {
    PVector diff = PVector.sub(target, location);

    float acc = map(diff.mag(), 0, 50, 0, 0.05);
    acceleration = diff.mult(acc * speed);
  }

  void update() {
    updateVelocity();
    velocity.add(acceleration);
    // Limit to not go too fast
    velocity.limit(2);
    location.add(velocity);
  }

  /**
   * Display a line between two targets
   */
  void display() {
    stroke(0, 50);
    strokeWeight(1);
    line(location.x, location.y, target.x, target.y);
  }
}


/**
 * Change the letter and assign new random targets
 */
void changeLetter() {
  char letter = text.charAt((letterIndex++) % text.length());

  // Display the letter
  letterCanvas.beginDraw();
  letterCanvas.background(255, 0);
  letterCanvas.textAlign(CENTER, CENTER);
  letterCanvas.fill(0);
  letterCanvas.textSize(400);
  letterCanvas.text(letter, width / 2, height / 2 - 100);
  letterCanvas.endDraw();

  assignTargets();
}


/**
 * Check for black pixels and assign new targets
 */
void assignTargets() {
  ArrayList<PVector> targets = new ArrayList<PVector>();

  letterCanvas.loadPixels();
  for (int x = 0; x < letterCanvas.width; x++) {
    for (int y = 0; y < letterCanvas.height; y++) {
      if (letterCanvas.pixels[x + y * letterCanvas.width] == color(0)) {
        targets.add(new PVector(x, y));
      }
    }
  }

  for (int i = 0; i < particles.size(); i++) {
    if (targets.size() != 0) {
      int randomTargetIndex = int(random(targets.size()));
      particles.get(i).setTarget(targets.remove(randomTargetIndex).copy());
    }
  }
}


void setup() {
  size(500, 500);
  
  // Create the buffer
  letterCanvas = createGraphics(width, height);
  
  // Create random particles
  particles = new ArrayList<Particle>();
  for (int i = 0; i < 1500; i++) {
    particles.add(new Particle(random(margin, width - margin), random(margin, height - margin), random(0.1, 1.5)));
  }
  
  // Initialize first letter
  changeLetter();
}


void draw() {
  background(255);

  if (frameCount % changeFrame == 0) {
    changeLetter();
  }

  for (Particle particle : particles) {
    particle.display();
    particle.update();
  }
}
