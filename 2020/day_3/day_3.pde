float margin = 50;

int nLines = 30;
float xResolution = 5;
float bandSize = 50;
float noiseAmplitude = 8;

float noiseAngle = 0;
float noiseRadius = 1;

void setup() {
  size(500, 500);
}

// Normal distribution formulae for smooth fallof
// https://en.wikipedia.org/wiki/Normal_distribution
float normalDistribution(float x, float mean, float deviation) {
  return (1 / deviation * sqrt(2 * PI)) * exp(-0.5 * pow((x - mean) / deviation, 2));
}

void draw() {
  background(255);

  strokeWeight(2);

  float ySize = (height - 2 * margin);
  float gap =  ySize / nLines;
  
  // Go through each line
  for (int i = 0; i < nLines; i++) {
    float y = margin + i * gap;
    float xSize = width - 2 * margin;
    float xOffset = y;
    float yOffset = y / ySize;

    noFill();

    // Go through each points on the line
    beginShape();
    for (float x = margin; x < width - margin; x += xResolution) {
      // Compute the distance from the center of the line
      float dist = map(x, margin + bandSize, margin + xSize - bandSize, -1, 1);
      
      // Compute smooth falloff with cosine offset based on the line number
      float smooth = normalDistribution(dist, cos(noiseAngle + TWO_PI * i / nLines) / 2, 0.3);
      
      // Compute seamless perlin noise 
      float noise = noise(cos(noiseAngle + xOffset) * noiseRadius, sin(noiseAngle + xOffset) * noiseRadius + yOffset);
      
      curveVertex(x, y - noise * smooth * noiseAmplitude);
      
      // Every five curve, inverse the direction
      if (i % 5 == 0) xOffset += 0.1;
      else xOffset -= 0.1;
    }
    endShape();
  }

  noiseAngle += 0.01;
}
