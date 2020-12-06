float margin = 50;

// Start with one side
int sides = 1;
float radius = 150;

float duration = 1000;
float currentTime = 0;

void setup() {
  size(500, 500);
}

void draw() {
  background(255);

  translate(width / 2, height / 2);

  stroke(0);
  noFill();
  strokeWeight(2);
  
  // For a number of sides, make the loop 2 times to split it
  beginShape();
  for (int i = 0; i < sides * 2; i++) {
    float angle = i * (TWO_PI / (sides * 2));
    float x = cos(angle) * radius;
    float y = sin(angle) * radius;
    
    // The side is pair so we need to move the point
    if (i % 2 != 0) {
      float prevAngle = ((i - 1) % (sides * 2)) * (TWO_PI / (sides * 2));
      float nextAngle = ((i + 1) % (sides * 2)) * (TWO_PI / (sides * 2));
      
      // Compute the middle point on the edge
      PVector middle = new PVector(((cos(prevAngle) + cos(nextAngle)) * radius) / 2, ((sin(prevAngle) + sin(nextAngle)) * radius) / 2);
      PVector target = new PVector(x, y);
      
      // Move it to match the target point through time
      float t = (millis() - currentTime) / duration;
      PVector between = PVector.add(middle, PVector.sub(target, middle).mult(t));

      vertex(between.x, between.y);

      strokeWeight(7);
      point(between.x, between.y);
    } else {
      vertex(x, y);

      strokeWeight(7);
      point(x, y);
    }
  }
  strokeWeight(2);
  endShape(CLOSE);
  
  // After a certain duration, double the number of sides
  if (millis() - currentTime > duration) {
    currentTime = millis();
    sides *= 2;
  }
}
