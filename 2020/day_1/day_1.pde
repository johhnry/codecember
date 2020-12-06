int nLines = 30;
float noiseAngle = 0;
float noiseDiameter = 1;
float noiseIncr = 0.05;
float margin = 60;

void setup() {
  size(500, 500);
}

void draw() {
  background(255);
  
  float gap = width / nLines;
  float xoffset = cos(noiseAngle) * noiseDiameter;
   
  // Go through every lines on the grid
  for (float x = margin; x <= width - margin; x += gap) { 
    float yoffset = sin(noiseAngle) * noiseDiameter;

    for (float y = margin; y <= height - margin; y += gap) {
      // Compute 2D noise
      float noise = noise(xoffset, yoffset);
      
      // Compute the direction from the noise
      PVector direction = PVector.fromAngle(TWO_PI * noise).mult(gap * 0.6);
      
      // Vary the stroke with the noise
      strokeWeight(noise * 5);
      line(x, y, x + direction.x, y + direction.y);
      
      yoffset += noiseIncr;
    }

    xoffset += noiseIncr;
  }

  noiseAngle += 0.01;
}
