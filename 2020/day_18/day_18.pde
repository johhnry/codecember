float margin = 100;

/**
 * Display a cross with rotation and 1/3 of its size as stroke
 */
void cross(float x, float y, float size, float rotation) {
  rectMode(CENTER);
  fill(0);
  noStroke();
  
  pushMatrix();
  translate(x, y);
  rotate(rotation);
  rect(0, 0, size / 3, size);
  rect(0, 0, size, size / 3);
  popMatrix();
}


float crossSize = 50;
float offset = 0;
boolean crosses = true;


void setup() {
  size(500, 500);
}


void draw() {
  background(255);
  
  // Test if drawing crosses or squares
  if (crosses) {
    for (float x = margin + crossSize / 2; x <= width - margin - crossSize / 2; x += crossSize) {
      for (float y = margin + crossSize / 2; y <= height - margin - crossSize / 2; y += crossSize) {
        cross(x, y, crossSize, cos(offset) * TWO_PI);
      }
    }
  } else { // Draw squares
    // Draw black background
    noStroke();
    fill(0);
    square(width / 2, height / 2, width - margin * 2);
    
    for (float x = margin; x <= width - margin; x += crossSize) {
      for (float y = margin; y <= height - margin; y += crossSize) {
        pushMatrix();
        translate(x, y);
        rotate(cos(offset) * TWO_PI);
        fill(255);
        square(0, 0, 2 * crossSize / 3);
        popMatrix();
      }
    }
  }
  
  offset += 0.01;
  
  // Every loop, change crosses to squares
  if (offset > PI) {
    offset = 0;
    crosses = !crosses;
  }
}
