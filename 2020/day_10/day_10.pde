float margin = 50;

PGraphics mask;
float time = 0;


/*
* Draws a white polygon on a separate canvas
*/
void drawPolygonMask(PGraphics canvas, float x, float y, float diameter, int sides) {
  float radius = diameter / 2;
  
  canvas.beginDraw();
  canvas.noStroke();
  canvas.fill(255);
  canvas.beginShape();
  for (int i = 0; i < sides; i++) {
    float angle = (i + 0.5) * (TWO_PI / sides);
    canvas.vertex(x + cos(angle) * radius, y + sin(angle) * radius);
  }
  canvas.endShape(CLOSE);
  canvas.endDraw();
}


/*
* Draw the waves on the screen with a mask (you can change it with any shape you like)
*/
void drawWaves(PGraphics mask, float time) {
  mask.loadPixels();
  loadPixels();
  
  for (int x = 0; x < mask.width; x++) {
    for (int y = 0; y < mask.height; y++) {
      int loc = x + y * mask.width;
      
      // If the pixel is black
      if (brightness(mask.pixels[loc]) == 255) {
        float xx = map(x, 0, mask.width, 0, 1);
        float yy = map(y, 0, mask.height, 0, 1);
        // noise(xx * 4, yy * 4)
        float value = cos((xx + (yy * sin(time)) + noise(xx + cos(time), yy)) * (150 - noise(xx, yy - sin(time)) * 50));
        pixels[loc] = color(map(value, -0.2, 0.1, 0, 1) * 255);
      }
    }
  }
  updatePixels();
}


void setup() {
  size(500, 500);
  
  // Create a polygon mask on a separate PGraphics
  mask = createGraphics(width, height);
  drawPolygonMask(mask, width / 2, height / 2, 300, 6);
}


void draw() {
  background(255);
  
  // Draw the waves with that mask
  drawWaves(mask, time);
  
  // Increase the animation time
  time += 0.01;
}
