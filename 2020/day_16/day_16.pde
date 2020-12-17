float offset = 0;

int nLines = 20;
float vSize = 100;


/**
 * Display a wave with different frequencies, offset and location
 */
void drawWave(int steps, float cycles, float offset, float yPos, float hSize) {
  noFill();
  stroke(0, 50);
  
  // Center on x
  float startX = width / 2 - hSize / 2;
  
  beginShape();
  for (int i = 0; i <= steps; i++) {
    float x = startX + i * (hSize / steps);
    
    float angle = offset + map(x, 0, width, 0, TWO_PI * cycles);
    float y = yPos + cos(angle) * 50;
    
    float xx = x - (pow(sin(angle), 2) * 20) - pow(cos(angle / 2), 2) * 20;
    float yy = y + noise(cos(offset + angle) * 2) * 20;
    vertex(xx, yy);
    
    // Put a point every 5 vertex
    if (i % 5 == 0) {
      strokeWeight(5);
      point(xx, yy);
    }
  }
  strokeWeight(2);
  endShape();
}


/**
 * Display multiple waves horizontally
 */
void horizontalWaves(int nLines, float vSize) {
  // Rotate 90° (did this afterward instead of swaping x and y)
  rotate(HALF_PI);
  translate(0, -height);
  
  float startY = height / 2 - vSize / 2;
  
  // Draw the curves, vary the parameters to offset them
  for (int i = 0; i < nLines; i++) {
    float cycles = map(i, 0, nLines - 1, 2, 3);
    float y = startY + i * (vSize / nLines);
    float angle = map(i, 0, nLines, 0, TWO_PI);
    float off = offset + cos(angle) * i * 0.05;
    
    drawWave(50, cycles, off, y, 300);
  }
}


void setup() {
  size(500, 500);
}


void draw() {
  background(255);
  
  horizontalWaves(nLines, vSize);
  
  offset -= 0.04;
}
