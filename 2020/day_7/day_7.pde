float margin = 50;

// Made x and y global values to simulate a lexical env
float x, y;

Grid grid;
ExpressionGenerator gen;


/*
* Main interface for the AST nodes
*/
interface ASTNode {
  float eval();
}


/*
* Enum for operators
*/
enum Operation {
  ADD("+"), SUBTRACT("-"), MULTIPLY("*");
  String op;

  private Operation(String op) {
    this.op = op;
  }

  String toString() {
    return op;
  }
}


/*
* Return a random operation
*/
Operation randomOp() {
  return Operation.values()[int(random((Operation.values().length)))];
}


/*
* Binary operator
*/
class BinOp implements ASTNode {
  Operation op;
  ASTNode left, right;

  BinOp(Operation op, ASTNode left, ASTNode right) {
    this.op = op;
    this.left = left;
    this.right = right;
  }

  float eval() {
    float l = left.eval();
    float r = right.eval();

    switch (op) {
    case ADD:
      return l + r;
    case SUBTRACT:
      return l - r;
    case MULTIPLY:
      return l * r;
    default:
      return 1;
    }
  }

  String toString() {
    return left.toString() + op + right.toString();
  }
}


/*
* Enum storing available function names
*/
enum FuncName {
  // Give them a ratio so we can pick more cos over noise for example
  COS(0.4), SIN(0.4), TAN(0.03), EXP(0.02), SQRT(0.05), NOISE(0.1);
  float ratio;
  
  private FuncName(float ratio) {
    this.ratio = ratio;
  }

  String toString() {
    return name().toLowerCase();
  }
}


/*
* Return a random function name based on their ratio
*/
FuncName randomFuncName() {
  float r = random(1);
  int choosen = 0;
  for (int i = 0; i < FuncName.values().length; i++) {
    float ratio = FuncName.values()[i].ratio;
    if (ratio <= r) {
      choosen = i;
      break;
    }
  }
  return FuncName.values()[choosen];
}


/*
* Responsible to call processing math functions
*/
class FunCall implements ASTNode {
  FuncName function;
  ASTNode arg;

  FunCall(FuncName function, ASTNode arg) {
    this.function = function;
    this.arg = arg;
  }

  float eval() {
    float a = arg.eval();

    switch(function) {
    case COS:
      return cos(a);
    case SIN:
      return sin(a);
    case TAN:
      return tan(a);
    case EXP:
      return exp(a);
    case SQRT:
      return sqrt(a);
    case NOISE:
      return noise(a);
    default:
      return 0;
    }
  }

  String toString() {
    return function + "(" + arg + ")";
  }
}


/*
* Holds a simple float
*/
class Value implements ASTNode {
  float value;

  Value(float value) {
    this.value = value;
  }

  float eval() {
    return value;
  }

  String toString() {
    return Float.toString(value);
  }
}


/*
* return x global value (very silly)
*/
class XValue implements ASTNode {
  float eval() {
    return x;
  }

  String toString() {
    return "x";
  }
}

/*
* return y global value
*/
class YValue implements ASTNode {
  float eval() { 
    return y;
  }

  String toString() {
    return "y";
  }
}

/*
* Time AST node return millis
*/
class Time implements ASTNode {
  float eval() { 
    return millis() / 1000.0;
  }

  String toString() {
    return "t";
  }
}


/*
* This class can generate random functions
*/
class ExpressionGenerator {
  // Recursive function to create a random AST
  ASTNode generate(int depth) {
    ASTNode left, right;
    
    // If we are at the end, put x/y and time with an operation
    if (depth == 1) {
      left = new Time();
      right = (random(1) < 0.5) ? new XValue() : new YValue();
      return new BinOp(randomOp(), left, right);
    }
    
    // Randomly add a binop or a function call
    if (random(1) < 0.4) {
      left = generate(depth - 1);
      right = generate(depth - 1);
      return new BinOp(randomOp(), left, right);
    } else {
      ASTNode arg = generate(depth - 1);
      return new FunCall(randomFuncName(), arg);
    }
  }
}

/*
* The actual grid
*/
class Grid {
  int size;
  // Stores a function as AST node
  ASTNode function;

  Grid(int size, ASTNode function) {
    this.size = size;
    this.function = function;
  }

  void setFunction(ASTNode function) {
    this.function = function;
  }

  void display() {
    float gap = (width - 2 * margin) / size;
    float maxCircleDiameter = 0.9 * gap;

    fill(0);
    noStroke();

    for (int i = 0; i < size; i++) {
      float xPos = margin + gap / 2 + i * gap;
      for (int j = 0; j < size; j++) {
        float yPos = margin + gap / 2 + j * gap;

        x = (float) i / size;
        y = (float) j / size;

        float radius = constrain(function.eval(), -1, 1) * maxCircleDiameter;

        circle(xPos, yPos, radius);
      }
    }
  
    textAlign(CENTER, CENTER);
    text(function.toString(), width / 2, margin / 2);
  }
}


void setup() {
  size(500, 500);

  gen = new ExpressionGenerator();
  grid = new Grid(32, gen.generate(4));
}


void draw() {
  background(255);
  
  // Display the grid
  grid.display();
  
  // Every 150 frames regenerate a new function (random tree with depth 5)
  if (frameCount % 150 == 0) {
    grid.setFunction(gen.generate(5));
  }
}
