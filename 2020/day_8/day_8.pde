float margin = 80;

BaoBaoBag bag;

class BaoBaoBag {
  int size;
  float time = 0;
  float noiseIncr = 5;

  BaoBaoBag(int size) {
    this.size = size;
  }

  void display() {
    float cellSize = (width - 2 * margin) / size;
    
    float gap = 3;
    float hGap = gap / 2.0;

    noStroke();
    for (int i = 0; i < size; i++) {
      float x = margin + i * cellSize;
      for (int j = 0; j < size; j++) {
        float y = margin + j * cellSize;
        
        // Gap between the triangles
        float sqGap = gap / sqrt(2) + cos(time + i * 0.5) * sin(time + j * 0.5);
        float crossGap = hGap + sqGap;
        
        // four corners of the cell
        // A ------ B
        // | \    / |
        // |  \  /  |
        // |   \/   |
        // |   /\   |
        // |  /  \  |
        // | /    \ |
        // D ------ C
        float ax = x;
        float ay = y;
        
        float bx = x + cellSize;
        float by = y;
        
        float cx = x + cellSize;
        float cy = y + cellSize;
        
        float dx = x;
        float dy = y + cellSize;

        // Center coordinates of the cell
        float mX = x + cellSize / 2 + cos(time + i * 0.5) * cellSize / (abs(cos(time)) + 4);
        float mY = y + cellSize / 2 + pow(sin(time + j * 0.5), 2) * cellSize / (abs(sin(time)) + 8);

        fill(0);
        
        // Display triangles
        // up
        triangle(ax + crossGap, ay + hGap, bx - crossGap, by + hGap, mX, mY - sqGap);
        // left
        triangle(ax + hGap, ay + crossGap, dx + hGap, dy - crossGap, mX - sqGap, mY);
        // right
        triangle(bx - hGap, by + crossGap, cx - hGap, cy - crossGap, mX + sqGap, mY);
        // bottom
        triangle(cx - crossGap, cy - hGap, dx + crossGap, dy - hGap, mX, mY + sqGap);
      }
    }
  }
  
  // Update the simulation time
  void update() {
    time += 0.06;
  }
}

void setup() {
  size(500, 500);
  
  bag = new BaoBaoBag(10);
}

void draw() {
  background(255);

  bag.display();
  bag.update();
}
