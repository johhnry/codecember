float margin = 80;

/**
 * 2D vector class of int
 */
class IntVector2D {
  int x, y;

  IntVector2D(int x, int y) {
    this.x = x;
    this.y = y;
  }

  /**
   * Copy constructor
   */
  IntVector2D copy() {
    return new IntVector2D(x, y);
  }
}


/**
 * Stone, storing a location and a size
 */
class Stone {
  IntVector2D location;
  float size;
  
  Stone(IntVector2D location, float size) {
    this.location = location;
    this.size = size;
  }
}


/**
 * Compute the taxicab distance
 * See : https://en.wikipedia.org/wiki/Taxicab_geometry
 */
int taxicabDistance(IntVector2D p, IntVector2D q) {
  return abs(p.x - q.x) + abs(p.y - q.y);
}


/**
 * The class representing the manhattan grid
 */
class ManhattanGrid {
  // The gap between lines on both directions
  float gapX, gapY;

  // The number of rows and columns
  int cols, rows;

  // The list of points on the grid
  ArrayList<IntVector2D> points;

  // Points put down some stones when they move
  ArrayList<Stone> stones;

  ManhattanGrid(int cols, int rows) {
    this.cols = cols;
    this.rows = rows;

    gapX = (width - 2 * margin) / cols;
    gapY = (height - 2 * margin) / rows;

    points = new ArrayList<IntVector2D>();
    stones = new ArrayList<Stone>();
  }

  /**
   * Add a point on the grid
   */
  void addPoint(int x, int y) {
    points.add(new IntVector2D(x, y));
  }

  /**
   * Add a point on the grid at a random location
   */
  void addRandomPointOnGrid() {
    addPoint(int(random(cols)), int(random(rows)));
  }

  /**
   * Randomly populate the grid with points
   */
  void randomlyPopulate(int n) {
    for (int i = 0; i < n; i++) {
      addRandomPointOnGrid();
    }
  }
  
  /**
   * Return true if the cell is not occupied
   */
  boolean isCellFree(int x, int y) {
    // Check for stones
    for (Stone stone : stones) {
      if (stone.location.x == x && stone.location.y == y) {
        return false;
      }
    }
    
    // Check for points
    for (IntVector2D point : points) {
      if (point.x == x && point.y == y) {
        return false;
      }
    }
    
    return true;
  }

  /**
   * Add Brownian motion to the points on the grid
   * See : https://en.wikipedia.org/wiki/Brownian_motion
   */
  void addBrownianMotion() {
    int stopped = 0;
    
    // For each point
    for (int i = 0; i < points.size(); i++) {
      IntVector2D point = points.get(i);
      
      // Add a stone at that place
      float normDistToNext = getNormalizedDistance(point, points.get((i + 1) % points.size()));
      stones.add(new Stone(point.copy(), normDistToNext * 20));
      
      // Stores the possible directions
      int[] free = new int[4];
      int added = 0;
      
      // Check if it can move
      if (point.x > 0 && isCellFree(point.x - 1, point.y)) free[added++] = 0;
      if (point.x < cols && isCellFree(point.x + 1, point.y)) free[added++] = 1;
      if (point.y > 0 && isCellFree(point.x, point.y - 1)) free[added++] = 2;
      if (point.y < rows && isCellFree(point.x, point.y + 1)) free[added++] = 3;
      
      // If we can't go anywhere break
      if (added == 0) {
        stopped++;
        continue;
      }
      
      // Choose a random direction from previous ones
      int choice = free[int(random(added))];
      
      // Do the appropriate operation
      if (choice == 0) point.x--;
      else if (choice == 1) point.x++;
      else if (choice == 2) point.y--;
      else if (choice == 3) point.y++;
    }
    
    // Stop the sketch if all the points are stopped
    if (stopped == points.size()) noLoop();
  }

  /**
   * Return the x coordinate of the point on the screen with the col number
   */
  float getPointX(int col) {
    return margin + gapX * col;
  }

  /**
   * Same as getPointX() but for the row
   */
  float getPointY(int row) {
    return margin + gapY * row;
  }
  
  /**
   * Return the normalized taxicab distance between two points
   */
  float getNormalizedDistance(IntVector2D p, IntVector2D q) {
    return taxicabDistance(p, q) / (float) (cols + rows);
  }

  /*
  * Display the taxicab distance lines
   */
  void displayPathBetween(IntVector2D p, IntVector2D q) {
    // Get points coordinates
    float px = getPointX(p.x);
    float py = getPointY(p.y);

    float qx = getPointX(q.x);
    float qy = getPointY(q.y);

    strokeWeight(map(getNormalizedDistance(p, q), 0, 1, 8, 0));
    stroke(0, 20);

    // If not aligned on the x axis
    if (p.x != q.x) {
      // Display the x line
      line(px, py, qx, py);
    }

    // If not aligned on the y axis
    if (p.y != q.y) {
      // Display the x line
      line(qx, qy, qx, py);
    }
  }

  /**
   * Display the grid lines
   */
  void displayGrid() {
    strokeWeight(2);
    stroke(0, 20);

    // Vertical lines
    for (int i = 0; i <= cols; i++) {
      float x = getPointX(i);
      line(x, margin, x, height - margin);
    }

    // Horizontal lines
    for (int i = 0; i <= rows; i++) {
      float y = getPointY(i);
      line(margin, y, width - margin, y);
    }
  }

  /**
   * Display the taxicab distances between all the points
   */
  void displayConnections() {
    for (int i = 0; i < points.size(); i++) {
      for (int j = 0; j < points.size(); j++) {
        if (i != j) {
          displayPathBetween(points.get(i), points.get(j));
        }
      }
    }
  }

  /**
   * Display the points on the grid
   */
  void displayPoints() {
    stroke(0);
    strokeWeight(15);

    for (IntVector2D point : points) {
      point(getPointX(point.x), getPointY(point.y));
    }
  }

  /**
   * Display the stones as circles
   */
  void displayStones() {
    for (Stone stone : stones) {
      //stroke(0, 200);
      //noFill();
      noStroke();
      fill(0, 100);
      //strokeWeight(1);
      
      circle(getPointX(stone.location.x), getPointY(stone.location.y), stone.size);
    }
  }

  /**
   * Display all the elements on the screen
   */
  void display() {
    displayGrid();
    displayConnections();
    displayStones();
    displayPoints();
  }

  /**
   * Update the grid
   */
  void update() {
    // Move the points
    addBrownianMotion();
  }
}

int updateFrame = 10;
ManhattanGrid grid;

void setup() {
  size(500, 500);
  
  // Create the grid with random points
  grid = new ManhattanGrid(20, 20);
  grid.randomlyPopulate(10);
  
  updateView();
}

/**
 * Redraw the background and the grid
 * Prevent from redrawing 60 times per second because the
 * grid methods are not well optimized and do a lot of loops...
 */
void updateView() {
  background(255);
  
  grid.display();
  grid.update();
}

void draw() {
  // Every updateFrame, redraw the screen
  if (frameCount % updateFrame == 0) {
    updateView();
  }
}
