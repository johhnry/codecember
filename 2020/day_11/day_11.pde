float margin = 50;

ArrayList<Circle> circles;
float offset = 0;
int nCircles = 7;


class Circle {
  int x, y, radius;
  
  Circle(int x, int y, int radius) {
    this.x = x;
    this.y = y;
    this.radius = radius;
  }
  
  void display(float depth) {
    // Go through every pixel enclosing the circle and the depth
    for (int i = int(x - radius - depth); i < x + radius + depth; i++) {
      for (int j = int(y - radius - depth); j < y + radius + depth; j++) {
        // Compute the distance from the center
        float dist = dist(i, j, x, y);
        
        // If the pixel is in the circle +/- random value (responsible for the blur)
        if (dist < random(radius - depth, radius) + random(depth)) {
          // Color it in black
          pixels[i + j * width] = color(map(dist, 0, radius + depth, 0, 50), 30);
        }
      }
    }
  }
}


void setup() {
  size(500, 500);
  
  // Create the circles
  circles = new ArrayList<Circle>();
  
  for (int i = 0; i < nCircles; i++) {
    circles.add(new Circle(0, 0, 30));
  }
}

void draw() {
  background(255);
  
  // We are manipulating the pixels directly
  loadPixels();
  
  // The circle in focus is changing
  float currentCircle = ((sin(offset) + 1) / 2) * nCircles;
  
  // For every circle
  for (int i = 0; i < circles.size(); i++) {
    Circle circle = circles.get(i);
    
    // Compute the offset between each circles on x and y
    float xOffset = sin(offset / 4) * 50;
    float yOffset = 20;
    int startX = int(width / 2 - (nCircles / 2) * xOffset);
    int startY = int(height / 2 + (nCircles / 2) * yOffset);
    
    // Change their location
    circle.x = int(startX + i * xOffset);
    circle.y = int(startY - i * yOffset);
    
    // The distance from the focus point
    float distToFocus = abs(currentCircle - i);
    
    // Display the circle according to that distance
    circle.display(map(distToFocus, 0, nCircles, 0, 1) * 100);
  }
  updatePixels();
  
  // Increase the offset
  offset += 0.05;
}
