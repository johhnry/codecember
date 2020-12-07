// The radius of the circles
int minRadius = 50;
int maxRadius = 190;

// The circles are represented as a 2D array wrapped onto itself
// When the snake go over cols in x direction, it loops to 0
int cols = 100;
int rows = 10;

// The initial sizes of the snakes
int minSnakeSize = 10;
int maxSnakeSize = cols / 2;

float turnPercent = 0.03;

ArrayList<Snake> snakes;


/* 
 * A simple wrapper of a point
 * I made this instead of PVector because of float approximation
 */
class Location {
  int x, y;

  Location(int x, int y) {
    this.x = x;
    this.y = y;
  }

  Location copy() {
    return new Location(x, y);
  }

  void add(int xOffset, int yOffset) {
    x += xOffset;
    y += yOffset;
  }
}


/*
* The Snake class is inspired from the game snake
 * https://en.wikipedia.org/wiki/Snake_(video_game_genre)
 */
class Snake {
  // Stores a list of positions
  ArrayList<Location> positions;

  // value to prevent the snake to turn twice
  boolean justTurned = false;

  Snake(int x, int y, int initialSize) {
    positions = new ArrayList<Location>();
    positions.add(new Location(x, y));

    // Add the pieces
    for (int i = 1; i < initialSize; i++) {
      addPiece();
    }
  }

  void display() {
    noFill();
    stroke(0);
    strokeWeight(8);

    beginShape();
    for (int i = 0; i < positions.size(); i++) {
      Location pos = positions.get(i);
      
      // The x location is on the circle
      float angle = pos.x * (TWO_PI / cols);
      
      // The y location is on the rings
      float radius = pos.y * ((maxRadius - minRadius) / rows) + minRadius;
      
      // Vary the stroke with the length
      stroke(0, map(i, 0, positions.size() - 1, 255, 0));
      
      vertex(cos(angle) * radius, sin(angle) * radius);
    }
    endShape();
  }
  
  // Shift all the pieces of the snake
  void update() {
    for (int i = positions.size() - 1; i >= 1; i--) {
      positions.set(i, positions.get(i - 1).copy());
    }
  }

  void moveForward() {
    Location head = getHead();
    head.add(1, 0);
    if (head.x >= cols) head.x = 0;
    justTurned = false;
  }

  void moveInside() {
    positions.get(0).add(0, -1);
    justTurned = true;
  }

  void moveOutside() {
    positions.get(0).add(0, 1);
    justTurned = true;
  }

  Location getHead() {
    return positions.get(0);
  }

  Location getTail() {
    return positions.get(positions.size() - 1);
  }
  
  // Add a piece at the end of the snake
  void addPiece() {
    Location tail = getTail();
    int newX = tail.x - 1;
    if (newX < 0) newX = cols - 1;
    positions.add(new Location(newX, tail.y));
  }
}


void setup() {
  size(500, 500, P2D);

  snakes = new ArrayList<Snake>();

  for (int i = 0; i < rows; i++) {
    int randomPosition = int(random(maxSnakeSize, cols));
    int randomSize = int(random(minSnakeSize, maxSnakeSize));
    snakes.add(new Snake(randomPosition, i, randomSize));
  }
}


// Display the tracks
void displayCircles() {
  noFill();
  stroke(180, 100);
  strokeWeight(2);

  for (float radius = minRadius; radius < maxRadius; radius += (maxRadius - minRadius) / rows) {
    circle(width / 2, height / 2, radius * 2);
  }
}


void draw() {
  background(255);
  
  // In order to optimize the colision detection
  // Create a 2D boolean map of the current configuration
  // true when there's a snake on a cell, false otherwise
  boolean[][] map = new boolean[cols][rows];
  for (Snake snake : snakes) {
    for (Location loc : snake.positions) {
      map[loc.x][loc.y] = true;
    }
  }

  translate(width / 2, height / 2);
  
  // Go through every snake
  for (int i = 0; i < snakes.size(); i++) {
    Snake snake = snakes.get(i);
    
    // Display and update the position of the snake
    snake.display();
    snake.update();
    
    Location head = snake.getHead();
    boolean canTurnInside, canTurnOutside;

    
    int insideY = head.y - 1;
    if (insideY < 0) insideY = rows - 1;
     
    // Test if the snake can turn inside
    if (head.y == 0) canTurnInside = false;
    else canTurnInside = !map[head.x][insideY];

    // Test if snake can turn outside
    if (head.y == rows - 1) canTurnOutside = false;  
    else canTurnOutside = !map[head.x][(head.y + 1) % rows];
    
    boolean obstacleInFront = map[(head.x + 1) % cols][head.y];
    
    // Turn if there's an obstacle or randomly (if the snake didn't just turned before)
    if ((random(1) > (1 - turnPercent) && !snake.justTurned) || obstacleInFront) {
      if (canTurnInside && canTurnOutside) {
        if (random(1) < 0.5) snake.moveInside();
        else snake.moveOutside();
      } else if (canTurnInside) {
        snake.moveInside();
      } else if (canTurnOutside) {
        snake.moveOutside();
      }
    } else { // Otherwise move forward
      snake.moveForward();
    }
  }
}
