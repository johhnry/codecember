float margin = 60;

GameOfLife game;

class GameOfLife {
  boolean[][] cells;
  int[][] neighbours;
  int size;
  PGraphics canvas;
  
  GameOfLife(int size) {
    this.size = size;
    cells = new boolean[size][size];
    neighbours = new int[size][size];
    
    // Create a canvas to isolate the drawing and help for transparency
    canvas = createGraphics(width, height);
  }
  
  // Randomly initialize the grid with a probability
  void initialize(float ratio) {
    for (int i = 0; i < size; i++)
      for(int j = 0; j < size; j++)
        cells[i][j] = (random(1) < ratio);
  }
  
  void display() {
    // Center the grid on the canvas
    float areaSize = (width - 2 * margin);
    float cellSize = areaSize / size;
    
    canvas.beginDraw();
    canvas.noStroke();
    for (int i = 0; i < size; i++) {
      float x = width / 2 - areaSize / 2 + i * cellSize;
      for (int j = 0; j < size; j++) {
        float y = height / 2 - areaSize / 2 + j * cellSize;
        
        if (cells[i][j]) {
          canvas.fill(0, map(neighbours[i][j], 0, 8, 0, 30));
        } else {
          canvas.fill(255, 5);
        }
        
        canvas.rect(x, y, cellSize, cellSize);
      }
    }
    canvas.endDraw();
    
    image(canvas, 0, 0);
  }
  
  // Game of life step
  void update() {
    // Dupliate the grid
    boolean[][] newCells = cells.clone();
    
    // For every cell
    for (int i = 0; i < size; i++) {
      for (int j = 0; j < size; j++) {
        // Start counting the number of neighbours
        int neighbours = 0;
        
        // true or false if next to the borders
        boolean left = i > 0, right = i < size - 1, up = j > 0, down = j < size - 1;
        
        if (left) {
          if (cells[i - 1][j]) neighbours++;
          if (up && cells[i - 1][j - 1]) neighbours++;
          if (down && cells[i - 1][j + 1]) neighbours++;
        }
        
        if (right) {
          if (cells[i + 1][j]) neighbours++;
          if (up && cells[i + 1][j - 1]) neighbours++;
          if (down && cells[i + 1][j + 1]) neighbours++;
        }
        
        if (up && cells[i][j - 1]) neighbours++;
        if (down && cells[i][j + 1]) neighbours++;
        
        // Follow the rules
        if (neighbours > 3 || neighbours < 2) newCells[i][j] = false;
        else if (neighbours == 3) newCells[i][j] = true;
        
        // Store the number of neighbours in another array
        this.neighbours[i][j] = neighbours;
      }
    }
    
    // Replace the current grid with the new one
    cells = newCells;
  }
}

void setup() {
  size(500, 500);
  
  // Grid 100 cells wide
  game = new GameOfLife(100);
  
  // Initialize the grid
  game.initialize(0.10);
}

void draw() {
  background(255);
  
  game.display();
  
  // Update every two frames
  if (frameCount % 2 == 0) game.update();
}
